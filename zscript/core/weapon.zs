class LegendWeapon : Weapon {
    // A weapon held by a Legend.

}

class LegendShot : Actor {
    // A projectile fired by a LegendWeapon.
    
    double BaseDmg; // Base damage of the projectile, for setting the bare minimum. Useful for weapons that are supposed to be strong early.
    double PowScale; // Multiplies Power to get final damage.

    Property Damage : BaseDmg, PowScale;

    default {
        PROJECTILE;
        DamageFunction (GetDamage());
        LegendShot.Damage 0, 1.0;
    }

    int GetDamage() {
        // Since we might get a fractional damage value, use the fractional part as a chance of rounding up.
        int fpow;
        double power = target.GetPower();
        int bpow = floor(power);

        double c = (power - bpow)*100; // Percentage chance of getting the higher value

        if (target.LuckRoll(c)) {
            return ceil(BaseDmg + (power*PowScale));
        } else {
            return floor(BaseDmg + (power*PowScale));
        }
    }
}