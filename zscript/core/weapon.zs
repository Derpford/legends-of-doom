class LegendWeapon : Weapon {
    // A weapon held by a Legend.
    
    double BaseDmg; // Base damage of the projectile, for setting the bare minimum. Useful for weapons that are supposed to be strong early.
    double PowScale; // Multiplies Power to get final damage.

    Property Damage : BaseDmg, PowScale;

    default {
        LegendWeapon.Damage 0, 1.0;
    }

    int GetDamage() {
        // Since we might get a fractional damage value, use the fractional part as a chance of rounding up.
        int fpow;
        let plr = LegendPlayer(owner);
        if(!plr) { return 0; } // Something went wrong.
        double power = plr.GetPower();
        int bpow = floor(power);

        double c = (power - bpow)*100; // Percentage chance of getting the higher value

        if (plr.LuckRoll(c)) {
            return ceil(BaseDmg + (power*PowScale));
        } else {
            return floor(BaseDmg + (power*PowScale));
        }
    }

    action void Shoot(Name type, double ang = 0, double xy = 0, int height = 0, int flags = 0, double pitch = 0) {
        Actor it = A_FireProjectile(type,ang,false,xy,height,flags,pitch);
        if(it) {
            if (it is "LegendShot") {
                let it = LegendShot(it);
                it.power = invoker.GetDamage();
            } else if (it is "LegendFastShot") {
                let it = LegendFastShot(it);
                it.power = invoker.GetDamage();
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

    int power;

    default {
        PROJECTILE;
        +FORCERADIUSDMG;
        Speed 40;
        DamageFunction (power);
    }

}

class LegendFastShot : Actor {
    // FastProjectile for LegendWeapons.

    int power;

    default {
        PROJECTILE;
        +FORCERADIUSDMG;
        Speed 40;
        DamageFunction (power);
    }
}