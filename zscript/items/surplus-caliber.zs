class SurplusCaliber : LegendItem {
    // *slaps roof of gun* this baby can fit so many bullet

    double power;

    default {
        LegendItem.Icon "CRATA0";
        LegendItem.Timer 1.;
        Tag "Surplus Caliber";
        LegendItem.Desc "On Reload, gain a power boost.";
        LegendItem.Remark "*slaps roof of gun*";
    }

    override void DoEffect() {
        // Timer starts ticking whenever power is > 0.
        if(power > 0) {
            if(TimeUp()) {
                SetTimer();
                power = max(0,power - (1.5 + GetStacks()));
            }
        } else {
            SetTimer();
        }
        super.DoEffect();
    }

    override void OnReload() {
        power += 1. + (2. * GetStacks());
    }

    override double GetPower() {
        // On reload: gain a stacking power boost.
        return power;
    }

    states {
        Spawn:
            CRAT A -1;
            Stop;
    }
}