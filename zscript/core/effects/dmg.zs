class VorpalHandler : EventHandler {
    // Catches and modifies Vorpal damage to be based on the target's max HP.

    override void WorldThingSpawned (WorldEvent e) {
        // Give all players and monsters the VorpalModifier.
        if (e.Thing.bSHOOTABLE) {
            e.Thing.GiveInventory("VorpalModifier",1);
        }
    }
}

class VorpalModifier : Inventory {
    // Uses ModifyDamage to apply Vorpal effects.

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inflictor, Actor src, int flags) {
        int amt;
        if(passive && type == "Vorpal") {
            if(owner is "LegendPlayer") {
                amt = floor(owner.GetMaxHealth() * 0.1);
            } else {
                // We have to calculate max HP from the target's level tokens.
                // Otherwise I'd have to build a custom monster set!
                let h = MonsterLevelHandler(EventHandler.Find("MonsterLevelHandler"));
                int maxhealth = h.MonsterMaxHealth(owner);
                amt = floor(maxhealth * 0.1);
            }
        }
        new = max(dmg, amt);
    }
}

class SmiteHandler : EventHandler {
    // Catches and modifies Smite damage to gain up to +100% bonus damage, based on the difference between target's HP and the attacker's HP.

    override void WorldThingSpawned (WorldEvent e) {
        if (e.Thing.bSHOOTABLE) {
            e.Thing.GiveInventory("SmiteModifier",1);
        }
    }
}

class SmiteModifier : Inventory {
    // Uses ModifyDamage to apply Smite effects.

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inflictor, Actor src, int flags) {
        if (passive && type == "Smite") {
            double hp;
            double maxhp;
            // Get the attacker's HP.
            if (owner) {
                hp = owner.health;

                if (owner is "LegendPlayer") {
                    maxhp = src.GetMaxHealth(true);
                } else {
                    let h = MonsterLevelHandler(EventHandler.Find("MonsterLevelHandler"));
                    maxhp = h.MonsterMaxHealth(owner);
                }
            } else {
                hp = 1;
                maxhp = 1; // Default to assuming full health.
            }

            double multi = 1. + (1. - (hp/maxhp));
            multi = clamp(multi,0.5,2); // at most a factor of 2 in either direction
            console.printf("Smite multiplier: %.2f/%.2f = %.2f",hp,maxhp,multi);
            new = floor(dmg * multi);
            console.printf("Smite damage: %d",new);
        }
    }
}

class RadBurst : LegendShot {
    // Emits radiation, creates sparkles, and stops existing.
    int radius;
    mixin SplashDamage;

    default {
        RenderStyle "Add";
        +NOGRAVITY;
        LegendShot.Proc 2;
    }

    states {
        Spawn:
            TNT1 A 0;
            APLS A 0 {
                A_SplashDamage(power,radius,power,type:"Radiation",selfdmg:false);
                for (double i = 0; i < 360.; i += (360./8)) {
                    A_SpawnItemEX("RadSparkle",xofs:radius,angle:i);
                }
            }
            APLS AB 2 Bright;
            APBX ABCDE 2 Bright;
            TNT1 A 0;
            Stop;
    }
}

class RadSparkle : Actor {
    // Sparkly.
    default {
        RenderStyle "Add";
        +NOINTERACTION;
        Scale 0.5;
    }

    states {
        Spawn:
            APLS AB 2 Bright;
            APBX ABCDE 2 Bright;
            TNT1 A 0;
            Stop;
    }
}