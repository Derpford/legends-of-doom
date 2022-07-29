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
        Height 36;
        +DONTTHRUST;
        +SHOOTABLE; // Not a monster!
        +NOBLOOD;
        +BRIGHT;
        ItemCrate.Tiers ""; // Empty list means any items.
        ItemCrate.Weight 100; // For the sake of convenience when defining new crate types.
    }

    void SpawnItem () {
        SpawnHandler = ItemSpawnHandler(StaticEventHandler.Find("ItemSpawnHandler"));
        if (SpawnHandler) {
            let t = SpawnHandler.SelectRarity(tierlist);
            let i = SpawnHandler.SelectItem(t);
            let it = Spawn(i, pos);
            if (it) {
                it.vel = (frandom(-1,1),frandom(-1,1),8);
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

class BigCrate : ItemCrate {
    // A crate that contains a guaranteed Rare or Epic item.
    default {
        ItemCrate.Tiers "RARE EPIC";
        ItemCrate.Weight 30;
    }

    states {
        Spawn:
            IBOX B -1;
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

class HealCrate : ItemCrate {
    // A crate guaranteed to contain a healing item.
    default {
        ItemCrate.Tiers "HEALING";
        ItemCrate.Weight 30;
    }

    states {
        Spawn:
            ISUP A -1;
            Stop;
    }
}

class AttackCrate : ItemCrate {
    // A crate guaranteed to contain a damage item.
    default {
        ItemCrate.Tiers "ATTACK";
        ItemCrate.Weight 30;
    }

    states {
        Spawn:
            IATK A -1;
            Stop;
    }
}

class UtilCrate : ItemCrate {
    // A crate guaranteed to contain a crowd control or economy item.
    default {
        ItemCrate.Tiers "UTILITY";
        ItemCrate.Weight 30;
    }

    states {
        Spawn:
            IUTL A -1;
            Stop;
    }
}

class DefenseCrate : ItemCrate {
    // A crate guaranteed to contain a defensive item.
    default {
        ItemCrate.Tiers "DEFENSE";
        ItemCrate.Weight 30;
    }

    states {
        Spawn:
            IDEF A -1;
            Stop;
    }
}