class ItemCrate : Actor {
    // An item crate that holds a single item.
    // Must be shot to open.

    string tierlist; // What tiers is this box permitted to spawn?
    Property Tiers : tierlist;

    double weight; // Weight for random selection.
    Property Weight : weight;

    ItemSpawnHandler SpawnHandler;

    default {
        Health 100;
        +SHOOTABLE; // Not a monster!
        ItemCrate.Tiers ""; // Empty list means any items.
        ItemCrate.Weight 100; // For the sake of convenience when defining new crate types.
    }

    void SpawnItem () {
        SpawnHandler = ItemSpawnHandler(StaticEventHandler.Find("ItemSpawnHandler"));
        if (SpawnHandler) {
            console.printf("Spawning an item...");
            let t = SpawnHandler.SelectRarity(tierlist);
            let i = SpawnHandler.SelectItem(t);
            console.printf("Selected "..i);
            let it = Spawn(i, pos);
            if (it) {
                it.vel = (frandom(-2,2),frandom(-2,2),12);
            }
        }
    }

    states {
        Spawn:
            IBOX A -1;
            Stop;
        Death:
            BEXP BC 3 Bright; // TODO: Spawn item
            TNT1 A 0 SpawnItem();
            TNT1 A -1;
            Stop;
    }
}

class CursedCrate : ItemCrate {
    // A crate that only contains cursed items!
    default {
        ItemCrate.Tiers "CURSED";
        ItemCrate.Weight 20;
    }

    states {
        Spawn:
            IBOX C -1;
            Stop;
    }
}