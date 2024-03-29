class LegendItem : Inventory abstract {
    // A class that contains a bunch of handy functions and overrides for handling procs.
    double timer;
    double timelimit;
    string alarm; // What sound, if any, should we play when the timer's up?
    double alarmPitch;
    bool alarmSet; // Should the alarm go off?
    int stacks; // Fixes repeated proccing of items with multiple copies. Also means we don't need to care about MaxAmount.

    Property TimerStart : timer;
    Property Timer : timelimit;
    Property StartStacks : stacks;
    Property Alarm : alarm, alarmPitch;

    double randomDecay; 
    double randomAdjust;
    Property RandomDecay: randomDecay;
    // Percentage adjustment of random rolls.
    // randomDecay determines how fast random rolls return to 0.
    // Allows for some PRNG.

    string remark; // the witty joke
    string shortdesc; // the short explanation
    Property Remark : remark;
    Property Desc : shortdesc;

    string rarity; // what rarity tier is this item?
    Property Rarity: rarity; // Will be allcaps'd for QoL

    string invicon; // The inventory icon.
    Property Icon : invicon;

    default {
        +BRIGHT; // Items should always be visible.
        +DONTGIB;
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
        LegendItem.TimerStart 0;
        LegendItem.Timer 0; // Timer must be set to be used correctly!
        LegendItem.StartStacks 1;
        LegendItem.Alarm "dsempty", 1.0;
        LegendItem.Rarity "COMMON"; // Should be a space-separated list. (I'm not gonna deal with whitespace in tier names.
    }

    String GetRarity() {
        let s = rarity;
        s.ToUpper();
        return s;
    }

    void GetTiers(out Array<String> results) {
        String s = GetRarity();
        s.split(results," ",TOK_SKIPEMPTY);
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();
        alarmSet = true;
        SetTimer();
    }

    override string PickupMessage () {
        return String.Format("%s: %s",GetTag(),GetShortDesc());
    }

    clearscope int GetStacks() {
        return stacks;
    }

    void HealOwner(int amount, bool overheal = false) {
        let plr = LegendPlayer(owner);
        if (plr) {
            plr.GiveHealth(amount,overheal);
        } else {
            owner.GiveBody(amount);
        }
    }

    bool IsOverArmor() {
        let plr = LegendPlayer(owner);
        if (plr) {
            let arm = LegendArmor(plr.FindInventory("LegendArmor"));
            if (arm) {
                return arm.amount >= plr.GetMaxHealth(true);
            } else {
                return false; // Player doesn't have armor?
            }
        } else {
            return false; // Monsters can't have armor, so they aren't over-armored.
        }
    }

    double GetOwnerLuck() {
        // Returns 0 or parent's luck. Monsters don't get lucky!
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetLuck();
        } else {
            return GetOwnerBase("Luck");
        }
    }

    bool LuckRoll(double chance, bool isBad = false) {
        // If the owner is a player, call their LuckRoll. Otherwise, raw random.
        if(isBad) {
            chance = chance * (1.0 + randomAdjust);
        } else {
            chance = chance * (1.0 - randomAdjust);
        }
        // Adding to randomAdjust is done manually.

        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.LuckRoll(chance,isBad);
        } else {
            return frandom(0,100) < chance;
        }
    }

    double RollDown(double initial) {
        // Essentially a copy of LegendPlayer's rolldown, but with our LuckRoll.
        double ret = 1.;
        while (initial > 100.) {
            ret += 1;
            initial -= 100.;
        }
        // The final roll.
        if (LuckRoll(initial)) {
            ret += 1;
        }
        return ret;
    }

    clearscope double GetOwnerBase(String stat) {
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetBaseStat(stat);
        } else {
            if (stat == "Power") {
                return 5.;
            } else {
                return 0.; // Monsters are not lucky, tough, or precise.
            }
        }
    }

    double GetOwnerPower(bool raw = false) {
        // Returns parent's power, or 5 plus 0.5 per level for monsters.
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetPower();
        } else {
            int lvl = owner.CountInv("LevelToken");
            double pow = GetOwnerBase("Power");
            if (!raw) {
                pow += 0.5 * lvl;
            }
            return pow;
        }
    }

    double GetOwnerPrecision() {
        // Returns 0 or parent's Precision. Monsters are not precise!
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetPrecision();
        } else {
            return GetOwnerBase("Precision");
        }
    }

    double GetOwnerToughness() {
        // Returns 0 or parent's Toughness. Monsters are not tough!
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetToughness();
        } else {
            return GetOwnerBase("Toughness");
        }
    }

    void SetTimer (double set = -1) {
        if(set < 0) {
            timer = timelimit;
        } else {
            timer = set;
        }
        self.alarmSet = true;
    }

    clearscope bool TimeUp () {
        return timer <= 0.;
    }

    override void DoEffect () {
        if (owner.bCORPSE) { return; }
        // Adjust the randomAdjust percentage.
        if (randomAdjust > 0) {
            randomAdjust = max(0,randomAdjust - (randomDecay * 1./35.));
        } else {
            randomAdjust = min(0,randomAdjust + (randomDecay * 1./35.));
        }

        timer -= 1./35.;

        if(alarmSet && timer <= 0.) {
            owner.A_StartSound(alarm,7);
            alarmSet = false;
            OnTimer();
        }
    }

    virtual clearscope string GetRemark () { return remark; }
    // A witty remark for the item.

    virtual clearscope string GetShortDesc () { return shortdesc; }
    // A short explanation of the item.

    virtual clearscope string GetLongDesc () { return "Not yet implemented!"; }
    // A longer, more detailed explanation of the item.

    virtual clearscope string, int GetItemInfo () { return "",Font.CR_WHITE; }
    // A bit of info to display on the item menu. Optionally, also a font color.

    virtual bool IconState () { return true; }
    // Return true if icon should be normal, or false if it should be dimmed.

    virtual void OnTimer () {} 
    // Called once whenever time is up.

    virtual void OnHit (int dmg, Name type, Actor src, Actor inf, Actor tgt) {} 
    // Called via event handler, WorldThingDamaged.

    virtual void OnRetaliate (int dmg, Name type, Actor src, Actor inf, Actor tgt) {} 
    virtual void OnRetaliateRaw (int dmg, Name type, Actor src, Actor inf, Actor tgt) {} 
    // Likewise, but when our owner is the thing behing hurt. OnRetaliateRaw is called before damage modifiers.

    virtual void OnKill (Actor src, Actor tgt) {} 
    // Called when owner (src) killed tgt.

    virtual void OnSmash (Actor src, Actor tgt) {} 
    // Called when src killed tgt, but tgt.bISMONSTER is false.

    virtual void OnCycle () {} 
    // Called whenever our weapon calls CycleProc.

    virtual void OnPrecisionHit () {} 
    // Called whenever a GetPower call causes a Precision Hit.

    virtual void PickupBonus (Inventory item) {} 
    // Called via HandlePickup for items that count as bonuses.

    virtual void PickupAmmo (Inventory item) {} 
    // Likewise but for ammo items.

    virtual void PickupHealth (Inventory item) {} 
    // ...and for medkits and stimpacks.

    virtual void PickupArmor (Inventory item) {} 
    // ...and armor...

    virtual void BreakArmor () {} 
    // Called when an enemy does damage to a player with no armor.

    virtual void OverArmorDamage (int dmg, Name type, Actor inf, Actor src, int flags) {}
    // Called when taking damage while over-armored.

    virtual double DamageMulti (int dmg, Name type, Actor inf, Actor src, int flags) { return 1.0; }
    // A multiplier to apply to outgoing damage.

    virtual double HurtMulti (int dmg, Name type, Actor inf, Actor src, int flags) { return 1.0; }
    // A multiplier to apply to incoming damage.

    virtual void OnStack() {}
    // Called whenever the item is stacked. This includes on first pickup.

    override bool HandlePickup(Inventory item) {
        // bool res = item.TryPickup(owner);
        bool res = ((item.bALWAYSPICKUP) ||
                    (owner.CountInv(item.GetClassName()) < item.MaxAmount) || 
                    ((item is "Ammo") && (owner.CountInv("BackpackItem") > 0) && (owner.CountInv(item.GetClassName()) < Ammo(item).BackpackAmount)));
        if (res) {
            if (item is "DummyHPBonus" || item is "ArmBonus" || item is "AmmoTiny") {
                PickupBonus(item);
            }

            if (item is "Health" || item is "HPBonus") { // This technically overlaps with PickupBonus and several powerups...oh well.
                PickupHealth(item); 
            }

            if (item is "LegendArmorGiver" || item is "ArmBonus") { // Likewise, this overlaps with armor bonuses.
                PickupArmor(item);
            }

            if (item is "Ammo") {
                PickupAmmo(item);
            }
        }

        return false;
    }

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inf, Actor src, int flags) {
        // We don't call OnHit and OnRetaliate here, because those should only be called AFTER all multipliers are applied.
        if (passive) {
            OnRetaliateRaw(dmg,type,src,inf,owner);
            new = dmg * HurtMulti(dmg,type,inf,src,flags);
        } else {
            new = dmg * DamageMulti(dmg,type,inf,src,flags);
        }
        if (passive && IsOverArmor()) {
            OverArmorDamage(dmg,type,inf,src,flags);
        }
    }

    override void AbsorbDamage (int dmg, Name type, out int newdamage) {
        let arm = LegendArmor(owner.FindInventory("LegendArmor"));
        if (arm && arm.Amount < 1) {
            BreakArmor();
        }
    }

    override void Touch (actor Toucher) {
        // Copied from Inventory, but altered to change stack count instead of its usual stuff.
        let player = toucher.player;

		// If a voodoo doll touches something, pretend the real player touched it instead.
		if (player != NULL)
		{
			toucher = player.mo;
		}

		bool localview = toucher.CheckLocalView();

		if (!toucher.CanTouchItem(self))
			return;

        // Instead of doing CallTryPickup right away...
        bool selfRemove = false;
        let it = LegendItem(toucher.FindInventory(GetClassName()));
        if (it) {
            // We might be doing stacks instead.
            it.stacks += 1;
            it.OnStack();
            selfRemove = true;
            let plr = LegendPlayer(toucher);
            if (plr) {
                plr.recentItems.push(it);
            }
        } else {
            bool res;
            [res, toucher] = CallTryPickup(toucher);
            let plr = LegendPlayer(toucher);
            if (plr) {
                plr.recentItems.push(self);
            }
            if (!res) return;
            OnStack();
        }

		// This is the only situation when a pickup flash should ever play.
		if (PickupFlash != NULL && !ShouldStay())
		{
			Spawn(PickupFlash, Pos, ALLOW_REPLACE);
		}

		if (!bQuiet)
		{
			PrintPickupMessage(localview, PickupMessage ());

			// Special check so voodoo dolls picking up items cause the
			// real player to make noise.
			if (player != NULL)
			{
				PlayPickupSound (player.mo);
				if (!bNoScreenFlash && player.playerstate != PST_DEAD)
				{
					player.bonuscount = BONUSADD;
				}
			}
			else
			{
				PlayPickupSound (toucher);
			}
		}							

		// [RH] Execute an attached special (if any)
		DoPickupSpecial (toucher);

		if (bCountItem)
		{
			if (player != NULL)
			{
				player.itemcount++;
			}
			level.found_items++;
		}

		if (bCountSecret)
		{
			Actor ac = player != NULL? Actor(player.mo) : toucher;
			ac.GiveSecret(true, true);
		}

		//Added by MC: Check if item taken was the roam destination of any bot
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (players[i].Bot != NULL && self == players[i].Bot.dest)
				players[i].Bot.dest = NULL;
		}

        if (selfRemove) {
            GoAwayAndDie(); // Gotta handle that ourselves.
        }
    }

    // And now, stat stuff.
    virtual clearscope double GetPower() { return 0; }
    virtual clearscope double GetPrecision() { return 0; }
    virtual clearscope double GetToughness() { return 0; }
    virtual clearscope double GetLuck() { return 0; }
    virtual clearscope double GetMultishot() { return 0; }
}

