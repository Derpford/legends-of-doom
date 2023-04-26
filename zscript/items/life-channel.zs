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

    override string GetLongDesc() {
        return "Gain Power equal to 40% (+40% per stack) of your base Power, but suffer 1 (+1 per stack) stack of bleed every 15 seconds.";
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