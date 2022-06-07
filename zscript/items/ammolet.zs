class Ammolet : LegendItem {
    // From the demesne formerly known as Gungeon.
    default {
        Inventory.Icon "AMLTD0";
        Inventory.PickupMessage "Ammolet: Health pickups can spawn ammo.";
    }

    override void PickupHealth() {
        int amt = RollDown(25 + (25 * GetStacks())) -1;
        for (int i = 0; i < amt; i++) {
            let it = owner.Spawn("AmmoSpawner",owner.pos);
            it.vel = (frandom(-3,3),frandom(-3,3),frandom(4,6));
        }
    }
    
    states {
        Spawn:
            AMLT D -1;
            Stop;
    }
}