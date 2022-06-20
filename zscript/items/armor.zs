class ArmorCladFaith : LegendItem {
    // I'M A CLOWN OF FAAAAAAATE
    default {
        Tag "Armor-Clad Faith";
        LegendItem.Desc "Picking up armor rarely grants Ult Ammo.";
        LegendItem.Remark "I'm a fool, I know nothing";
        LegendItem.Icon "ARMIA0";
    }

    override void PickupArmor (Inventory item) {
        int amount = RollDown(5 * GetStacks()) - 1;
        if (amount > 0) {
            owner.GiveInventory("PinkAmmo",amount);
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
            int amount = RollDown(20 * GetStacks()) - 1;
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
        LegendItem.Desc "Gain a burst of Luck when your armor breaks.";
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
        power = 10 + (5 * GetStacks());
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