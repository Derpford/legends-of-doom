class HardHelmet : LegendItem {
    // OSHA-compliant.

    default {
        Scale 2;
        Inventory.PickupMessage "Hard Helmet: Being healthy grants Toughness.";
        Inventory.Icon "BON2A0";
    }

    override double GetToughness () {
        // Gives 25 toughness per stack at full health. Less health = less toughness.
        int stacks = CountInv("HardHelmet");
        double hpercent = double(owner.health) / double(owner.GetMaxHealth());

        return 25. * stacks * hpercent;
    }

    states {
        Spawn:
            BON2 ABCB 3;
            Loop;
    }
}