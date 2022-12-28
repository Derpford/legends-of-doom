class SurplusCaliber : LegendItem {
    // *slaps roof of gun* this baby can fit so many bullet

    double power;

    default {
        LegendItem.Icon "CRATA0";
        LegendItem.Timer 1.;
        Tag "Surplus Caliber";
        LegendItem.Desc "When your weapon Cycles, gain a power boost.";
        LegendItem.Remark "*slaps roof of gun*";
        LegendItem.Rarity "RARE ATTACK";
    }

    override void DoEffect() {
        // Timer starts ticking whenever power is > 0.
        if(power > 0) {
            if(TimeUp()) {
                SetTimer();
                power = max(0,power - .50);
            }
        } else {
            SetTimer();
        }
        super.DoEffect();
    }

    override void OnReload() {
        power = min(power+1,GetStacks()*5);
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