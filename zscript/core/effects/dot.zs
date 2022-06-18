class Bleed : StatusEffect {
    // Deals damage over time at a flat rate of 5 per second per stack.
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