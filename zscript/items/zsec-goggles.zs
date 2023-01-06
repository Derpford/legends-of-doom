class ZSecGoggles : LegendItem {
    // Hey, these aren't my lensmaker's glasses!
    default {
        LegendItem.Icon "HGOGB0";
        Tag "Z-Sec Goggles";
        LegendItem.Desc "Gain 5% Haste.";
        LegendItem.Remark "These aren't my glasses...";
        LegendItem.Rarity "COMMON ATTACK";
    }

    override double GetHaste() {
        return 5. * GetStacks();
    }

    states {
        Spawn:
            HGOG A 4;
            HGOG B 4 Bright;
            Loop;
    }
}