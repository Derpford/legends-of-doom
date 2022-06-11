class SanguineShield : LegendItem {
    // 'Til Death Do Us Part
    int stock;
    default {
        Inventory.Icon "SHLDA0";
        Inventory.PickupMessage "Sanguine Shield: Absorb some incoming damage, creating armor.";
        LegendItem.Timer .25;
        Tag "Sanguine Shield";
        LegendItem.Desc "Absorb some incoming damage, creating armor.";
        LegendItem.Remark "Bargain-bin halo?";
    }

    override void OnRetaliate (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        stock = min(25 * GetStacks(),stock + dmg);
    }

    override void OnTimer() {
        SetTimer();
        if(stock > 0 && owner.CountInv("BasicArmor") < 200) {
            stock -= GetStacks();
            owner.GiveInventory("ArmorBonus",GetStacks());
        }
    }

    states {
        Spawn:
            SHLD A -1;
            Stop;
    }
}