Class StoneskinAmulet : LegendItem {
    // Not quite immortality.
    default {
        LegendItem.Icon "AMLTA0";
        LegendItem.Timer 0.5;
        Tag "Stoneskin Amulet";
        LegendItem.Desc "Consume armor for healing, even if your HP's full.";
        LegendItem.Remark "Not quite immortal.";
    }

    override void OnTimer() {
        let arm = owner.CountInv("BasicArmor");
        if (arm > 0) {
            owner.TakeInventory("BasicArmor",2*GetStacks());
            HealOwner(GetStacks());
        }
        SetTimer();
    }

    states {
        Spawn:
            AMLT A -1;
            Stop;
    }
}