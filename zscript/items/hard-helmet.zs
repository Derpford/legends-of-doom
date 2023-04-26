class HardHelmet : LegendItem {
    // OSHA-compliant.

    default {
        Scale 1.5;
        LegendItem.Icon "BON2A0";
        Tag "Hard Helmet";
        LegendItem.Desc "Being healthy grants Toughness.";
        LegendItem.Remark "OSHA-compliant.";
        LegendItem.Rarity "EPIC DEFENSE";
    }

    override string GetLongDesc() {
        return "Gain 25 (+25 per stack) Toughness when at full health. Grants less toughness when below full health, based on HP percentage. Being above full health grants more Toughness, up to 50 (+50 per stack).";
    }

    override double GetToughness () {
        // Gives 25 toughness per stack at full health. Less health = less toughness.
        int stacks = GetStacks();
        double hpercent = double(owner.health) / double(owner.GetMaxHealth(true));

        return min(25. * stacks * hpercent,50 * stacks);
    }

    states {
        Spawn:
            BON2 ABCB 3;
            Loop;
    }
}