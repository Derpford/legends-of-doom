mixin class PlayerVac {
    bool shouldSuck;
    property dontSuck : shouldSuck;
    void Suck() {
        if(shouldSuck) {return;}
        if (target && !target.bCORPSE) {
            if (GetAge() > 48) { bNOGRAVITY = true; }
            bNOCLIP = (vec3To(target).length() > target.radius+radius);
            vel += vec3To(target).unit() * (min(GetAge(),48) * 0.1);
        } else {
            ThinkerIterator it = ThinkerIterator.Create("LegendPlayer");
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
        if (e.Thing.bISMONSTER || e.Thing is "PlayerPawn") {
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
                console.printf("Vorpal hit for "..maxhealth*0.1.." damage!");
                new = floor(maxhealth*0.1);

            }
        }
    }
}

class RadBurst : Actor {
    // Emits radiation, creates sparkles, and stops existing.
    int radius;
    int power;

    default {
        RenderStyle "Add";
        +NOGRAVITY;
    }

    states {
        Spawn:
            TNT1 A 0;
            APLS A 0 {
                A_Explode(power,radius,0,fulldamagedistance:radius,damagetype:"Radiation");
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
    // Loses half of stacks each time it triggers.
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
    }

    override void DoEffect() {
        if (owner.health > 0 && !owner.bCORPSE && owner.ResolveState("pain")) {
            if (owner.InStateSequence(owner.curstate,owner.ResolveState("Melee")) || owner.InStateSequence(owner.curstate,owner.ResolveState("Missile"))) {
                owner.SetState(owner.ResolveState("Pain"));
                owner.TakeInventory("Jam",ceil(0.5 * owner.CountInv("Jam")));
            }
        } else {
            owner.TakeInventory("Jam",1);
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
        if (timer >= timermax) {
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