class LegendItem : Inventory {
    // A class that contains a bunch of handy functions and overrides for handling procs.

    double timer;
    double timelimit;
    int stacks; // Fixes repeated proccing of items with multiple copies. Also means we don't need to care about MaxAmount.
    Property TimerStart : timer;
    Property Timer : timelimit;

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        LegendItem.TimerStart 0;
        LegendItem.Timer 0; // Timer must be set to be used correctly!
    }

    clearscope int GetStacks() {
        return stacks;
    }

    clearscope double GetOwnerLuck() {
        // Returns 0 or parent's luck. Monsters don't get lucky!
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetLuck();
        } else {
            return 0.;
        }
    }

    clearscope bool LuckRoll(double chance, bool isBad = false) {
        // If the owner is a player, call their LuckRoll. Otherwise, raw random.
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.LuckRoll(chance,isBad);
        } else {
            return frandom(0,100) < chance;
        }
    }

    clearscope double RollDown(double initial) {
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

    clearscope double GetOwnerPower(bool raw = false) {
        // Returns parent's power, or 5 plus 0.5 per level for monsters.
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetPower(raw);
        } else {
            int lvl = owner.CountInv("LevelToken");
            double pow = 5.;
            if (raw) {
                pow += 0.5 * lvl;
            }
            return pow;
        }
    }

    clearscope double GetOwnerPrecision() {
        // Returns 0 or parent's Precision. Monsters are not precise!
        if (owner is "LegendPlayer") {
            let plr = LegendPlayer(owner);
            return plr.GetPrecision();
        } else {
            return 0.;
        }
    }

    clearscope double GetOwnerToughness() {
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
    }

    bool TimeUp () {
        return timer <= 0.;
    }

    override void DoEffect () {
        timer -= 1./35.;
    }

    virtual void OnHit (int dmg, Name type, Actor src, Actor inf, Actor tgt) {} // Called via event handler, WorldThingDamaged.

    virtual void OnRetaliate (int dmg, Name type, Actor src, Actor inf, Actor tgt) {} // Likewise, but when our owner is the thing behing hurt.

    virtual void OnKill (Actor src, Actor tgt) {} // Called when owner (src) killed tgt.

    virtual void OnReload () {} // Called whenever our weapon calls ReloadProc.

    virtual void PickupBonus () {} // Called via HandlePickup for items that count as bonuses.

    virtual void PickupAmmo () {} // Likewise but for ammo items.

    virtual void PickupHealth () {} // ...and for medkits and stimpacks.

    virtual void PickupArmor () {} // ...and armor...

    virtual void BreakArmor (Actor src) {} // Called when an enemy breaks our armor (reduces Armor to 0).

    override bool HandlePickup(Inventory item) {
        if (item is "HPBonus" || item is "BasicArmorBonus") {
            PickupBonus();
        }

        if (item is "Health" || item is "HPBonus") { // This technically overlaps with PickupBonus and several powerups...oh well.
            PickupHealth(); 
        }

        if (item is "Armor") { // Likewise, this overlaps with armor bonuses.
            PickupArmor();
        }

        if (item is "Ammo") {
            PickupAmmo();
        }

        // Finally, handle increasing our stack count.
        if (item is self.GetClassName()) {
            stacks += 1;
            item.GoAwayAndDie();
            return true;
        } else {
            return false;
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

class HPBonus : Inventory replaces HealthBonus {
    // Adds 1 to health. Does *NOT* respect max health (or any maximum!).

    int heals;
    Property Heal : heals;

    default {
        HPBonus.Heal 1;
        Inventory.PickupMessage "Health bonus!";
    }

    override void AttachToOwner (Actor other) {
        other.GiveBody(heals,int.max);
        GoAwayAndDie();
    }

    states {
        Spawn:
            BON1 ABCDCB 5;
            Loop;
    }
}

class SuperSoul : HPBonus replaces Soulsphere {
    // The soulsphere, but without a maximum!

    default {
        HPBonus.Heal 100;
        Inventory.PickupMessage "Super Soul!";
    }

    states {
        Spawn:
            SOUL ABCDCB 6 Bright;
    }
}

class MegaSoul : HPBonus replaces Megasphere {
    // The megasphere, but without a (health) maximum!
    default {
        HPBonus.Heal 200;
        Inventory.PickupMessage "Mega Soul!";
    }

    override void AttachToOwner (Actor other) {
        other.GiveInventory("BlueArmor",1);
        super.AttachToOwner(other);
    }

    states {
        Spawn:
            MEGA ABCD 6 Bright;
    }
}