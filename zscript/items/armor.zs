class ArmorCladFaith : LegendItem {
    // I'M A CLOWN OF FAAAAAAATE
    int count;
    default {
        Tag "Armor-Clad Faith";
        LegendItem.Desc "Picking up armor occasionally grants Ult Ammo.";
        LegendItem.Remark "I'm a fool, I know nothing";
        LegendItem.Icon "ARMIA0";
        LegendItem.Rarity "COMMON UTILITY DEFENSE";
    }

    override void PickupArmor (Inventory item) {
        double multi = RollDown(5 * GetStacks());
        int amt = item.amount;
        if (item is "BasicArmorPickup") { amt = BasicArmorPickup(item).SaveAmount; }
        count += amt * multi; 
        while (count >= 100) {
            count -= 100;
            owner.GiveInventory("PinkAmmo",1);
        }
    }

    states {
        Spawn:
            ARMI A -1;
            Stop;
    }
}

class BlackPowderPlate : LegendItem {
    // Who needs bandoliers?
    default {
        Tag "Black Powder Plate";
        LegendItem.Desc "Ammo and Armor Bonuses can spawn each other.";
        LegendItem.Remark "Shaped like infinity";
        LegendItem.Icon "ARMIB0";
        LegendItem.Rarity "EPIC";
    }

    override void PickupAmmo (Inventory item) {
        int amount = RollDown(20 * GetStacks()) - 1;
        for (int i = 0; i < amount; i++) {
            owner.Spawn("ArmBonus",owner.pos);
        }
    }

    override void PickupBonus (Inventory item) {
        if (item is "ArmBonus") {
            int amount = RollDown(10 + (10 * GetStacks())) - 1;
            for (int i = 0; i < amount; i++) {
                owner.Spawn("AmmoDrop",owner.pos);
            }
        }
    }

    states {
        Spawn:
            ARMI B -1;
            Stop;
    }
}

class PanicBootton : LegendItem {
    // Wizzardly.
    int power;
    default {
        Tag "Panic Bootton";
        LegendItem.Desc "Gain a burst of Luck when you take unarmored damage.";
        LegendItem.Remark "Property Of Wizzard";
        LegendItem.Icon "BOOTA0";
        LegendItem.Timer 1.;
    }

    override void OnTimer() {
        power = max(0,power - 1.);
        if (power > 0) {
            SetTimer();
        }
    }

    override void BreakArmor() {
        power = 10 + (10 * GetStacks());
        SetTimer();
    }

    override double GetLuck() {
        return power;
    }

    states {
        Spawn:
            BOOT A -1;
            Stop;
    }
}