class ItemPassiveHandler : EventHandler {
    // Handles OnHit, OnRetaliate, and OnKill.

    double GetProc(Actor it) {
        if (it is "LegendShot") {
            let linf = LegendShot(it);
            return linf.proc;
        }

        if (it is "LegendFastShot") {
            let linf = LegendFastShot(it);
            return linf.proc;
        }

        // default to 1.
        return 1.0;
    }

    override void WorldThingDamaged(WorldEvent e) {
        // First call OnHit on any items in DamageSource's inventory.
        Inventory it;
        Actor realsrc;
        if (e.DamageSource && e.DamageSource.inv) { 
            realsrc = e.DamageSource;
        } else if (e.Inflictor && e.Inflictor.inv ) {
            realsrc = e.Inflictor;
        }

        if (realsrc && realsrc != e.Thing) { // Skip on-hits if the source is the target.
            if (realsrc.FindInventory("LegendItem",true)) {
                // Only do this if the source has any LegendItems!
                it = realsrc.inv;
                while (it) {
                    let lit = LegendItem(it);
                    if (lit) {
                        double dmg = it.ApplyDamageFactors(it.GetClassName(),e.DamageType,e.Damage,e.Damage);
                        double proc = GetProc(e.Inflictor);
                        dmg *= proc;
                        lit.OnHit(floor(dmg), e.DamageType, e.DamageSource, e.Inflictor, e.Thing);
                    }
                    it = it.inv;
                }
            }
        }
        // Next, do the same for the victim and OnRetaliate.
        if (e.Thing.FindInventory("LegendItem",true)) {
            it = null;
            if (e.Thing && e.Thing.inv) { it = e.Thing.inv; }
            while (it) {
                let lit = LegendItem(it);
                if (lit) {
                    int dmg = it.ApplyDamageFactors(it.GetClassName(),e.DamageType,e.Damage,e.Damage);
                    lit.OnRetaliate(dmg, e.DamageType, e.DamageSource, e.Inflictor, e.Thing);
                }
                it = it.inv;
            }
        }
    }

    override void WorldThingDied(WorldEvent e) {
        // Call OnKill on items in the killer's inventory.
        Inventory it;
        if (!e.Inflictor) { return; }
        if (e.inflictor.target && e.inflictor.target.inv) {
            it = e.inflictor.target.inv;
        } else if (e.inflictor.inv) {
            it = e.inflictor.inv; 
        }

        while (it) {
            let lit = legenditem(it);
            if (lit) {
                if (e.thing.bismonster) {
                    lit.onkill(e.inflictor.target, e.thing);
                } else {
                    lit.onsmash(e.inflictor.target,e.thing);
                }
            }
            it = it.inv;
        }
    }
}