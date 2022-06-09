class StrawberryJam : LegendItem {
    // Finally. Bosstonium.
    default {
        Inventory.Icon "JAMMA0";
        Scale 1.5;
        Tag "Strawberry Jam";
        LegendItem.Desc "Chance to jam enemies on hit.";
    }

    override void OnHit (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if (src == tgt) { return; }
        if (LuckRoll(5 + (5 * GetStacks()))) {
            tgt.GiveInventory("Jam",1); 
        }
    } 

    states {
        Spawn:
            JAMM A -1;
            Stop;
    }
}