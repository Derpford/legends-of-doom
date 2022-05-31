class SurplusCaliber : LegendItem {
    // *slaps roof of gun* this baby can fit so many bullet

    double power;
    double timer;

    default {
        Inventory.Icon "CRATA0";
        Inventory.PickupMessage "Surplus Caliber: On Reload, gain a power boost.";
    }

    override void DoEffect() {
        // Timer starts ticking whenever power is > 0.
        if(power > 0) {
            timer -= 1./35.; // One second per second.
            if(timer <= 0) {
                timer = 2.0;
                power -= 3.0;
            }
        } else {
            timer = 2.0; // Timer always starts at 2 seconds.
        }
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