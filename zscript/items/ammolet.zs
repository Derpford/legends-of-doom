class Ammolet : LegendItem {
    double charge;
    default {
        LegendItem.Icon "AMLTD0";
        Tag "Ammolet";
        LegendItem.Desc "Picking up health occasionally spawns ammo.";
        LegendItem.Remark "Gungeon Souvenir";
        LegendItem.Rarity "COMMON UTILITY";
    }

    override void PickupHealth(Inventory it) {
        let lit = HPBonus(it);
        if (lit) {
            if (lit.heals < 0) {
                charge += GetStacks() * -lit.heals;
            } else {
                let plr = LegendPlayer(owner);
                if (plr) {
                    charge += GetStacks() * (lit.heals / plr.GetMaxHealth(true));
                }
            }
        } else {
            let plr = LegendPlayer(owner);
            if (plr) {
                charge += GetStacks() * (it.amount / plr.GetMaxHealth(true));
            }
        }

        while (charge >= 25) {
            let it = owner.Spawn("AmmoDrop",owner.pos);
            it.vel = (frandom(-3,3),frandom(-3,3),frandom(4,6));
            charge -= 25;
        }
    }
    
    states {
        Spawn:
            AMLT D -1;
            Stop;
    }
}

class LeakyBackpack : LegendItem {
    // It keeps falling out...
    default {
        LegendItem.Icon "LKBKA0";
        Tag "Leaky Backpack";
        LegendItem.Desc "Always pick up ammo, even if full. Ammo spawns XP.";
        LegendItem.Remark "Why cant I hold all this gun";
        LegendItem.Rarity "CURSED";
    }

    override void DoEffect() {
        super.DoEffect();
        Actor am;
        ThinkerIterator it = ThinkerIterator.Create("Ammo");
        while (am = Actor(it.next())) {
            if (owner.Vec3To(am).length()< owner.radius) {
                let it = Inventory(am);
                it.bALWAYSPICKUP = true;
            }
        }
    }

    override void PickupAmmo(Inventory item) {
        let xpg = XPGem(owner.Spawn("XPGem",owner.pos));
        if (xpg) {
            xpg.value = GetStacks() * 0.5;
        }
    }

    states {
        Spawn:
            LKBK A -1;
            Stop;
    }
}