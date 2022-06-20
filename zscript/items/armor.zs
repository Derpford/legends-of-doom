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