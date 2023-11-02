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
        LegendPlayer.BonusHealth 0,3;
        Player.MaxHealth 110;

        Player.DisplayName "Tank Jr";

        Player.StartItem "TankPassive";
        Player.StartItem "TankBrawler";
        Player.StartItem "TankArty";
        Player.StartItem "RedAmmo", 200;
        Player.StartItem "YellowAmmo",150;
        Player.StartItem "BlueAmmo",150;
        Player.StartItem "GreenAmmo",200;
    }
}

class TankPassive : LegendItem {
    // Provides up to 5 Power based on current health.
    mixin Lerps;
    default {
        LegendItem.Icon "ARMBA0";
        Tag "Tank's Pride";
        LegendItem.Desc "Gain a small amount of power as health falls.";
        LegendItem.Remark "You're up against the wall!";
        LegendItem.Rarity "";
    }

    override string GetLongDesc() {
        return "Gain up to 5 Power (+5 per stack) based on your current health percentage. Maxes out at 30% health.";
    }

    override double GetPower() {
        double low = owner.GetMaxHealth(true) * 0.3;
        double high = owner.GetMaxHealth(true);
        double input = clamp(owner.health,low,high);
        return MapRange(input,high,low,0,5*GetStacks());
    }

}

class TankDualWeapon : LegendWeapon {
    const LEFT = 2;
    const RIGHT = 3; // Overlay layers.
    const SPACING = 64; // How far to the left/right the guns are.

    default {
        // +Weapon.AMMO_OPTIONAL;
        // +Weapon.NOAUTOSWITCHTO;
        Weapon.MinSelectionAmmo1 0;
        Weapon.MinSelectionAmmo2 0;
    }

    override void OwnerDied() {
        A_ClearOverlays();
    }

}

class TankBrawler : TankDualWeapon {
    // Contains the short-range configuration of the plasma lance, as well as a grenade launcher.
    default {
        LegendWeapon.Damage 5, 1.0;

        Weapon.SlotNumber 3;
        Weapon.AmmoType1 "RedAmmo";
        Weapon.AmmoUse1 3;
        Weapon.AmmoType2 "YellowAmmo";
        Weapon.AmmoUse2 10;
    }

    action void PlasFire() {
        if (TakeAmmo()) {
            Shoot("PlasmaFire",frandom(-10,10));
            Shoot("PlasmaFire",frandom(-5,5));
        }
    }

    action void GrenFire(double ang) {
        if (TakeAmmo(true)) {
            A_StartSound("weapons/grenlf");
            Shoot("TankGrenade",ang,pitch:-10,dscale:5.0);
        }
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

class TankArty : TankDualWeapon {
    // Combines a heavy autocannon with a plasma lance.
    default {
        LegendWeapon.Damage 5, 2.0;

        Weapon.SlotNumber 2;
        Weapon.AmmoType1 "BlueAmmo";
        Weapon.AmmoUse1 5;
        Weapon.AmmoType2 "GreenAmmo";
        Weapon.AmmoUse2 2;
    }

    action void PlasFire() {
        if (TakeAmmo()) {
            A_StartSound("weapons/plasmaf");
            Shoot("PlasLance",base:0,dscale:5);
        }
    }

    action void CannonFire() {
        if (TakeAmmo(true)) {
            A_StartSound("weapons/gatlf");
            Shoot("CannonShot",pitch:-5);
        }
    }

    states {
        Select:
            TNT1 A 0;
            TNT1 A 0 A_Overlay(RIGHT,"PlasReady");
            TNT1 A 0 A_OverlayOffset(RIGHT,SPACING,0);
            TNT1 A 0 A_Overlay(LEFT,"CannonReady");
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
        
        PlasReady:
            DPGG A 1 A_DualFire("PlasShot");
            Loop;

        PlasShot:
            DPGF A 2 Bright PlasFire();
            DPGF B 2 Bright;
            DPGF C 2 Bright;
            DPGF D 2 Bright;
            DPGG B 5 Cycle();
            DPFG B 5;
            DPGG B 5;
            DPFG B 5;
            DPGG B 5;
            DPFG B 5;
            Goto PlasReady;
        
        CannonReady:
            DGTG A 1 A_DualFire("CannonShot",true);
            Loop;
        
        CannonShot:
            DGTG A 2 A_StartSound("weapons/gatls",7);
            DGTF A 1 Bright CannonFire();
            DGTF B 1 Bright;
            DGTG BCD 1;
            DGTG ABCD 3 A_DualFire("CannonShot",true);
            DGTG A 4 Cycle();
            Goto CannonReady;
    }
}

class PlasLance : LegendFastShot {
    // A powerful railgun-like blast of plasma.
    default {
        +RIPPER;
        +BRIGHT;
        Speed 120;
        MissileType "PlasLanceTrail";
        MissileHeight 8;
        RenderStyle "Add";
    }

    states {
        Spawn:
            PLSS AB 3;
            Loop;
        Death:
            PLSE ABCDE 3;
            Stop;
    }
}

class PlasLanceTrail : Actor {
    default {
        +NOINTERACTION;
        RenderStyle "Add";
        Scale 0.5;
    }

    states {
        Spawn:
            PLSE ABCDE 2;
            Stop;
    }
}

class CannonShot : LegendShot {
    default {
        -NOGRAVITY;
        Speed 80;
        Scale 0.5;
    }

    states {
        Spawn:
            MISL A 1;
            Loop;
        
        Death:
            MISL B 0 { invoker.bNOGRAVITY = true; }
            MISL BCD 3;
            Stop;
    }
}