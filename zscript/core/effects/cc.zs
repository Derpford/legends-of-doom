class Pain : StatusEffect {
    // Flinches the target for a certain number of frames.

    default {
        StatusEffect.StackGiven .1;
        StatusEffect.Timer .1;
    }

    override void OnTick() {
        if (owner.health > 0 && !owner.bCORPSE && owner.ResolveState("pain") && !InStateSequence(owner.curstate,owner.ResolveState("Pain"))) {
            owner.SetState(owner.ResolveState("Pain"));
        }
    }
}

class Jam : StatusEffect {
    // Flinches the target whenever they try to attack.
    bool flinched;
    default {
        StatusEffect.StackGiven .25;
        StatusEffect.Timer 0.5; // half-second timer.
    }

    override void OnTick() {
        if (owner.health > 0 && !owner.bCORPSE && owner.ResolveState("pain")) {
            if (owner.InStateSequence(owner.curstate,owner.ResolveState("Melee")) || owner.InStateSequence(owner.curstate,owner.ResolveState("Missile"))) {
                owner.SetState(owner.ResolveState("Pain"));
                flinched = true;
            }

            if (flinched && !owner.InStateSequence(owner.curstate,owner.ResolveState("Pain"))) {
                owner.SetState(owner.ResolveState("Pain"));
            }
        }

        if(owner && owner.GetAge() % 10 == 0) { 
            owner.A_SpawnItemEX("JamPuff",xofs:owner.radius,zofs:owner.height+8,angle:owner.GetAge()); 
            owner.A_SpawnItemEX("JamPuff",xofs:owner.radius,zofs:owner.height+8,angle:owner.GetAge()+180); 
        }
    }

    override void OnTimer() {
        if (flinched) {
            super.OnTimer();
        }
    }
    
    override void OnEnd() {
        flinched = false;
        super.OnEnd();
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

class Root : StatusEffect {
    // Locks the target's X/Y movement.
    Vector3 oldpos;
    bool posSet;
    default {
        StatusEffect.Timer 1.;
        StatusEffect.StackGiven .1; 
        // Each stack is .1s of root, so you can define roots down to .1s resolution
    }

    override void OnStack(int amt) {
        if(!posSet) {
            oldpos = owner.pos;
            posSet = true;
        }
    }

    override void OnTick() {
        owner.vel = (0,0,owner.vel.z);
        //GROSS HAX AHEAD
        owner.SetOrigin((oldpos.x,oldpos.y,owner.pos.z),false);
        if (owner && owner.GetAge() % 10 == 0) {
            owner.A_SpawnItemEX("RootSmoke",xofs:owner.radius, zofs:0,angle:owner.GetAge());
            owner.A_SpawnItemEX("RootSmoke",xofs:owner.radius, zofs:0,angle:-owner.GetAge());
        }
    }

    override void OnEnd() {
        posSet = false;
        super.OnEnd();
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