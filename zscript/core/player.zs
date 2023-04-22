class LegendPlayer : DoomPlayer abstract {
    mixin Lerps;
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

    // In addition, we use BonusHealth for health increases.
    double BonusHealthGrow;

    Array<LegendItem> recentItems; // Holds LegendItems we just picked up.
    double itemTimer; // Counts up. At ~5s, remove the first entry in recentItems.

    double healthtimer; // Counts up. At ~.5s, take 1% maxhp.
    double armortimer; // Same for armor.

    int level;
    double xp;
    // Every so often, you level up. 
    // This increases your core stats.

    Name bfg; // A weapon you can quickly select using the Zoom key.
    Property BFG : bfg;

    double hasteProgress; // For every 100 of this, advance 1 tick.


    default {
        LegendPlayer.Power 5., 1.;
        LegendPlayer.Precision 0., 0.5;
        LegendPlayer.Toughness 0., 1.;
        LegendPlayer.Luck 0., 0.;
        LegendPlayer.BonusHealth 0, 0.5; // The only property that *doesn't* take a double for its first param!
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
        if (!player || !player.mo || player.mo != self) {
            Super.Tick();
            return;
        }

        Super.Tick();

        if (TryLevel()) {
            console.printf("Level is now "..level+1);
        }
        
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

        // Do the same for armor.
        if(CountInv("LegendArmor") > mhp*2) {
            armortimer += 1./35.;
            if (armortimer >= .5) {
                int amt = ceil(0.01*(CountInv("LegendArmor") - (mhp*2)));
                TakeInventory("LegendArmor",amt);
                armortimer = 0;
            }
        } else {
            armortimer = -5.;
        }

        // Handle haste.
        if (health > 0 && player.readyweapon) {
            let wpn = player.readyweapon;
            let st = player.GetPSprite(PSP_WEAPON);
            if (!wpn.InStateSequence(st.curstate,wpn.ResolveState("Ready"))) {
                // Not in the Ready state, tick Haste.
                hasteProgress += GetHaste();
                while (hasteProgress > 100.) {
                    // It's safe to subtract a tick.
                    st.tics = max(1,st.tics - 1);
                    hasteProgress -= max(100., hasteProgress / 2.);
                }
            } else {
                hasteProgress = 0; // Reset haste if not in a non-Ready state.
            }
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

}
