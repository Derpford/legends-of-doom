mixin class PlayerVac {
    bool shouldSuck;
    property dontSuck : shouldSuck;
    void Suck() {
        if(shouldSuck) {return;}
        if (target && !target.bCORPSE) {
            Vector3 tv = vec3To(target);
            if (GetAge() > 48) { bNOGRAVITY = true; }
            bNOCLIP = (tv.length() > target.radius+radius);
            vel += tv.unit() * (min(GetAge(),48) * 0.1);
        } else {
            ThinkerIterator it = ThinkerIterator.Create("LegendPlayer",Thinker.STAT_PLAYER);
            double dist = -1.;
            Actor m;
            Actor closest;
            while(m = Actor(it.next())) {
                double newdist = Vec3To(m).length();
                if (newdist < 256.) {
                    if (dist < 0 || newdist < dist) {
                        closest = Actor(m);
                        dist = Vec3To(closest).length();
                    }
                }
            }
            target = closest;
        }
    }
}

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
        if(passive && type == "Vorpal") {
            if(owner is "LegendPlayer") {
                int amt = floor(owner.GetMaxHealth() * 0.1);
                new = amt;
            } else {
                // We have to calculate max HP from the target's level tokens.
                // Otherwise I'd have to build a custom monster set!
                double bhealth = owner.GetSpawnHealth();
                double level = owner.CountInv("LevelToken");
                double maxhealth = bhealth + (0.1*bhealth*level);

            }
        }
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
            int ownhp;
            int otherhp;
            // Get our own HP.
            if (owner is "LegendPlayer") {
                ownhp = owner.GetMaxHealth(true);
            } else {
                double bhealth = owner.GetSpawnHealth();
                double level = owner.CountInv("LevelToken");
                double maxhealth = bhealth + (0.1*bhealth*level);
                ownhp = floor(maxhealth);
            }
            // Get the attacker's HP.
            if (src) {
                if (src is "LegendPlayer") {
                    otherhp = src.GetMaxHealth(true);
                } else {
                    double bhealth = owner.GetSpawnHealth();
                    double level = owner.CountInv("LevelToken");
                    double maxhealth = bhealth + (0.1*bhealth*level);
                    otherhp = floor(maxhealth);
                }
            } else {
                otherhp = ownhp; // If there's no source, assume self-damage.
            }

            double multi = 1 + (1 - (ownhp/otherhp));
            multi = clamp(0.5,2,multi); // at most a factor of 2 in either direction
            new = floor(dmg * multi);
        }
    }
}

class RadBurst : Actor {
    // Emits radiation, creates sparkles, and stops existing.
    int radius;
    int power;
    mixin SplashDamage;

    default {
        RenderStyle "Add";
        +NOGRAVITY;
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

class Pain : Inventory {
    // Flinches the target for a certain number of frames.

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
    }

    override void DoEffect() {
        if (owner.health > 0 && !owner.bCORPSE && owner.ResolveState("pain") && !InStateSequence(owner.curstate,owner.ResolveState("Pain"))) {
            owner.SetState(owner.ResolveState("Pain"));
        }
        owner.A_TakeInventory("Pain",1);
    }
}

class Jam : Inventory {
    // Flinches the target whenever they try to attack.
    bool flinched;
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
    }

    override void DoEffect() {
        if (owner.health > 0 && !owner.bCORPSE && owner.ResolveState("pain")) {
            if (owner.InStateSequence(owner.curstate,owner.ResolveState("Melee")) || owner.InStateSequence(owner.curstate,owner.ResolveState("Missile"))) {
                owner.SetState(owner.ResolveState("Pain"));
                flinched = true;
            }

            if (flinched && !owner.InStateSequence(owner.curstate,owner.ResolveState("Pain"))) {
                owner.SetState(owner.ResolveState("Pain"));
            }
        }
        if (flinched || owner.health <= 0 || owner.bCORPSE) {
            owner.TakeInventory("Jam",2);
        }

        if(owner && owner.GetAge() % 10 == 0) { 
            owner.A_SpawnItemEX("JamPuff",xofs:owner.radius,zofs:owner.height+8,angle:owner.GetAge()); 
            owner.A_SpawnItemEX("JamPuff",xofs:owner.radius,zofs:owner.height+8,angle:owner.GetAge()+180); 
        }
    }
}

