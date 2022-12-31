class SmallHealth : HPBonus replaces Stimpack {
    // A small health pickup that heals 10% of your max health.
    default {
        HPBonus.heal -10;
        HPBonus.overheal false;
        HPBonus.DontSuck true;
        -INVENTORY.ALWAYSPICKUP;
        Inventory.PickupMessage "Grabbed a small health pack!";
    }

    states {
        Spawn:
            HPAK A -1;
            Stop;
    }
}

class LargeHealth : SmallHealth replaces Medikit {
    default {
        HPBonus.heal -25;
        Inventory.PickupMessage "Grabbed a large health pack!";
    }

    states {
        Spawn:
            HPAK B -1;
            Stop;
    }
}