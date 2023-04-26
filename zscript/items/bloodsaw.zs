class BloodSaw : LegendItem {
    // Is that tomato sauce?
    default {
        LegendItem.Icon "BSAWA0";
        Tag "Bloodsaw";
        LegendItem.Desc "Chance to inflict bleed on hit.";
        LegendItem.Remark "Is that tomato sauce?";
        LegendItem.Rarity "COMMON ATTACK";
    }
    
    override string GetLongDesc() {
        return "On-hit, 15% (+5% per stack) chance to inflict bleed on the target. Each stack of bleed deals 2 damage every half-second.";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if (!src || src == tgt || type == "Bleeding") { return; }
        // Don't stab yourself! Also, bleeding cannot cause bleeding.
        double chance = 10. + (5. * GetStacks());
        // console.printf("Bleed chance "..chance);
        double amt = RollDown(chance);
        if (amt > 1) {
            tgt.GiveInventory("Bleed",amt - 1);
        }
    }

    states {
        Spawn:
            BSAW A -1;
            Stop;
    }
}