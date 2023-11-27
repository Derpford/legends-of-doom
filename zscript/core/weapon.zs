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

    action state A_BtnCheck(StateLabel st, int btn) {
        // A generalized button check for weapons.
        int btns = GetPlayerInput(INPUT_BUTTONS);
        if (btns & btn) {
            return ResolveState(st);
        }
        return ResolveState(null);
    }

    action state A_DualFire(StateLabel st, bool alt = false) {
        // A helpful function for handling dual-wielding.
        int btns = GetPlayerInput(INPUT_BUTTONS);
        if (!alt) {
            if (invoker.CheckAmmo(PrimaryFire,false)) {
                return A_BtnCheck(st,BT_ATTACK);
            }
        } else {
            if (invoker.CheckAmmo(AltFire,false)) {
                return A_BtnCheck(st,BT_ALTATTACK);
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

    override bool CheckAmmo(int fireMode, bool autoSwitch, bool requireAmmo, int ammocount)
	{
        // Ended up having to copy in all this shit, because
        // there's no good way to ignore running out of ammo.
		int count1, count2;
		int enough, enoughmask;
		int lAmmoUse1;
        int lAmmoUse2 = AmmoUse2;

		if (sv_infiniteammo || (Owner.FindInventory ('PowerInfiniteAmmo', true) != null))
		{
			return true;
		}
		if (fireMode == EitherFire)
		{
			bool gotSome = CheckAmmo (PrimaryFire, false) || CheckAmmo (AltFire, false);
			if (!gotSome && autoSwitch)
			{
				PlayerPawn(Owner).PickNewWeapon (null);
			}
			return gotSome;
		}
		let altFire = (fireMode == AltFire);
		let optional = (altFire? bAlt_Ammo_Optional : bAmmo_Optional);
		let useboth = (altFire? bAlt_Uses_Both : bPrimary_Uses_Both);

		if (!requireAmmo && optional)
		{
			return true;
		}
		count1 = (Ammo1 != null) ? Ammo1.Amount : 0;
		count2 = (Ammo2 != null) ? Ammo2.Amount : 0;

		if (ammocount >= 0)
		{
			lAmmoUse1 = ammocount;
			lAmmoUse2 = ammocount;
		}
		else if (bDehAmmo && Ammo1 == null)
		{
			lAmmoUse1 = 0;
		}
		else
		{
			lAmmoUse1 = AmmoUse1;
		}

		enough = (count1 >= lAmmoUse1) | ((count2 >= lAmmoUse2) << 1);
		if (useboth)
		{
			enoughmask = 3;
		}
		else
		{
			enoughmask = 1 << altFire;
		}
		if (altFire && FindState('AltFire') == null)
		{ // If this weapon has no alternate fire, then there is never enough ammo for it
			enough &= 1;
		}
		if (((enough & enoughmask) == enoughmask) || (enough && bAmmo_CheckBoth))
		{
			return true;
		}
		// out of ammo, pick a weapon to change to
		// if (autoSwitch)
		// {
		// 	PlayerPawn(Owner).PickNewWeapon (null);
		// }
        // Sike, not gonna autoswitch ever.
		return false;
	}

    action bool TakeAmmo(bool alt = false,bool enough = true,int use = -1,bool forced = false) {
        // if(!alt) {
        //     A_TakeInventory(invoker.ammotype1,invoker.ammouse1);
        // } else {
        //     A_TakeInventory(invoker.ammotype2,invoker.ammouse2);
        // }
        // DepleteAmmo is used instead.
        return invoker.DepleteAmmo(alt,enough,use,forced);
    }

    action actor Shoot(Name type, double ang = 0, double xy = 0, int height = 0, int flags = 0, double pitch = 0, double power = -1, double base = -1, double dscale = -1, double mult = -1) {
        int shots = 1;
        let plr = LegendPlayer(invoker.owner);
        if (plr) {
            shots = plr.RollDown(plr.GetMultishot());
        }
        Actor first;
        for (int i = 0; i < shots; i++) {
            Actor it; Actor dummy;
            double spreadang = frandom(-i,i) * 0.25;
            double spreadpitch = frandom(-i,i) * 0.25;
            [dummy, it] = A_FireProjectile(type,ang+spreadang,false,xy,height,flags,pitch+spreadpitch);
            if(it) {
                double pow; double multi;
                [pow, multi] = invoker.GetPower();
                if (mult > 0) { multi = mult; }
                if (power > 0) { pow = power; }
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
            }
        }
        return first;
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

    override void Tick() {
        Super.Tick();
        // Handle gravity.
        vel.z -= GetGravity();
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