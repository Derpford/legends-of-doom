class TankJr : LegendPlayer {
    // A big stompy nasty cyborg.
    // Low Power/Precision growth; high Toughness growth and health growth.
    // Tank Jr passively gains a small amount of Power based on its current health percentage.
    // Two weapon 'modes', each with a primary and alternate fire. Weapons have lower individual power, but can be fired simultaneously.
    // Brawler mode's primary fire is a close-range flamethrower that rips through enemies. (Red Ammo)
    // Brawler mode's secondary fire is a 3-shot grenade burst. (Yellow Ammo)
    // Artillery mode's primary fire is a long-distance plasma lance, piercing enemies. (Blue Ammo)
    // Artillery mode's secondary fire is an autocannon that chugs along, firing accurate slugs that do greater single-target damage than the lance but are slower and have some arc to them. (Green Ammo)
    // Tank Jr.'s Ultimate is an experimental energy shield, covering an arc in front of it.
    // While active, it stores damage dealt to it, releasing that damage in a shockwave upon switching away from it, pressing the fire button, or running out of charge.
    // Damage storage happens pre-mitigation (specifically, in ModifyDamage), but ammo used is based on postmitigation damage (checked in TakeSpecialDamage).
    // This means that as Toughness increases, Tank Jr's ult lasts longer and potentially hits harder!
    default {
        LegendPlayer.Power 5,0.3;
        LegendPlayer.Precision 0,1.0;
        LegendPlayer.Toughness 10,1.0;
        LegendPlayer.Luck 1.0,0.0;
        LegendPlayer.BonusHealth 10,3;

        Player.DisplayName "Tank Jr";

        Player.StartItem "TankBrawler";
        Player.StartItem "RedAmmo", 300;
        Player.StartItem "YellowAmmo",150;
    }
}

class TankBrawler : LegendWeapon {
    // Contains the short-range configuration of the plasma lance, as well as a grenade launcher.
    const LEFT = 2;
    const RIGHT = 3; // Overlay layers.

    const SPACING = 64; // How far to the left/right the guns are.
    default {
        LegendWeapon.Damage 5, 1.0;

        Weapon.AmmoType1 "RedAmmo";
        Weapon.AmmoUse1 3;
        Weapon.AmmoType2 "YellowAmmo";
        Weapon.AmmoUse2 10;
    }

    action void PlasFire() {
        Shoot("PlasmaFire",frandom(-10,10));
        Shoot("PlasmaFire",frandom(-5,5));
        TakeAmmo();
    }

    action void GrenFire(double ang) {
        A_StartSound("weapons/grenlf");
        Shoot("TankGrenade",ang,pitch:-10,dscale:5.0);
        TakeAmmo(true);
    }

    states {
        Select:
            TNT1 A 0;
            TNT1 A 0 A_Overlay(RIGHT,"FlameReady");
            TNT1 A 0 A_OverlayOffset(RIGHT,SPACING,0);
            TNT1 A 0 A_Overlay(LEFT,"GrenadeReady");
            TNT1 A 0 A_OverlayOffset(LEFT,-SPACING,0);
        SelLoop:
            TNT1 A 1 A_Raise(35);
            Loop;
        
        DeSelect:
            TNT1 A 1 A_Lower(35);
            Loop;

        Ready:
            TNT1 A 1 A_WeaponReady();
            Loop;
        
        Fire:
        AltFire:
            TNT1 A 1;
            Goto Ready;
        
        FlameReady:
            DPFG A 1 A_DualFire("FlameShot");
            Loop;

        FlameShot:
            DPFF A 2 Bright PlasFire();
            DPFF B 2 Bright;
            DPFF C 2 Bright PlasFire();
            DPFF D 2 Bright;
            DPFF A 0 A_DualFire("FlameShot");
            DPFG B 5 Cycle();
            Goto FlameReady;
        
        GrenadeReady:
            DRLG A 1 A_DualFire("GrenadeShot",true);
            Loop;
        
        GrenadeShot:
            DRLF A 2 Bright GrenFire(-5);
            DRLF BC 1 Bright;
            DRLF A 2 Bright GrenFire(0);
            DRLF BC 1 Bright;
            DRLF A 2 Bright GrenFire(5);
            DRLF BCDE 1 Bright;
            DRLG B 4 Cycle();
            Goto GrenadeReady;
    }
}

class PlasmaFire : LegendShot {
    // A ripping plasma bolt.
    default {
        +RIPPER;
        Speed 20;
        RenderStyle "Add";
        Radius 4;
        Height 4;
    }

    states {
        Spawn:
            PLS2 AB 3 A_FadeOut();
            Loop;
        Death:
            PLS2 AB 3;
            BAL1 CDE 3;
            Stop;
    }
}

class TankGrenade : LegendShot {
    // A bouncy grenade.
    default {
        -NOGRAVITY;
        Speed 30;
        BounceType "Doom";
        BounceCount 3;
        DeathSound "weapons/rocklx";
        BounceSound "weapons/grbnce";
    }

    override int SpecialMissileHit(Actor victim) {
        return -1; // skip ripper logic
    }

    states {
        Spawn:
            MISL A 1;
            Loop;
        Death:
            MISL B 0 { invoker.bNOGRAVITY = true; }
            MISL BC 4 Bright;
            MISL D 4 Bright A_SplashDamage(power*10,128);
            MISL E 4 Bright;
            TNT1 A 0;
            Stop;
    }
}