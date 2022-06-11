class LuckyCoin : LegendItem {
    // Ooh, a potion!
    bool active;

    default {
        Inventory.Icon "COINA0";
        LegendItem.Timer 5.;
        Tag "Lucky Coin";
        LegendItem.Desc "Picking up bonuses makes you lucky.";
        LegendItem.Remark "Ooh, a potion!";
    }

    override void PickupBonus(Inventory item) {
        // Picking up a bonus item grants +25 luck for 5s per stack.
        active = true;
        SetTimer(timelimit * GetStacks());
    }

    override void OnTimer() {
        active = false;
    }

    override double GetLuck() {
        if (active) { return 10.; } else { return 0.; }
    }

    states {
        Spawn:
            COIN A -1;
            Stop;
    }
}