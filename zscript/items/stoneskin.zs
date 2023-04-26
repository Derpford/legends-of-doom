Class StoneskinAmulet : LegendItem {
    // Not quite immortality.
    default {
        LegendItem.Icon "AMLTA0";
        LegendItem.Timer 0.5;
        Tag "Stoneskin Amulet";
        LegendItem.Desc "Consume armor for healing.";
        LegendItem.Remark "Not quite immortal.";
        LegendItem.Rarity "CURSED";
    }

    override string GetLongDesc() {
        return "Every 0.5 seconds, consume 2 (+2 per stack) armor to heal 1 (+1 per stack) health. This effect can overheal.";
    }

    override void OnTimer() {
        let arm = owner.CountInv("LegendArmor");
        if (arm > 0) {
            owner.TakeInventory("LegendArmor",2*GetStacks());
            HealOwner(GetStacks(),true);
        }
        SetTimer();
    }

    states {
        Spawn:
            AMLT A -1;
            Stop;
    }
}