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

    int GetDamage(double power) {
        // Since we might get a fractional damage value, use the fractional part as a chance of rounding up.
        let plr = LegendPlayer(owner);
        if(!plr) { return 0; } // Something went wrong.

        int bpow = floor(power);
        double c = (power - bpow)*100; // Percentage chance of getting the higher value

        int fdmg = floor(BaseDmg + (power * PowScale));
        if (plr.LuckRoll(c)) {
            fdmg = ceil(BaseDmg + (power * PowScale));
        }
        return fdmg;
    }

    action void TakeAmmo(bool alt = false) {
        if(!alt) {
            A_TakeInventory(invoker.ammotype1,invoker.ammouse1);
        } else {
            A_TakeInventory(invoker.ammotype2,invoker.ammouse2);
        }
    }

    action void Shoot(Name type, double ang = 0, double xy = 0, int height = 0, int flags = 0, double pitch = 0) {
        Actor it = A_FireProjectile(type,ang,false,xy,height,flags,pitch);
        if(it) {
            double pow; double multi;
            [pow, multi] = invoker.GetPower();
            int dmg = invoker.GetDamage(pow);
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
        }   
    }

    action void Reload() {
        // Not tied to "reloading". This just procs OnReload().
        A_StartSound("misc/w_pkup",8,volume:0.7,pitch:1.3);
        Inventory it = invoker.owner.inv;
        while (it) {
            let lit = LegendItem(it);
            if (lit) {
                lit.OnReload();
            }
            it = it.inv;
        }
    }

}

class LegendShot : Actor {
    // A projectile fired by a LegendWeapon.
    mixin SplashDamage;

    double power;
    int dmg;
    double precision; // What's the precision modifier?

    default {
        PROJECTILE;
        +FORCERADIUSDMG;
        Speed 40;
        DamageFunction (dmg);
    }

    override int DoSpecialDamage(Actor tgt, int dmg, name mod) {
        // If this was precision damage, spawn a special particle effect.
        if (precision > 1) {
            A_SpawnItemEX("PrecisionFlash");
        }
        return super.DoSpecialDamage(tgt,dmg,mod);
    }

}

class LegendFastShot : Actor {
    // FastProjectile for LegendWeapons.
    mixin SplashDamage;

    int dmg;
    double power;
    double precision; // What's the precision modifier?

    default {
        PROJECTILE;
        +FORCERADIUSDMG;
        Speed 40;
        DamageFunction (dmg);
    }

    override int DoSpecialDamage(Actor tgt, int dmg, name mod) {
        // If this was precision damage, spawn a special particle effect.
        if (precision > 1) {
            A_SpawnItemEX("PrecisionFlash");
        }
        return super.DoSpecialDamage(tgt,dmg,mod);
    }
}

class PrecisionFlash : Actor {
    default {
        +BRIGHT;
        +NOINTERACTION;
    }

    states {
        Spawn:
            APLS AB 5;
            TNT1 A 0;
            Stop;
    }
}

class LegendPuff : BulletPuff {
    // Needs +PUFFGETSOWNER to function correctly.
    default {
        +PUFFGETSOWNER;
    }
}