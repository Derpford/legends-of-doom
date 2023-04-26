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

    override string GetLongDesc() {
        return "Gain +4 Precision. On Precision Hit, gain 5 (+5 per stack) Haste. Stacks up to 1 (+1 per stack) times. This buff decays by 7.5 (+7.5 per stack) every 3 seconds.";
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