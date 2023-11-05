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
        Player.StartItem "TankShield";
        Player.StartItem "RedAmmo", 200;
        Player.StartItem "YellowAmmo",150;
        Player.StartItem "BlueAmmo",150;
        Player.StartItem "GreenAmmo",200;
        
        LegendPlayer.BFG "TankShield";
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
        owner.A_ClearOverlays(LEFT,RIGHT);
    }

}

class TankBrawler : TankDualWeapon {
    // Contains the short-range configuration of the plasma lance, as well as a grenade launcher.
    default {
        LegendWeapon.Damage 5, 1.0;

        Weapon.SlotNumber 3;
        Weapon.AmmoType1 "RedAmmo";
        Weapon.AmmoUse1 5;
        Weapon.AmmoType2 "YellowAmmo";
        Weapon.AmmoUse2 10;
    }

    action void PlasFire() {
        if (TakeAmmo()) {
            A_StartSound("weapons/plasmax",9);
            Shoot("PlasmaFire",-8);
            Shoot("PlasmaFire",-2);
            Shoot("PlasmaFire",8);
            Shoot("PlasmaFire",2);
        }
    }

    action void GrenFire(double ang) {
        if (TakeAmmo(true)) {
            A_StartSound("weapons/grenlf",10);
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
            DPFF A 3 Bright PlasFire();
            DPFF B 3 Bright;
            DPFG B 3;
            DPFF C 3 Bright PlasFire();
            DPFF D 3 Bright;
            DPFG B 3 Cycle();
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
        +BRIGHT;
        Speed 20;
        RenderStyle "Add";
        Radius 4;
        Height 4;
    }

    states {
        Spawn:
            PLS2 ABABA 3;
            BAL1 ABCDE 4;
        Death:
            BAL1 E 0;
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
        LegendWeapon.Damage 5, 2.5;

        Weapon.SlotNumber 2;
        Weapon.AmmoType1 "BlueAmmo";
        Weapon.AmmoUse1 5;
        Weapon.AmmoType2 "GreenAmmo";
        Weapon.AmmoUse2 3;
    }

    action void PlasFire() {
        if (TakeAmmo()) {
            A_StartSound("weapons/plasmaf",9);
            Shoot("PlasLance",base:10,dscale:5);
            Shoot("PlasLanceCore",base:10,dscale:5);
        }
    }

    action void CannonFire(double spread = 0) {
        if (TakeAmmo(true)) {
            A_StartSound("weapons/gatlf",10);
            Shoot("CannonShot",frandom(-spread,spread),pitch:-2 + (frandom(-spread,spread) * 0.5));
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
            DPGG B 3 Cycle();
            DPFG B 3;
            DPGG B 3;
            DPFG B 3;
            DPGG B 3;
            DPFG B 3;
            Goto PlasReady;
        
        CannonReady:
            DGTG A 1 A_DualFire("CannonShot",true);
            Loop;
        
        CannonShot:
        CannonRefire:
            DGTG A 1 A_StartSound("weapons/gatls",7);
            DGTF A 1 Bright CannonFire();
            DGTG BCDA 1;
            DGTF B 1 Bright CannonFire(1.5);
            DGTG BCD 1;
            DGTG ABCD 3 A_DualFire("CannonRefire",true);
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
        MissileType "PlasLanceTrail2";
        MissileHeight 8;
        RenderStyle "Add";
        Scale 0.5;
        Alpha 0.5;
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

class PlasLanceCore : PlasLance {
    // Same as the PlasLance shot, but only hits
    // the first enemy.
    default {
        Speed 100;
        Scale 1;
        -RIPPER;
        MissileType "PlasLanceTrail";
    }
}

class PlasLanceTrail : Actor {
    default {
        +NOINTERACTION;
        RenderStyle "Add";
        Alpha 0.3;
    }

    states {
        Spawn:
            PLSS AB 2;
            PLSE E 2;
            Stop;
    }
}

class PlasLanceTrail2 : Actor {
    default {
        +NOINTERACTION;
        RenderStyle "Add";
        Scale 1.3;
        Alpha 0.3;
    }

    states {
        Spawn:
            PLSS AB 2;
            Stop;
    }
}

class CannonShot : LegendFastShot {
    default {
        -NOGRAVITY;
        Speed 120;
        Scale 0.5;
        Gravity 0.5;
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

class TankShield : LegendWeapon {
    // An extremely unconventional weapon which absorbs incoming fire from the front.
    // Upon releasing this charge, Tank Jr. heals for a percentage of what it absorbed,
    // and releases a shockwave based on absorbed damage.
    // Ammo is consumed based on the damage absorbed, altered by Tank Jr.'s toughness.
    // However, charge is based on premitigation damage!
    // This means that this weapon gets more efficient as Toughness increases.
    mixin Lerps;
    mixin SplashDamage;

    default {
        Weapon.SlotNumber 6;
        Weapon.AmmoType1 "TankShieldCharge";
        Weapon.AmmoUse1 10; // Special ammo usage.
        // +Weapon.AMMO_OPTIONAL;
        // +FORCERADIUSDMG;
        Weapon.AmmoType2 "PinkAmmo";
        Weapon.AmmoUse2 1; // Special ammo usage.
        LegendWeapon.Damage 0,0.; // Nonstandard damage output.
    }

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inf, Actor src, int flags) {
        if (!passive) { return; }
        if ((owner.player.readyweapon is GetClassName())) { return; } // Only prevents damage while NOT selected.
        if (owner.CountInv("PinkAmmo") <= 0) { return ;}
        owner.A_StartSound("misc/tankshield",6);
        owner.GiveInventory("TankShieldCharge",dmg);
        let plr = LegendPlayer(owner);
        double div = 1.0;
        if (plr) {
            div = DimResist(plr.GetToughness(),50);
        }
        double nd = double(dmg) * div;
        console.printf("Ammo usage %d",floor(nd));
        owner.TakeInventory(ammotype2.GetClassName(),floor(nd));
        new = floor(nd * 0.2); // Absorb 80% of damage.
    }

    action void FireShockwave() {
        int amt = invoker.owner.GetMaxHealth(true);
        int healing = ceil((invoker.owner.GetMaxHealth(true) - invoker.owner.health) * 0.1); // 10% of missing health per shot
        double dist = 256 + (256 * (double(amt)/1000.));
        double mult = 1.0;
        target = invoker.owner; // gross hax to prevent selfdmg
        let plr = LegendPlayer(invoker.owner);
        if (plr) {
            plr.GiveHealth(healing);
            mult += plr.GetPower(true) * 0.01; // Every power is 1% additional damage.
        }
        // A_SplashDamage(amt,dist,ceil(amt*0.5),selfdmg: false);
        Shoot("TankShockwave",base:amt * mult);
        TakeAmmo();
        // invoker.owner.TakeInventory(invoker.ammotype1.GetClassName(),amt);
    }

    states {
        Select:
            DBFC AB 3 A_Raise(35);
            Loop;
        
        DeSelect:
            DBFG A 1 A_Lower(35);
            Loop;
        
        Ready:
            DBFC ABCDEF 2 Bright;
        ReadyLoop:
            DBFC GHIJ 2 Bright A_WeaponReady();
            Loop;
        
        Fire:
            DBFF A 3 Bright FireShockwave();
            DBFF B 3 Bright;
            DBFG C 3;
            DBFG BA 3 A_Refire();
            Goto Ready;
    }
}

class TankShieldCharge : Ammo {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1000;
    }
}

class TankShockwave : LegendShot {
    default {
        Radius 10;
        RenderStyle "Add";
        +BRIGHT;
    }

    states {
        Spawn:
            APLS AB 3;
            Loop;
        
        Death:
            BFE2 A 4 A_SplashDamage(dmg,128,floor(dmg * 0.5),"Plasma",false);
            BFE2 BCD 4;
            APBX ABCDE 3;
            Stop;
    }
}