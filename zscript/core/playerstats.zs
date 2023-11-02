extend class LegendPlayer {
    // ALl the stat-related stuff.
    // TODO: TakeSpecialDamage override for Toughness.

    clearscope double RollDown(double initial) {
        // Returns 1, plus 1 for every 100 in initial, plus 1 based on remainder of initial.
        double ret = 1.;
        while (initial > 100.) {
            ret += 1;
            initial = floor(initial * 0.5);
        }
        // The final roll.
        while (initial > 0) {
            if (LuckRoll(initial)) {
                ret += 1;
                initial = floor(initial * 0.5);
            } else {
                initial = 0; // On first missed roll, stop rolling.
            }
        }
        return ret;
    }

    clearscope bool LuckRoll(double chance, bool isBad = false) {
        // Roll a random number between 1 and 100. If it's lower than chance, return true.
        // Luck is applied to this roll based on isBad.
        double roll = frandom(0,100);
        if(isBad) { roll += GetLuck(); } else { roll -= GetLuck(); }
        return roll < chance;
    }

    clearscope double GetBaseStat(String stat) {
        // Stats before items.
        double base; double scaling;
        if (stat == "Luck") {
            base = self.Luck;
            scaling = self.LuckGrow;
        }

        if (stat == "Precision") {
            base = self.Precision;
            scaling = self.PrecisionGrow;
        }
        
        if (stat == "Power") {
            base = self.Power;
            scaling = self.PowerGrow;
        }

        if (stat == "Toughness") {
            base = self.Toughness;
            scaling = self.ToughnessGrow;
        }
        return base + (scaling * level);
    }

    clearscope double GetHaste() {
        // Characters do not naturally gain Haste.
        Inventory it = inv;
        double bonus = 0.;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                bonus += lit.GetHaste();
            }
            it = it.inv;
        }

        return bonus;
    }

    clearscope double GetLuck() {
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
        // Capped to 50!
        double baseLuck = GetBaseStat("Luck");
        double RealLuck = SmoothCap(baseLuck+bonus, 50);
        return RealLuck; //clamp(-50, 50,RealLuck);
    }

    clearscope double GetPrecision() {
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
        return bonus + GetBaseStat("Precision");
    }

    clearscope double GetToughness() {
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
        return bonus + GetBaseStat("Toughness");
    }

    clearscope double UI_GetPower(bool raw = true) {
        // Skip the precision hit proc. This is for HUDs and the like.
        // Also defaults to 'raw' value.
        double lucky = GetPrecision();
        double multi = RollDown(lucky);
        
        Inventory it = inv;
        double bonus = 0.;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                bonus += lit.GetPower();
            }
            it = it.inv;
        }
        double pow = bonus + GetBaseStat("Power");
        if (raw) { return pow; }
        return pow * multi;
    }

    double, double GetPower(bool raw = false) {
        // Grabs the current Power value. If `raw`, skip the precision doubling check.
        // Also returns the multiplier, in case you need that.
        double lucky = GetPrecision();
        double multi = RollDown(lucky);
        if (CountInv("AimComp") > 0) { multi += 1; }

        Inventory it = inv;
        double bonus = 0.;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                if (multi > 1.) {
                    lit.OnPrecisionHit();
                }
                bonus += lit.GetPower();
            }
            it = it.inv;
        }
        double pow = bonus + GetBaseStat("Power");

        // Return the raw value if asked.
        if (raw) { return pow; }
        return pow * multi, multi;
    }

    override int GetMaxHealth (bool withUpgrades) {
        // We're measuring health with the growth calculator.
        // Sadly, checking against inventory items fails.
        if (withUpgrades) {
            return MaxHealth + Stamina + BonusHealth + Floor(BonusHealthGrow * Level);
        } else {
            return MaxHealth;
        }
    }

    override int TakeSpecialDamage (Actor inf, Actor src, int dmg, Name type) {
        // RollDown our Toughness and use that as a divisor.
        double tough = GetToughness();
        double div = DimResist(GetToughness(),50);
        // if (div > 1) { A_StartSound("switches/normbutn",8,pitch:1.2); } // Placeholder sound for "Toughness procced"
        double new = double(dmg) * div;
        console.printf("Toughness: "..dmg.." to "..new);
        return floor(new);
    }

}