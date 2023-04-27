class LegendArmorGiver : Inventory {
    // Gives the player LegendArmor.
    double givepercent;
    Property Give : givepercent;
    default {
        LegendArmorGiver.Give 1.0;
        +DONTGIB;
    }

    override bool TryPickup(in out Actor toucher) {
        if (!amount && givepercent) {
            amount = toucher.GetMaxHealth(true) * givepercent;
        }
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
    // Armor absorbs damage based on how much armor you have compared to your max health.
    // At minimum, it absorbs 30% damage.
    // While armor is equal to or higher than your max health, you get 100% protection. (This means you're Over-Armored.)
    // Since proper armor pickups scale with HP, this means increasing your health also increases the amount of damage it takes to drop below Over-Armored.
    // It also means you chew through armor rapidly.
    // If you have armor higher than 2x your health, it ticks down, similarly to health.

    default {
        +Inventory.KEEPDEPLETED;
        Inventory.Amount 0; // We don't use Amount the normal way...
    }

    double GetProtection() {
        // if (amount > owner.GetMaxHealth(true)) {
        //     return .66;
        // } else {
        //     return .33;
        // }
        return clamp(double(amount) / double(owner.GetMaxHealth(true)),0.3,1);
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
            ARMG AB 5 Bright;
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
            ARMB AB 5 Bright;
            Loop;
    }
}