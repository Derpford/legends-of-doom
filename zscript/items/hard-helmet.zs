class HardHelmet : LegendItem {
    // OSHA-compliant.

    default {
        Scale 1.5;
        LegendItem.Icon "BON2A0";
        Tag "Hard Helmet";
        LegendItem.Desc "Being healthy grants Toughness.";
        LegendItem.Remark "OSHA-compliant.";
        LegendItem.Rarity "EPIC";
    }

    override double GetToughness () {
        // Gives 25 toughness per stack at full health. Less health = less toughness.
        int stacks = GetStacks();
        double hpercent = double(owner.health) / double(owner.GetMaxHealth(true));

        return 25. * stacks * hpercent;
    }

    states {
        Spawn:
            BON2 ABCB 3;
            Loop;
    }
}