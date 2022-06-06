class LifeChannelAmulet : LegendItem {
    // Cast from HP.
    default {
        Inventory.Icon "AMLTC0";
        Inventory.PickupMessage "Life-Channel Amulet: Gain incredible Power, but occasionally suffer Bleeding.";
        LegendItem.Timer 15.;
    }

    override void OnTimer() {
        owner.GiveInventory("Bleed",GetStacks());
    }

    override double GetPower() {
        return 10. + (10. * GetStacks());
    }

    states {
        Spawn:
            AMLT C -1;
            Stop;
    }
}