class JamPuff : Actor {
    // A puff of smoke to indicate jammed-ness.
    default {
        +NOINTERACTION;
    }

    states {
        Spawn:
            PUFF ABCD 3 Bright { vel.z += 1; }
            Stop;
    }
}

class Root : Inventory {
    // Locks the target's X/Y movement.
    Vector3 oldpos;
    bool posSet;
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
        +INVENTORY.KEEPDEPLETED;
    }

    override void DoEffect() {
        if (owner) {
            if (owner.CountInv("Root") > 0) {
                owner.vel = (0,0,owner.vel.z);
                //GROSS HAX AHEAD
                if(!posSet) {
                    oldpos = owner.pos;
                    posSet = true;
                }

                owner.SetOrigin((oldpos.x,oldpos.y,owner.pos.z),false);

                owner.TakeInventory("Root",1);

                if (owner && owner.GetAge() % 10 == 0) {
                    owner.A_SpawnItemEX("RootSmoke",xofs:owner.radius, zofs:0,angle:owner.GetAge());
                    owner.A_SpawnItemEX("RootSmoke",xofs:owner.radius, zofs:0,angle:-owner.GetAge());
                }
            } else {
                posSet = false; // If the root has ended, reset the oldpos.
            }

        }
    }
}

class RootSmoke : Actor {
    // Indicates rooted-ness.
    default {
        Scale 0.2;
        +NOINTERACTION;
    }

    states {
        Spawn:
            TRE2 A 1 A_FadeOut();
            Loop;
    }
}

class Bleed : Inventory {
    // Deals damage over time at a flat rate of 5 per second per stack.
    int frames;
    int stacks;
    int timer, timermax;
    Property BleedTime : timermax;
    Property StackStart : stacks;
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
        Bleed.BleedTime 5 * 35;
        Bleed.StackStart 1;
    }

    override void DoEffect() {
        if (!owner.bISMONSTER && !(owner is "LegendPlayer")) { return; } //QoL: Non-monsters cannot be bled to death. Barrels are no longer timebombs.
        frames += 1;
        timer += 1;
        if (frames >= 7) {
            owner.DamageMobj(self,master,1*stacks,"Bleeding",DMG_NO_PAIN|DMG_NO_ARMOR|DMG_THRUSTLESS);
            if(timer % 14 == 0) {
                let bld = owner.Spawn("BloodParticle",owner.pos+(0,0,(owner.height/2)));
                bld.vel = (frandom(-6,6),frandom(-6,6),frandom(4,12));
            }
            frames = 0;
        }
        if (timer >= timermax || owner.bCORPSE || owner.health < 1) {
            owner.TakeInventory("Bleed",1);
        }
    }

    override bool HandlePickup (Inventory item) {
        if (item is "Bleed") {
            // Reset timer.
            timer = 0;
            // Increase stack count.
            stacks += 1;
            return true;
        }
        return false;
    }

}

class BloodParticle : Actor {
    // A bloody splat.
    default {
        +NOINTERACTION;
    }

    override void Tick() {
        Super.tick();
        if (GetAge() % 5 == 0) {
            Spawn("BloodTrail",pos);
        }
        vel.z -= 0.5;
    }

    states {
        Spawn:
            BLUD CBCBA 5;
            TNT1 A 0;
            Stop;
    }
}
class BloodTrail : Actor {
    // Bits from the bloody splat.
    default {
        +NOINTERACTION;
    }

    states {
        Spawn:
            BLUD CBABA 4;
            TNT1 A 0;
            Stop;
    }
}