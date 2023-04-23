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