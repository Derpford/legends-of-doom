class RubyPower : LegendItem {
    // Socket to me!
    default {
        LegendItem.Icon "KGZRB0";
        Tag "Ruby of Power";
        LegendItem.Desc "Gain +1 Power.";
        LegendItem.Remark "Strength Enchantment";
        LegendItem.Rarity "COMMON ATTACK";
    }

    override string GetLongDesc() {
        return "Every weapon's damage is affected by Power.";
    }

    override double GetPower() {
        return GetStacks();
    }

    states {
        Spawn:
            KGZR B -1;
            Stop;
    }
}

class EmeraldPrecise : LegendItem {
    default {
        LegendItem.Icon "KGZGB0";
        Tag "Emerald of Precision";
        LegendItem.Desc "Gain +8 Precision.";
        LegendItem.Remark "Dexterity Enchantment";
        LegendItem.Rarity "COMMON ATTACK";
    }

    override string GetLongDesc() {
        return "Precision gives you a percentage chance to do double damage. High enough Precision allows triple damage, or more. Some weapons do special things with Precision...";
    }

    override double GetPrecision() {
        return GetStacks() * 8.;
    }

    states {
        Spawn:
            KGZG B -1;
            Stop;
    }

}

class OnyxToughness : LegendItem {
    default {
        LegendItem.Icon "KGZZB0";
        Tag "Onyx of Toughness";
        LegendItem.Desc "Gain +8 Toughness.";
        LegendItem.Remark "Constitution Enchantment";
        LegendItem.Rarity "COMMON DEFENSE";
    }

    override string GetLongDesc() {
        return "Toughness gives you damage reduction. At 50 Toughness, you have 50% damage reduction, but after that, diminishing returns start kicking in.";
    }

    override double GetToughness() {
        return GetStacks() * 8.;
    }

    states {
        Spawn:
            KGZZ B -1;
            Stop;
    }

}

class TopazLucky : LegendItem {
    default {
        LegendItem.Icon "KGZYB0";
        Tag "Lucky Topaz";
        LegendItem.Desc "Gain +1 Luck.";
        LegendItem.Remark "Keepsake Charm";
        LegendItem.Rarity "COMMON UTILITY";
    }

    override string GetLongDesc() {
        return "Luck affects most forms of randomness, but suffers from extremely diminishing returns. You can't have more than 50 Luck.";
    }

    override double GetLuck() {
        return GetStacks() * 1.;
    }

    states {
        Spawn:
            KGZY B -1;
            Stop;
    }
    
}

class FirebluCursed : LegendItem {
    default {
        LegendItem.Icon "KGZFB0";
        Tag "FIREBLU Gem";
        LegendItem.Desc "Buff all your stats, but take more damage.";
        LegendItem.Remark "Demon Core";
        LegendItem.Rarity "CURSED";
    }

    override string GetLongDesc() {
        return "Gain 2.5 Power, 2.5 Luck, 12 Precision and 12 Toughness (+2.5/2.5/12/12 per stack). Take 10% more damage (+10% per stack).";
    }

    override double GetLuck() {
        return 2.5 * GetStacks();
    }

    override double GetPower() {
        return 2.5 * GetStacks();
    }

    override double GetPrecision() {
        return 12 * GetStacks();
    }

    override double GetToughness() {
        return 12 * GetStacks();
    }

    override double DamageMulti (int dmg, Name type, Actor inf, Actor src, int flags) { return 1.0 + (GetStacks() * 0.1); }

    states {
        Spawn:
            KGZF AB 5;
            Loop;
    }
}