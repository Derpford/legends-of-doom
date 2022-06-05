class MedicBag : LegendItem {
    // AAAAAAUUGH I'M DYYYYIIIIING
    default {
        Inventory.Icon "MBAGA0";
        Inventory.PickupMessage "Medic Bag: Enemies drop stimpacks on death.";
    }

    override void OnKill(Actor src, Actor tgt) {
        for (int i = 0; i < GetStacks(); i++) {
            let it = tgt.Spawn("Stimpack",tgt.pos);
            if (it) {
                it.vel = (frandom(-2,2),frandom(-2,2),frandom(4,8));
            }
        }
    }

    states {
        Spawn:
            MBAG A -1;
            Stop;
    }
}