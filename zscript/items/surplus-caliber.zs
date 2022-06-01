class SurplusCaliber : LegendItem {
    // *slaps roof of gun* this baby can fit so many bullet

    double power;

    default {
        Inventory.Icon "CRATA0";
        Inventory.PickupMessage "Surplus Caliber: On Reload, gain a power boost.";
        LegendItem.Timer 2.;
    }

    override void DoEffect() {
        // Timer starts ticking whenever power is > 0.
        if(power > 0) {
            if(TimeUp()) {
                SetTimer();
                power -= 3.0;
            }
        } else {
            SetTimer();
        }
        super.DoEffect();
    }

    override void OnReload() {
        power += 1. + (2. * owner.CountInv("SurplusCaliber"));
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