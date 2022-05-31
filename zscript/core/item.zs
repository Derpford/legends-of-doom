class LegendItem : Inventory {
    // A class that contains a bunch of handy functions and overrides for handling procs.

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
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
        if (item is "HealthBonus" || item is "BasicArmorBonus") {
            PickupBonus();
        }

        if (item is "Health") { // This technically overlaps with PickupBonus and several powerups...oh well.
            PickupHealth(); 
        }

        if (item is "Armor") {
            PickupArmor();
        }

        return false;
    }
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
        if (e.Inflictor && e.Inflictor.inv) {
            Inventory it = e.Inflictor.inv;
            while (it) {
                let lit = LegendItem(it);
                if (lit) {
                    lit.OnKill(e.Inflictor, e.Thing);
                }
                it = it.inv;
            }
        }
    }
}