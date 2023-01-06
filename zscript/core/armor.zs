class LegendArmorGiver : Inventory {
    // Gives the player LegendArmor.
    double givepercent;
    Property Give : givepercent;
    default {
        LegendArmorGiver.Give 1.0;
    }

    override bool TryPickup(in out Actor toucher) {
        amount = toucher.GetMaxHealth(true) * givepercent;
        LegendArmor it = LegendArmor(toucher.FindInventory("LegendArmor"));
        if (it) {
            it.amount += amount;
        } else {
            toucher.GiveInventory("LegendArmor",1);
            it = LegendArmor(toucher.FindInventory("LegendArmor"));
            it.amount = amount;
        }
        GoAwayAndDie();
        return true; // Can always be picked up!
    }
}
class LegendArmor : Inventory {
    // Handles armor!
    // Armor normally absorbs ~33% of incoming damage.
    // However, while the armor total is above your max health value, the protection rate increases to ~66%.
    // If you have armor higher than 2x your health, it ticks down, similarly to health.

    default {
        +Inventory.KEEPDEPLETED;
        Inventory.Amount 0; // We don't use Amount the normal way...
    }

    double GetProtection() {
        if (amount > owner.GetMaxHealth(true)) {
            return .66;
        } else {
            return .33;
        }
    }

    override void AbsorbDamage(int damage, Name damageType, out int newdamage, Actor inflictor, Actor source, int flags) {
        int protect = damage * GetProtection();
        protect = min(protect,amount);
        owner.TakeInventory("LegendArmor",protect);
        newdamage = damage - protect;
    }
}

class LegendGreenArmor : LegendArmorGiver replaces GreenArmor {
    default {
        LegendArmorGiver.Give 0.75;
        Inventory.PickupMessage "Light Armor!";
    } 

    states {
        Spawn:
            ARM1 AB 5 Bright;
            Loop;
    }
}

class LegendBlueArmor : LegendArmorGiver replaces BlueArmor {
    default {
        LegendArmorGiver.Give 1.5;
        Inventory.PickupMessage "Heavy Armor!";
    }

    states {
        Spawn:
            ARM2 AB 5 Bright;
            Loop;
    }
}