class LegendItem : Inventory {
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

    string remark; // the witty joke
    string shortdesc; // the short explanation
    Property Remark : remark;
    Property Desc : shortdesc;

    default {
        +BRIGHT; // Items should always be visible.
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
        LegendItem.TimerStart 0;
        LegendItem.Timer 0; // Timer must be set to be used correctly!
        LegendItem.StartStacks 1;
        LegendItem.Alarm "dsempty", 1.0;
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

    double GetOwnerLuck() {
        // Returns 0 or parent's luck. Monsters don't get lucky!
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetLuck();
        } else {
            return 0.;
        }
    }

    bool LuckRoll(double chance, bool isBad = false) {
        // If the owner is a player, call their LuckRoll. Otherwise, raw random.
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

    double GetOwnerPower(bool raw = false) {
        // Returns parent's power, or 5 plus 0.5 per level for monsters.
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetPower();
        } else {
            int lvl = owner.CountInv("LevelToken");
            double pow = 5.;
            if (raw) {
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
            return 0.;
        }
    }

    double GetOwnerToughness() {
        // Returns 0 or parent's Toughness. Monsters are not tough!
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetToughness();
        } else {
            return 0.;
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

    bool TimeUp () {
        return timer <= 0.;
    }

    override void DoEffect () {
        if (owner.bCORPSE) { return; }
        timer -= 1./35.;
        if(alarmSet && timer <= 0.) {
            owner.A_StartSound(alarm,7);
            alarmSet = false;
            OnTimer();
        }
    }

    virtual string GetRemark () { return remark; }
    // A witty remark for the item.

    virtual string GetShortDesc () { return shortdesc; }
    // A short explanation of the item.

    virtual string GetLongDesc () { return "Not yet implemented!"; }
    // A longer, more detailed explanation of the item.

    virtual bool IconState () { return true; }
    // Return true if icon should be normal, or false if it should be dimmed.

    virtual void OnTimer () {} 
    // Called once whenever time is up.

    virtual void OnHit (int dmg, Name type, Actor src, Actor inf, Actor tgt) {} 
    // Called via event handler, WorldThingDamaged.

    virtual void OnRetaliate (int dmg, Name type, Actor src, Actor inf, Actor tgt) {} 
    // Likewise, but when our owner is the thing behing hurt.

    virtual void OnKill (Actor src, Actor tgt) {} 
    // Called when owner (src) killed tgt.

    virtual void OnReload () {} 
    // Called whenever our weapon calls ReloadProc.

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

    virtual void BreakArmor (Actor src) {} 
    // Called when an enemy breaks our armor (reduces Armor to 0).

    override bool HandlePickup(Inventory item) {
        if (item is "HPBonus" || item is "BasicArmorBonus") {
            PickupBonus(item);
        }

        if (item is "Health" || item is "HPBonus") { // This technically overlaps with PickupBonus and several powerups...oh well.
            PickupHealth(item); 
        }

        if (item is "Armor") { // Likewise, this overlaps with armor bonuses.
            PickupArmor(item);
        }

        if (item is "Ammo") {
            PickupAmmo(item);
        }

        return false;
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
            selfRemove = true;
        } else {
            bool res;
            [res, toucher] = CallTryPickup(toucher);
            if (!res) return;
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
}

class ItemPassiveHandler : EventHandler {
    // Handles OnHit, OnRetaliate, and OnKill.

    override void WorldThingDamaged(WorldEvent e) {
        // First call OnHit on any items in DamageSource's inventory.
        Inventory it;
        if (e.DamageSource && e.DamageSource.inv) { 
            it = e.DamageSource.inv; 
        } else if (e.Inflictor && e.Inflictor.inv ) {
            it = e.Inflictor.inv; 
        }
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                lit.OnHit(e.Damage, e.DamageType, e.DamageSource, e.Inflictor, e.Thing);
            }
            it = it.inv;
        }
        // Next, do the same for the victim and OnRetaliate.
        it = null;
        if (e.Thing && e.Thing.inv) { it = e.Thing.inv; }
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                lit.OnRetaliate(e.Damage, e.DamageType, e.DamageSource, e.Inflictor, e.Thing);
            }
            it = it.inv;
        }
    }

    override void WorldThingDied(WorldEvent e) {
        // Call OnKill on items in the killer's inventory.
        if (e.Inflictor && e.Inflictor.target && e.Inflictor.target.inv) {
            Inventory it = e.Inflictor.target.inv;
            while (it) {
                let lit = LegendItem(it);
                if (lit) {
                    lit.OnKill(e.Inflictor.target, e.Thing);
                }
                it = it.inv;
            }
        }
    }
}

class BonusDrop : Actor {
    // Spawns either an HPBonus or an ArmorBonus.

    states {
        Spawn:
            TNT1 A 0;
            TNT1 A 0 {
                Name bon;
                if(frandom(0,1)>0.5) {
                    bon = "HPBonus"; 
                } else {
                    bon = "ArmBonus";
                }
                let it = Spawn(bon,pos);
                if (it) {
                    it.vel = (frandom(-4,4), frandom(-4,4), frandom(6,12));
                }
            }
            Stop;
    }
}

class HPBonus : Inventory replaces HealthBonus {
    // Adds 1 to health. Does *NOT* respect max health (or any maximum!).

    mixin PlayerVac;
    override void Tick() {
        Super.Tick();
        Suck();
    }

    int heals;
    Property Heal : heals;
    bool overheal;
    Property Overheal : overheal;

    default {
        HPBonus.Heal 1;
        HPBonus.Overheal true;
        Inventory.PickupMessage "Health bonus!";
    }

    override void AttachToOwner (Actor other) {
        if(overheal) {
            other.GiveBody(heals,int.max);
        } else {
            other.GiveBody(heals,other.GetMaxHealth(true));
        }
        GoAwayAndDie();
    }

    states {
        Spawn:
            BON1 ABCDCB 5;
            Loop;
    }
}

class ArmBonus: ArmorBonus replaces ArmorBonus {
    // Just the old ArmorBonus, plus succ.
    mixin PlayerVac;
    override void Tick() {
        Super.Tick();
        Suck();
    }
}

class SuperSoul : HPBonus replaces Soulsphere {
    // The soulsphere, but without a maximum!

    default {
        HPBonus.Heal 100;
        HPBonus.dontSuck true;
        Inventory.PickupMessage "Super Soul!";
    }

    states {
        Spawn:
            SOUL ABCDCB 6 Bright;
    }
}

class MegaSoul : SuperSoul replaces Megasphere {
    // The megasphere, but without a (health) maximum!
    default {
        HPBonus.Heal 200;
        HPBonus.dontSuck true;
        Inventory.PickupMessage "Mega Soul!";
    }

    override void AttachToOwner (Actor other) {
        other.GiveInventory("BlueArmor",1);
        other.GiveBody(heals,int.max);
    }

    states {
        Spawn:
            MEGA ABCD 6 Bright;
    }
}