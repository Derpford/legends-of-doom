class ZSecGoggles : LegendItem {
    // Hey, these aren't my lensmaker's glasses!
    default {
        LegendItem.Icon "HGOGB0";
        Tag "Z-Sec Goggles";
        LegendItem.Desc "Gain 5% Multishot.";
        LegendItem.Remark "These aren't my glasses...";
        LegendItem.Rarity "COMMON ATTACK";
    }

    override string GetLongDesc() {
        return "Gain 5% Multishot (+5 per stack). Multishot gives each projectile a chance to duplicate itself.";
    }

    override double GetMultishot() {
        return 5. * GetStacks();
    }

    states {
        Spawn:
            HGOG A 4;
            HGOG B 4 Bright;
            Loop;
    }
}