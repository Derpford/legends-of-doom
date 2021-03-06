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

    // The 'grow' vars determine how much is added with each level.
    Property Power : Power, PowerGrow;
    Property Precision : Precision, PrecisionGrow;
    Property Toughness : Toughness, ToughnessGrow;
    Property Luck : Luck, LuckGrow;
    Property BonusHealth : BonusHealth, BonusHealthGrow;
    Property Level : Level;

    // In addition, we use BonusHealth for health increases.
    double BonusHealthGrow;

    Array<LegendItem> recentItems; // Holds LegendItems we just picked up.
    double itemTimer; // Counts up. At ~5s, remove the first entry in recentItems.

    double healthtimer; // Counts up. At ~.5s, take 1% maxhp.

    int level;
    double xp;
    // Every so often, you level up. 
    // This increases your core stats.

    Name bfg; // A weapon you can quickly select using the Zoom key.
    Property BFG : bfg;


    default {
        LegendPlayer.Power 25., 5.;
        LegendPlayer.Precision 0., 0.5;
        LegendPlayer.Toughness 0., 1.;
        LegendPlayer.Luck 0., 0.;
        LegendPlayer.BonusHealth 0, 0.5; // The only property that *doesn't* take a double for its first param!
        LegendPlayer.Level 1; // Should always start at level 1!
        Player.MaxHealth 100; // Make sure this is set.
    }

    void GiveHealth(int amount, bool overheal = false) {
        // Since GiveBody keeps failing.
        if(!overheal) {
            GiveBody(amount,GetMaxHealth(true));
        } else {
            GiveBody(amount,int.MAX);
        }

        player.health = health; //sync health
    }

    void TakeHealth(int amount) {
        health -= amount;
        player.health = health;
    }

    override void Tick() {
        super.Tick();
        TryLevel();
        
        int mhp = GetMaxHealth(true);

        if(GetAge() % (35 * 5) == 0) {
            // Restore 1% max health every 5 seconds.
            if(health < mhp) {
                int amt = floor(0.01*mhp);
                GiveHealth(amt);
            }
        }
        // Also, tick overheal down until it's at mhp+100.
        if(health > mhp+100) {
            healthTimer += 1./35.;
            if (healthTimer >= .5) {
                int amt = ceil(0.01*(health - (mhp+100)));
                TakeHealth(amt);
                healthTimer = 0;
            }
        } else {
            healthTimer = -5.; // Overheal doesn't tick down until at least 5s after overhealing.
        }

        // If we're currently pressing BT_ZOOM, select the BFG.
        int buttons = GetPlayerInput(INPUT_BUTTONS);
        if (buttons & BT_ZOOM) {
            A_SelectWeapon(bfg);
        }

        // Tick the HUD item stuff.
        if (recentItems.Size() > 0) {
            itemTimer += 1./35.;
            if (itemTimer > 5.) {
                recentItems.Delete(0);
                itemTimer = 0.;
            }
        }
    }

    // TODO: TakeSpecialDamage override for Toughness.

    clearscope double RollDown(double initial) {
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

    clearscope bool LuckRoll(double chance, bool isBad = false) {
        // Roll a random number between 1 and 100. If it's lower than chance, return true.
        // Luck is applied to this roll based on isBad.
        double roll = frandom(0,100);
        if(isBad) { roll += GetLuck(); } else { roll -= GetLuck(); }
        return roll < chance;
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
        double baseLuck = self.Luck + (self.LuckGrow * self.Level);
        double RealLuck = (atan((bonus+baseLuck)/50.) / 180.) * 2 * 50;
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
        return bonus + self.Precision + (self.PrecisionGrow * self.Level);
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
        double ret = bonus + self.Toughness + (self.ToughnessGrow * self.Level);
        // console.printf("Calculated toughness: "..ret);
        return ret;
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
        double pow = bonus + self.Power + (self.PowerGrow * self.Level);
        if (raw) { return pow; }
        return pow * multi;
    }

    double GetPower(bool raw = false) {
        // Grabs the current Power value. If `raw`, skip the precision doubling check.
        double lucky = GetPrecision();
        double multi = RollDown(lucky);
        if (CountInv("PowerStrength") > 0) { multi += 1; } // Grabbing a Zerk increases your multiplier for the rest of the level.

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
        double pow = bonus + self.Power + (self.PowerGrow * self.Level);

        // Return the raw value if asked.
        if (raw) { return pow; }
        return pow * multi;
    }

    override int GetMaxHealth (bool withUpgrades) {
        // We're measuring health with the growth calculator.
        // Sadly, checking against inventory items fails.
        if (withUpgrades) {
            return MaxHealth + stamina + Floor(BonusHealthGrow * Level);
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
