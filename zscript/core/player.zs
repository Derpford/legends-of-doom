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

    override void Tick() {
        super.Tick();
        TryLevel();
        
        // Restore 1% max health every 5 seconds.
        if(GetAge() % 175 == 0) {
            int amt = floor(0.01*GetMaxHealth(true));
            GiveBody(amt);
        }
    }

    // TODO: TakeSpecialDamage override for Toughness.

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
        Inventory it = inv;
        double bonus = 0.;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                bonus += lit.GetLuck();
            }
            it = it.inv;
        }
        return bonus + self.Luck + (self.LuckGrow * self.Level);
    }

    double GetPrecision() {
        // As with GetLuck, but for Precision.
        Inventory it = inv;
        double bonus = 0.;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                bonus += lit.GetPrecision();
            }
            it = it.inv;
        }
        return bonus + self.Precision + (self.PrecisionGrow + self.Level);
    }

    double GetToughness() {
        // As with GetLuck, but for Toughness.
        Inventory it = inv;
        double bonus = 0.;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                bonus += lit.GetToughness();
            }
            it = it.inv;
        }
        double ret = bonus + self.Toughness + (self.ToughnessGrow * self.Level);
        // console.printf("Calculated toughness: "..ret);
        return ret;
    }

    double GetPower(bool raw = false) {
        // Grabs the current Power value. If `raw`, skip the precision doubling check.
        Inventory it = inv;
        double bonus = 0.;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                bonus += lit.GetPower();
            }
            it = it.inv;
        }
        double pow = bonus + self.Power + (self.PowerGrow * self.Level);
        double lucky = GetPrecision();

        // Return the raw value if asked.
        if (raw) { return pow; }
        double multi = RollDown(lucky);
        return pow * multi;
    }

    override int GetMaxHealth (bool withUpgrades) {
        // We're measuring health with the growth calculator.
        // Sadly, checking against inventory items fails.
        if (withUpgrades) {
            return MaxHealth + BonusHealth + Floor(BonusHealthGrow * Level);
        } else {
            return MaxHealth;
        }
    }

    override int TakeSpecialDamage (Actor inf, Actor src, int dmg, Name type) {
        // RollDown our Toughness and use that as a divisor.
        double div = RollDown(GetToughness());
        if (div > 1) { A_StartSound("switches/normbutn",8,pitch:1.2); } // Placeholder sound for "Toughness procced"
        double new = double(dmg) / div;
        // console.printf("Toughness: "..dmg.." to "..new);
        return floor(new);
    }

}
