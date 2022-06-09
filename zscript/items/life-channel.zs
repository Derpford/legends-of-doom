class LifeChannelAmulet : LegendItem {
    // Cast from HP.
    default {
        Inventory.Icon "AMLTC0";
        LegendItem.Timer 15.;
        Tag "Life-Channel Amulet";
        LegendItem.Desc "Gain Power, but occasionally suffer Bleeding.";
    }

    override void OnTimer() {
        owner.GiveInventory("Bleed",GetStacks());
        SetTimer();
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