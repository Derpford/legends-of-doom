class LegendWeapon : Weapon {
    // A weapon held by a Legend.
    
    double BaseDmg; // Base damage of the projectile, for setting the bare minimum. Useful for weapons that are supposed to be strong early.
    double PowScale; // Multiplies Power to get final damage.

    Property Damage : BaseDmg, PowScale;

    default {
        LegendWeapon.Damage 0, 1.0;
    }

    double, double GetPower(bool raw = false) {
        let plr = LegendPlayer(owner);
        if (!plr) { return 0.0; } // Something went wrong.
        double pow; double multi;
        [pow,multi] = plr.GetPower(raw);
        return pow, multi;
    }

    action state A_DualFire(StateLabel st, bool alt = false) {
        // A helpful function for handling dual-wielding.
        int btns = GetPlayerInput(INPUT_BUTTONS);
        if (!alt) {
            if (btns & BT_ATTACK && invoker.CheckAmmo(PrimaryFire,false)) {
                return ResolveState(st);
            }
        } else {
            if (btns & BT_ALTATTACK && invoker.CheckAmmo(AltFire,false)) {
                return ResolveState(st);
            }
        }
        return ResolveState(null);
    }


    int GetDamage(double power, double base = -1, double scale = -1) {
        // Mildly annoying hax, because there's no clean way to have these defaults in an action function to my knowledge
        if (base < 0) { base = BaseDmg; }
        if (scale < 0) { scale = PowScale; }
        // Since we might get a fractional damage value, use the fractional part as a chance of rounding up.
        let plr = LegendPlayer(owner);
        if(!plr) { return 0; } // Something went wrong.

        int bpow = floor(power);
        double c = (power - bpow)*100; // Percentage chance of getting the higher value

        int fdmg = floor(base + (power * scale));
        if (plr.LuckRoll(c)) {
            fdmg = ceil(base + (power * scale));
        }
        return fdmg;
    }

    action void TakeAmmo(bool alt = false) {
        // if(!alt) {
        //     A_TakeInventory(invoker.ammotype1,invoker.ammouse1);
        // } else {
        //     A_TakeInventory(invoker.ammotype2,invoker.ammouse2);
        // }
        // DepleteAmmo is used instead.
        invoker.DepleteAmmo(alt);
    }

    action actor Shoot(Name type, double ang = 0, double xy = 0, int height = 0, int flags = 0, double pitch = 0, double base = -1, double dscale = -1) {
        Actor it; Actor dummy;
        [dummy, it] = A_FireProjectile(type,ang,false,xy,height,flags,pitch);
        if(it) {
            double pow; double multi;
            [pow, multi] = invoker.GetPower();
            int dmg = invoker.GetDamage(pow,base,dscale);
            if (it is "LegendShot") {
                let it = LegendShot(it);
                it.power = pow;
                it.dmg = dmg;
                it.precision = multi;
            } else if (it is "LegendFastShot") {
                let it = LegendFastShot(it);
                it.power = pow;
                it.dmg = dmg;
                it.precision = multi;
            }
            return it;
        } else {
            return null;
        }
    }

    action void Cycle() {
        // Procs OnCycle.
        // This should happen either during the Fire state or during a weapon's reload.
        // Be mindful of how often each weapon procs this, because it affects their synergies
        // (i.e., with Surplus Caliber)
        A_StartSound("misc/w_pkup",8,volume:0.7,pitch:1.3);
        Inventory it = invoker.owner.inv;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                lit.OnCycle();
            }
            it = it.inv;
        }
    }

}

class LegendShot : Missile {
    // A projectile fired by a LegendWeapon.
    mixin SplashDamage;

    double power;
    int dmg;
    double precision; // What's the precision modifier?
    double proc; // Multiplier to proc damage.
    property Proc: proc;

    default {
        PROJECTILE;
        +FORCERADIUSDMG;
        -RIPPER;
        +Missile.HITONCE;
        Speed 40;
        LegendShot.Proc 1;
        DamageFunction (dmg);
    }

    override int DoSpecialDamage(Actor tgt, int dmg, name mod) {
        // If this was precision damage, spawn a special particle effect.
        if (precision > 1) {
            A_SpawnItemEX("PrecisionFlash",xofs: -16);
        }
        return super.DoSpecialDamage(tgt,dmg,mod);
    }

}

class LegendFastShot : FastMissile {
    // FastProjectile for LegendWeapons.
    mixin SplashDamage;

    int dmg;
    double power;
    double precision; // What's the precision modifier?
    double proc; // Multiplier to proc damage.
    property Proc: proc;

    default {
        PROJECTILE;
        +FORCERADIUSDMG;
        -RIPPER;
        +FastMissile.HITONCE;
        Speed 40;
        LegendFastShot.Proc 1;
        DamageFunction (dmg);
    }

    override int DoSpecialDamage(Actor tgt, int dmg, name mod) {
        // If this was precision damage, spawn a special particle effect.
        if (precision > 1) {
            A_SpawnItemEX("PrecisionFlash",xofs: -16);
        }
        return super.DoSpecialDamage(tgt,dmg,mod);
    }
}

class PrecisionFlash : Actor {
    default {
        +BRIGHT;
        +NOINTERACTION;
    }

    action void ParticleRing() {
        int numParticles = 8;
        for (int i = 0; i < numParticles; i++) {
            double ang = 360. / numParticles;
            double fang = (ang * i);
            vector2 offs = (cos(fang) ,sin(fang) );
            invoker.A_SpawnParticle("FF000",SPF_FULLBRIGHT|SPF_RELATIVE,size:8,xoff:-4, yoff:offs.x * 8, zoff:offs.y * 8,velx: 1, vely:offs.x,velz:offs.y);
        }
    }

    states {
        Spawn:
            PLS2 A 0;
            PLS2 A 8 ParticleRing();
        Fade:
            PLS2 A 1 A_FadeOut();
            Loop;
    }
}

class LegendPuff : BulletPuff {
    // Needs +PUFFGETSOWNER to function correctly.
    default {
        +PUFFGETSOWNER;
    }
}