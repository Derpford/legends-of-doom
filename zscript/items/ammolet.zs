class Ammolet : LegendItem {
    int charge;
    default {
        LegendItem.Icon "AMLTD0";
        Tag "Ammolet";
        LegendItem.Desc "Picking up health occasionally spawns ammo.";
        LegendItem.Remark "Gungeon Souvenir";
    }

    override void PickupHealth(Inventory it) {
        charge += it.amount * GetStacks();
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