class Ammolet : LegendItem {
    // From the demesne formerly known as Gungeon.
    int charge;
    default {
        Inventory.Icon "AMLTD0";
        Inventory.PickupMessage "Ammolet: Picking up health occasionally spawns ammo.";
    }

    override void PickupHealth(Inventory it) {
        charge += it.amount * GetStacks();
        while (charge >= 25) {
            let it = owner.Spawn("AmmoSpawner",owner.pos);
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