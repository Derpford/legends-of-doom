class RuneOfPain : LegendItem {
    // It has such sights to show you...
    bool active;
    default {
        Inventory.Icon "RKYYA0";
        LegendItem.Timer .25;
        Tag "Rune of Pain";
        LegendItem.Desc "Hitting pained enemies spawns XP.";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if (tgt.InStateSequence(tgt.curstate, tgt.ResolveState("Pain")) && TimeUp()) {
            let gem = XPGem(tgt.spawn("SmallXPGem", tgt.pos));
            if (gem) {
                gem.value = 0.25 * GetStacks();
                gem.vel = (frandom(-4,4), frandom(-4,4), frandom(6,12));
            }
            active = true;
            SetTimer();
        }
    }

    override void OnTimer() {
        active = false;
    }

    states {
        Spawn:
            RKYY ABCDEFGHIJ 4;
            Loop;
    }
}

class RuneOfEyes : LegendItem {
    // I am the god-particle that permeates the universe.
    double power;

    default {
        Inventory.Icon "SKYYA0";
        LegendItem.Timer 2.5;
        Tag "Rune of Eyes";
        LegendItem.Desc "Precision hits grant a bit of luck.";
    }

    override void OnPrecisionHit() {
        power = min(power + 0.5 * GetStacks(), 50);
    }

    override void DoEffect() {
        super.DoEffect();
        if (power > 0) {
            if(TimeUp()) {
                SetTimer();
                power = max(0, power - (1. * GetStacks()));
            } 
        } else {
                SetTimer();
        }

    }

    override double GetLuck() {
        return power;
    }

    states {
        Spawn:
            SKYY ABCDEFGHIJKLMNOPQR 4;
            Loop;
    }
}

class RuneOfJudgement : LegendItem {
    // AND THY PUNISHMENT IS DEATH.
    default {
        Inventory.Icon "ZKYYA0";
        LegendItem.Timer 2.;
        LegendItem.Alarm "misc/p_pkup",1.5;
        Tag "Rune of Judgement";
        LegendItem.Desc "Retaliate with a homing projectile.";
    }

    override void OnRetaliate(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if(src && src != tgt && TimeUp()) {
            LegendShot js = LegendShot(owner.Spawn("JudgementSnake",owner.pos+(0,0,24)));
            js.target = owner;
            js.tracer = src;
            js.angle = Normalize180(owner.angle) + (90 * frandom(-1,1));
            js.pitch = frandom(-45,45);
            js.power = dmg * (0.5 + (0.5 * GetStacks()));
            SetTimer();
        }
    }

    states {
        Spawn:
            ZKYY ABCDEFGHIJKLMNOPQR 4;
    }
}

class JudgementSnake : LegendShot {
    // JUDGEMENT.
    default {
        +NOCLIP;
        +SEEKERMISSILE;
        Speed 20;
        radius 20;
        height 10;
    }

    override void Tick() {
        Super.Tick();
        if(tracer) {
            if (Vec3To(tracer).length() < (tracer.radius + self.radius)) {
                // We're about to hit.
                bNOCLIP = false;
            }
        }
    }

    states {
        Spawn:
            FATB AB 2 Bright {
                if (tracer) {
                    A_SeekerMissile(10,15,SMF_PRECISE);
                    Spawn("JudgementTail",invoker.pos);
                    return ResolveState(null);
                } else {
                    return ResolveState("Death");
                }
            }
            Loop;
        Death:
            TNT1 A 0 A_StartSound("skeleton/tracex");
            FBXP ABC 6 Bright;
            TNT1 A 0;
            Stop;
    }
}

class JudgementTail : Actor {
    default {
        +NOINTERACTION;
        Scale 2.;
    }

    states {
        Spawn:
            PUFF AB 2 A_FadeOut();
            Loop;
    }
}


