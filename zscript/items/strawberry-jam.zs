class StrawberryJam : LegendItem {
    // Finally. Bosstonium.
    default {
        LegendItem.Icon "JAMMA0";
        Scale 1.5;
        Tag "Strawberry Jam";
        LegendItem.Desc "Chance to jam enemies on hit.";
        LegendItem.Remark "Finally...Bosstonium.";
        LegendItem.Rarity "RARE ATTACK UTILITY";
    }

    override string GetLongDesc() {
        return "On-hit, gain a 5% (+5% per stack) chance to afflict the target with Jammed, forcing them into their pain state if they attempt to attack.";
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