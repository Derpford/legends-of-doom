class RuneOfPain : LegendItem {
    // It has such sights to show you...
    bool active;
    default {
        LegendItem.Icon "RKYYA0";
        LegendItem.Timer .25;
        Tag "Rune of Pain";
        LegendItem.Desc "Hitting pained enemies spawns XP.";
        LegendItem.Remark "Sadness in a box.";
        LegendItem.Rarity "RARE UTILITY";
    }

    override string GetLongDesc() {
        return "On-hit, if the target is in their pain state, spawn an XP gem worth .25 XP (+.25 per stack). Can trigger once every .25 seconds.";
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
        LegendItem.Icon "SKYYA0";
        LegendItem.Timer 2.5;
        Tag "Rune of Eyes";
        LegendItem.Desc "Precision hits grant luck for a short time.";
        LegendItem.Remark "I am the God-Particle!";
        LegendItem.Rarity "RARE ATTACK DEFENSE";
    }

    override string GetLongDesc() {
        return "Gain +4 Precision. On Precision Hit, gain 5 (+5 per stack) Precision. This buff decays by 2.5 (+2.5 per stack) every 2.5 seconds.";
    }

    override double GetPrecision() {
        return 4.0;
    }

    override void OnPrecisionHit() {
        power = 5 * GetStacks();
    }

    override void DoEffect() {
        super.DoEffect();
        if (power > 0) {
            if(TimeUp()) {
                SetTimer();
                power = max(0, power - (2.5 * GetStacks()));
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
        LegendItem.Icon "ZKYYA0";
        LegendItem.Timer .2;
        Tag "Rune of Judgement";
        LegendItem.Desc "Retaliate with a homing projectile.";
        LegendItem.Remark "JUDGEMENT!";
        LegendItem.Rarity "EPIC ATTACK DEFENSE";
    }

    override string GetLongDesc() {
        return "On taking health damage, spawn a homing snake of JUDGEMENT that does damage equal to 100% (+50% per stack) of the damage taken, homing in on the enemy who wronged you. Can trigger once every .2 seconds. Does not protect against being locked in a flesh prison.";
    }

    override void OnRetaliate(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if(src && src != tgt && TimeUp()) {
            LegendShot js = LegendShot(owner.Spawn("JudgementSnake",owner.pos+(0,0,24)));
            js.target = owner;
            js.tracer = src;
            js.angle = Normalize180(owner.angle) + (90 * frandom(-1,1));
            js.pitch = frandom(-45,45);
            js.dmg = dmg * (0.5 + (0.5 * GetStacks()));
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
    mixin NoClipProj;

    default {
        +NOCLIP;
        +SEEKERMISSILE;
        Speed 20;
        RenderStyle "Add";
        radius 20;
        height 10;
    }

    override void Tick() {
        Super.Tick();
        ClipCheck();
    }

    states {
        Spawn:
            FATB AB 2 Bright {
                Spawn("JudgementTail",invoker.pos);
                Seek();
                // A_SeekerMissile(10,15,SMF_PRECISE|SMF_LOOK,128,5);
                // if(!tracer) {
                //     angle += 30; // Spin in place if there's no target.
                //     VelFromAngle(speed,angle);
                // }
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
        RenderStyle "Add";
    }

    states {
        Spawn:
            PUFF A 2 A_FadeOut();
            Loop;
    }
}


