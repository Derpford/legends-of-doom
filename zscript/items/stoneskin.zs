Class StoneskinAmulet : LegendItem {
    // Not quite immortality.
    default {
        Inventory.Icon "AMLTA0";
        Inventory.PickupMessage "Stoneskin Amulet: Consume armor for healing...whether you like it or not.";
        LegendItem.Timer 0.5;
    }

    override void OnTimer() {
        let arm = owner.CountInv("BasicArmor");
        if (arm > 0) {
            owner.TakeInventory("BasicArmor",2*GetStacks());
            owner.GiveBody(GetStacks());
        }
        SetTimer();
    }

    states {
        Spawn:
            AMLT A -1;
            Stop;
    }
}