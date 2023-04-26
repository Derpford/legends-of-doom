class ZSecGoggles : LegendItem {
    // Hey, these aren't my lensmaker's glasses!
    default {
        LegendItem.Icon "HGOGB0";
        Tag "Z-Sec Goggles";
        LegendItem.Desc "Gain 5% Haste.";
        LegendItem.Remark "These aren't my glasses...";
        LegendItem.Rarity "COMMON ATTACK";
    }

    override string GetLongDesc() {
        return "Gain 5 Haste (+5 per stack). Haste makes your weapon animations tick faster. 100 Haste reduces the length of each sprite frame by 1 tick, to a minimum of 1. Yes, this is very jank.";
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