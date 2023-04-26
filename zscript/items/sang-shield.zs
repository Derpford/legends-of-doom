class SanguineShield : LegendItem {
    // 'Til Death Do Us Part
    int stock;
    default {
        LegendItem.Icon "SHLDA0";
        Inventory.PickupMessage "Sanguine Shield: Absorb some incoming damage, creating armor.";
        LegendItem.Timer .25;
        Tag "Sanguine Shield";
        LegendItem.Desc "Absorb some incoming damage, creating armor.";
        LegendItem.Remark "Bargain-bin halo?";
        LegendItem.Rarity "COMMON DEFENSE HEALING";
    }

    override string GetLongDesc() {
        return "On taking health damage, store up to 25 (+25 per stack) damage as charge. Every .25 seconds, convert 1 (+1 per stack) charge to armor.";
    }

    override void OnRetaliate (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        stock = min(25 * GetStacks(),stock + dmg);
    }

    override void OnTimer() {
        SetTimer();
        if(stock > 0) {
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