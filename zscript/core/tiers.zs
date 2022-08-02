class RarityTier : Thinker abstract {
    // Contains data about a Rarity Tier.
    String tiername; // A shorthand name for the tier. Should not contain spaces.
    double weight; // The weight of the tier when selecting a tier randomly.
    String sparkle;
    bool hasSparkle;// Does this tier have an item sparkle associated with it?
    bool specify; // Does this tier need to be specified in the crate's tier list to be selected?

    RarityTier init() {
        ChangeStatNum(STAT_STATIC);
        self.setup();
        Console.printf("Loading rarity tier %s",tiername);
        return self;
    }

    abstract void setup(); 
    // Set the defaults here!

    RarityTier get() {
        ThinkerIterator it = ThinkerIterator.create(GetClassName(),STAT_STATIC);
        let p = RarityTier(it.next());
        if (p == null) {
            p = RarityTier(new(GetClassName())).init();
        }
        return p;
    }
}

// And now the base rarity tiers.
class CommonTier : RarityTier {
    override void setup() {
        tiername = "COMMON";
        weight = 70.0;
        sparkle = "CommonSpark";
        hasSparkle = true;
        specify = false;
    }
}

class RareTier : RarityTier {
    override void setup() {
        tiername = "RARE";
        weight = 20.0;
        sparkle = "RareSpark";
        hasSparkle = true;
        specify = false;
    }
}

class EpicTier : RarityTier {
    override void setup() {
        tiername = "EPIC";
        weight = 5.0;
        sparkle = "EpicSpark";
        hasSparkle = true;
        specify = false;
    }
}

class CursedTier : RarityTier {
    override void setup() {
        tiername = "CURSED";
        weight = 5.0;
        sparkle = "CursedSpark";
        hasSparkle = true;
        specify = true;
    }
}

// And the 'tiers' for the heal/attack/def/util crates.
class HealTier : RarityTier {
    override void setup() {
        tiername = "HEALING";
        weight = 5.0;
        sparkle = "";
        hasSparkle = false;
        specify = true;
    }
}

class AttackTier : RarityTier {
    override void setup() {
        tiername = "ATTACK";
        weight = 5.0;
        sparkle = "";
        hasSparkle = false;
        specify = true;
    }
}

class DefenseTier : RarityTier {
    override void setup() {
        tiername = "DEFENSE";
        weight = 5.0;
        sparkle = "";
        hasSparkle = false;
        specify = true;
    }
}

class UtilityTier : RarityTier {
    override void setup() {
        tiername = "UTILITY";
        weight = 5.0;
        sparkle = "";
        hasSparkle = false;
        specify = true;
    }
}