class BloodSaw : LegendItem {
    // Is that tomato sauce?
    default {
        Inventory.Icon "BSAWA0";
        Inventory.PickupMessage "Bloodsaw: Chance to inflict bleed on hit.";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        double chance = 10. + (5. * GetStacks());
        // console.printf("Bleed chance "..chance);
        double amt = RollDown(chance);
        if (amt > 1) {
            tgt.GiveInventory("Bleed",amt - 1);
        }
    }
}