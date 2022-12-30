class LifeChannelAmulet : LegendItem {
    // Cast from HP.
    default {
        LegendItem.Icon "AMLTC0";
        LegendItem.Timer 15.;
        Tag "Life-Channel Amulet";
        LegendItem.Desc "Gain 40% more Power, but occasionally suffer Bleeding.";
        LegendItem.Remark "Lightning bolt!";
        LegendItem.Rarity "CURSED";
    }

    override void OnTimer() {
        owner.GiveInventory("Bleed",GetStacks());
        SetTimer();
    }

    override double GetPower() {
        double p = GetOwnerBase("Power");
        return p * (0.4 * GetStacks());
    }

    states {
        Spawn:
            AMLT C -1;
            Stop;
    }
}