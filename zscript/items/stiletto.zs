class Stiletto : LegendItem {
    double pow;
    default {
        LegendItem.Icon "SRDPA0";
        Tag "Stiletto";
        LegendItem.Desc "Precision Hits grant a stacking Haste buff.";
        LegendItem.Remark "Good hunting...";
        LegendItem.Rarity "RARE ATTACK";
        LegendItem.Timer 3.;
    }

    override double GetPrecision() {
        return 4.0;
    }

    override void OnPrecisionHit() {
        pow = min(pow + 1.,GetStacks());
        SetTimer();
    }

    override void OnTimer() {
        if (pow > 0) {
            pow = max(0,pow - 1.5);
            SetTimer();
        }
    }

    override double GetHaste() {
        return 5. * pow;
    }

    states {
        Spawn:
            SRDP A -1;
            Stop;
    }
}