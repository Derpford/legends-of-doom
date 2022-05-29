class LegendPlayer : DoomPlayer {
    // The core class for a Legend. 
    // This class has all the basic stats that Legends should have.
    double Power; 
    double PowerGrow;
    // Affects all damage. Different attacks scale differently.
    double Precision; 
    double PrecisionGrow;
    // For every 1.0 Precision, add 1% chance to return double Power on calling GetPower(). Above 100, add chance to give 3x, and so on.
    double Toughness; 
    double ToughnessGrow;
    // For every 1.0 Toughness, add 1% chance to halve incoming damage. Above 100, add chance to give 3x, and so on.
    double Luck; 
    double LuckGrow;
    // For every 1.0 Luck, the roll used by LuckRoll() is adjusted by 1%. 
    // Which direction this goes in is decided by the "isBad" argument (default false, meaning more luck = more likely to return true).

    // In addition, we use BonusHealth for health increases.
    double BonusHealthGrow;

    int Level;
    double xp;
    // Every so often, you level up. 
    // This increases your core stats.

    // The 'grow' vars determine how much is added with each level.
    Property Power : Power, PowerGrow;
    Property Precision : Precision, PrecisionGrow;
    Property Toughness : Toughness, ToughnessGrow;
    Property Luck : Luck, LuckGrow;
    Property BonusHealth : BonusHealth, BonusHealthGrow;
    Property Level : Level;

    default {
        LegendPlayer.Power 25., 5.;
        LegendPlayer.Precision 0., 0.5;
        LegendPlayer.Toughness 0., 1.;
        LegendPlayer.Luck 0., 0.;
        LegendPlayer.BonusHealth 0, 0.5; // The only property that *doesn't* take a double for its first param!
        LegendPlayer.Level 1; // Should always start at level 1!
        Player.MaxHealth 100; // Make sure this is set.
    }

    double RollDown(double initial) {
        // Returns 1, plus 1 for every 100 in initial, plus 1 based on remainder of initial.
        double ret = 1.;
        while (initial > 100.) {
            ret += 1;
            initial -= 100.;
        }
        // The final roll.
        if (LuckRoll(initial)) {
            ret += 1;
        }
        return ret;
    }

    bool LuckRoll(double chance, bool isBad = false) {
        // Roll a random number between 1 and 100. If it's lower than chance, return true.
        // Luck is applied to this roll based on isBad.
        double roll = frandom(0,100);
        if(isBad) { roll += GetLuck(); } else { roll -= GetLuck(); }
        return roll < chance;
    }

    double GetLuck() {
        // Get the current Luck value, based on:
        // The base Luck value,
        // The LuckGrowth value times our level, 
        // and any items that might modify our Luck. [TODO]
        return self.Luck + (self.LuckGrow * self.Level);
    }

    double GetPrecision() {
        // As with GetLuck, but for Precision.
        return self.Precision + (self.PrecisionGrow + self.Level);
    }

    double GetToughness() {
        // As with GetLuck, but for Toughness.
        return self.Toughness + (self.ToughnessGrow + self.Level);
    }

    double GetPower(bool raw = false) {
        // Grabs the current Power value. If `raw`, skip the precision doubling check.
        double pow = self.Power + (self.PowerGrow * self.Level);
        double lucky = GetPrecision();

        // Return the raw value if asked.
        if (raw) { return pow; }
        double multi = RollDown(lucky);
        return pow * multi;
    }

    override int GetMaxHealth (bool withUpgrades) {
        // We're measuring health with the growth calculator.
        if (withUpgrades) {
            return MaxHealth + BonusHealth + Floor(BonusHealthGrow * Level);
        } else {
            return MaxHealth;
        }
    }

}

class XPGem : Inventory {
    // A special class that handles the whole thing with XP being a double

    double value;
    Property Value : value;

    default {
        XPGem.Value 1.0;
    }

    override void AttachToOwner(Actor other) {
        let plr = LegendPlayer(other);
        if(plr) {
            plr.xp += value;
            GoAwayAndDie(); //wow rude >:(
        }
    }

    states {
        Spawn:
            XPRS A -1;
            Loop;
        Death:
            TNT1 A 0;
            Stop;
    }
}