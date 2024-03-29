class Retribution : LegendItem {
    // Big talk for someone within smiting distance
    default {
        Scale 0.75;
        Tag "Retribution";
        LegendItem.Icon "HAMIA0";
        LegendItem.Desc "On-hit, chance to smite a foe.";
        LegendItem.Remark "Go Medieval On Thy Foes";
        LegendItem.Rarity "RARE ATTACK";
        LegendItem.RandomDecay 0.1;
        +FLOATBOB;
    }

    override string GetLongDesc() {
        return "On-hit, 25% chance to fire a holy hammer, dealing Smite damage equal to 500% (+500% per stack) of your Power. Smite damage is increased based on the target's missing health, dealing up to 2x damage against low-health enemies. If the target is overhealed (somehow), the attack will deal less damage, down to 0.5x at twice normal health.";
    }

    override void OnHit (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if (LuckRoll(25)) {
            let it = LegendShot(Spawn("RetributionHammer",owner.pos+(0,0,owner.height/2)));
            if (it) {
                it.target = owner;
                it.tracer = tgt;
                it.VelFromAngle(it.speed,it.angle);
                it.angle = owner.angle + frandom(-15,15);
                it.dmg = GetStacks() * GetOwnerPower() * 5;
            }
            randomAdjust += 1;
        }
    } 

    states {
        Spawn:
            HAMI ABCD 5;
            Loop;
    }
}

class RetributionHammer : LegendShot {
    mixin NoClipProj;
    default {
        DamageType "Smite";
        SeeSound "imp/attack";
        DeathSound "imp/shotx";
    }

    override void Tick() {
        Super.Tick();
        ClipCheck();
    }

    states {
        Spawn:
            HAMM ABCD 4 Bright { 
                // A_SeekerMissile(70,90,SMF_PRECISE|SMF_LOOK);
                Seek();
                // if (tracer == target) {
                //     tracer == null;
                // }
            }
            Loop;
        Death:
            BAL1 CDE 5 Bright;
            TNT1 A 0;
            Stop;
    }
}