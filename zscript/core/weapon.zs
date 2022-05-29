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
        double power = owner.GetPower();
        int bpow = floor(power);

        double c = (power - bpow)*100; // Percentage chance of getting the higher value

        if (owner.LuckRoll(c)) {
            return ceil(BaseDmg + (power*PowScale));
        } else {
            return floor(BaseDmg + (power*PowScale));
        }
    }

    action void Shoot(Name type, double ang = 0, double xy = 0, int height = 48, int flags = 0, double pitch = 0) {
        Actor it = A_FireProjectile(type,ang,false,xy,height,flags,pitch);
        if(it && (it is LegendShot)) {
            let it = LegendShot(it);
            it.power = invoker.GetDamage();
        }
    }

}

class LegendShot : Actor {
    // A projectile fired by a LegendWeapon.

    int power;

    default {
        PROJECTILE;
        DamageFunction (GetDamage());
    }

}