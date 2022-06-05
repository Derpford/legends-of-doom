class MedicBag : LegendItem {
    // AAAAAAUUGH I'M DYYYYIIIIING
    default {
        Inventory.Icon "MBAGA0";
        Inventory.PickupMessage "Medic Bag: Enemies drop healing items on death.";
    }

    override void OnKill(Actor src, Actor tgt) {
        let it = tgt.Spawn("Stimpack",tgt.pos);
        if (it) {
            it.vel = (frandom(-2,2),frandom(-2,2),frandom(4,8));
        }
        for (int i = 0; i < GetStacks()-1; i++) {
            let it = tgt.Spawn("HPBonus",tgt.pos);
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