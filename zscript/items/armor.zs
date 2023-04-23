class ArmorCladFaith : LegendItem {
    // I'M A CLOWN OF FAAAAAAATE
    double count;
    default {
        Tag "Armor-Clad Faith";
        LegendItem.Desc "Picking up armor occasionally grants Ult Ammo.";
        LegendItem.Remark "I'm a fool, I know nothing";
        LegendItem.Icon "ARMIA0";
        LegendItem.Rarity "COMMON UTILITY DEFENSE";
    }

    override void PickupArmor (Inventory item) {
        double multi = GetStacks() * 0.5;
        double amt = 0;
        if (item is "LegendArmorGiver") { 
            amt = LegendArmorGiver(item).givepercent; 
        }
        count += amt * multi; 
        while (count >= 1) {
            count -= 1;
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
        LegendItem.Rarity "EPIC DEFENSE UTILITY";
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
        LegendItem.Rarity "COMMON UTILITY";
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

class MollePlate : LegendItem {
    // Real generals study logistics.
    int charge;
    default {
        Tag "MOLLE Plate";
        LegendItem.Desc "While Over-Armored, blocked damage periodically spawns ammo bonuses.";
        LegendItem.Remark "Do U Even Operate Bro";
        LegendItem.Icon "MOLLA0";
        LegendItem.Rarity "COMMON UTILITY";
    }

    override void OverArmorDamage (int dmg, Name type, Actor inf, Actor src, int flags) {
        charge += dmg * GetStacks();
    }

    clearscope double ChargeCap() {
        return owner.GetMaxHealth(true) * 0.5;
    }

    override void DoEffect() {
        double hpfrac = ChargeCap();
        if (charge > hpfrac) {
            charge -= hpfrac;
            owner.Spawn("AmmoTiny",owner.pos);
        }
    }

    override string, int GetItemInfo() {
        double hpfrac = ChargeCap();
        double perc = charge / hpfrac;
        perc *= 100.0;
        return String.format("%0.1f%%",perc), Font.CR_WHITE;
    }

    states {
        Spawn:
            MOLL A -1;
            Stop;
    }
}