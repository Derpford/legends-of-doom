class Bleed : StatusEffect {
    // Deals damage over time at a flat rate of 4 per second per stack.
    double lifetime;
    default {
        StatusEffect.Timer .5; // tick twice a second.
    }

    override void OnTimer() {
        if (!owner.bISMONSTER && !(owner is "LegendPlayer")) { super.OnTimer(); return; } //QoL: Non-monsters cannot be bled to death. Barrels are no longer timebombs.

        owner.DamageMobj(self,master,2*stacks,"Bleeding",DMG_NO_PAIN|DMG_NO_ARMOR|DMG_THRUSTLESS);

        let bld = owner.Spawn("BloodParticle",owner.pos+(0,0,(owner.height/2)));
        bld.vel = (frandom(-6,6),frandom(-6,6),frandom(4,12));

        lifetime += .5;
        if (lifetime >= 5) {
            stacks = 0; // Reset all stacks when the timer runs out!
        }

        super.OnTimer();
    }

    override void OnStack(int amt) {
        lifetime = 0;
        super.OnStack(amt);
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

class Burn : StatusEffect {
    // Every second, ticks for 1 * stacks and has a 5% chance of spreading to nearby enemies.
    // Also has a 5% chance of removing a stack.
    default {
        StatusEffect.StackGiven 1;
        StatusEffect.Timer 1;
    }

    override void OnTimer() {
        // if (!owner.bISMONSTER && !(owner is "LegendPlayer")) { super.OnTimer(); return; } //QoL: Non-monsters skip DoTs.

        owner.DamageMobj(self,master,stacks,"Fire",DMG_NO_PAIN|DMG_NO_ARMOR|DMG_THRUSTLESS);

        if (frandom(0,1) < 0.05) {
            owner.A_RadiusGive("Burn",owner.radius * 4,RGF_PLAYERS|RGF_MONSTERS); // TODO: Should this friendly-fire?
            let b = FlameBurst(owner.Spawn("FlameBurst",owner.pos+(0,0,owner.height/2)));
            if (b) {
                b.power = 1;
                b.giveradius = owner.radius * 4;
            }
        }

        if (frandom(0,1) < 0.05) {
            TakeStacks(1);
        }

        SetTimer();
    }

    override void OnTick() {
        if(owner && owner.GetAge() % 10 == 0) { 
            owner.A_SpawnItemEX("BurnFlame",xofs:owner.radius,zofs:owner.height+8,angle:owner.GetAge()); 
            owner.A_SpawnItemEX("BurnFlame",xofs:owner.radius,zofs:owner.height+8,angle:owner.GetAge()+180); 
        }
    }
}

class FlameBurst : Actor {
    // Spreading flames.
    int power;
    double giveradius;
    default {
        Scale 1.5;
        RenderStyle "Add";
        +NOGRAVITY;
    }

    states {
        Spawn:
            TNT1 A 1;
            BAL1 C 5 Bright {
                // Iterate over all nearby things.
                console.printf("Burn set off!");
                let it = ThinkerIterator.create("Actor",Thinker.STAT_DEFAULT);
                Actor mo;
                while (mo = Actor(it.next())) {
                    if (mo.bSHOOTABLE && (Vec3To(mo).length() - mo.radius) < giveradius) {
                        console.printf("Within range for "..mo.GetClassName());
                        console.printf("Stats: %d, %0.2f",power,giveradius);
                        let itm = mo.GiveInventory("Burn",power);
                    }
                }
            }
            BAL1 DE 5 Bright;
            TNT1 A 0;
            Stop;
    }

}

class BurnFlame : Actor {
    // Fancy fire effect.
    default {
        +NOINTERACTION;
        RenderStyle "Add";
    }

    states {
        Spawn:
            BAL1 ABCDE 3 Bright { vel.z += 1; }
            TNT1 A 0;
            Stop;
    }
}