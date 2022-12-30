class Sidhe : LegendPlayer {
    // It's pronounced 'Shee'.
    // This ancient master of the magical arts is also a skilled warrior and weaponsmith.
    // What the Sidhe lack in brute Power, they more than make up for with high Precision scaling and weapons that benefit greatly from it.
    // Each of the Sidhe's weapons also benefits from an alternate firing mode that consumes Pink Ammo for a more powerful version of its primary fire.
    // The Amethyst Wand is a variant of the Topaz Wand, rapidly firing projectiles with primary fire. It can fire without ammo, too.
    // Its altfire shoots a piercing beam of force that gains additional damage from Precision hits, but costs 125 pink ammo.
    // The Flamberge is a wide-angle flame launcher that ignites enemies on Precision Hit.
    // Its altfire is a flamethrower, guaranteeing an ignite at the cost of 10 pink ammo per shot.
    // The Dragon Gauntlet fires green bolts in a spread pattern, great for dealing with crowds.
    // Its altfire throws fewer bolts, but they fly straighter and explode on impact. Precision hits explode in a wider area. 25 pink ammo per shot.
    // The Skullmelter throws red-and-blue shards of pain given form in four-shot bursts. It makes a good long-distance weapon, and can also be swap-canceled.
    // Its altfire rapid-fires the painshards at the cost of 50 pink ammo per shot. With a full bar, this nukes single targets.

    default {
        LegendPlayer.Power 3, 0.2; // Much lower power scaling than the Doomslayer.
        LegendPlayer.Precision 5, 1.8; // Starts with more Precision and scales faster too.
        LegendPlayer.Toughness 0.,0.3; // Gradually gains Toughness...
        LegendPlayer.Luck 2.,0.; // And has a tiny bit of luck.
        LegendPlayer.BonusHealth 0,1.5; // Scales health slightly slower than Doomslayer.

        Player.DisplayName "Sidhe";

        Player.StartItem "BlueAmmo", 200;
        Player.StartItem "RedAmmo", 200;
        Player.StartItem "SidheWand";
        Player.StartItem "SidheFlamberge";
        Player.StartItem "SidheGauntlet";
        Player.StartItem "SidheHellmouth";
    }
}

class SidheWand : LegendWeapon {
    default {
        LegendWeapon.Damage -1.,3.; // Less DPS at level 1 than the chaingun, but hoo boy, when it hits...
        Weapon.SlotNumber 2;
        Weapon.AmmoType1 "BlueAmmo";
        Weapon.AmmoUse1 5;
        +Weapon.AMMO_OPTIONAL;
        Weapon.AmmoType2 "PinkAmmo";
        Weapon.AmmoUse2 125;
    }

    action void FireWand() {
        // TODO: Fire projectile
        A_StartSound("weapon/awandf");
        if (CountInv(invoker.ammotype1) > invoker.ammouse1) {
            TakeAmmo();
            Shoot("AmethystBolt");
            Shoot("AmethystBolt",xy:-8,height:-4);
            Shoot("AmethystBolt",xy:8,height:-4);
        } else {
            Shoot("AmethystBolt");
        }
    }

    action void FireBolt() {
        TakeAmmo(true);
        double pow; double mult;
        [pow, mult] = invoker.GetPower();
        if (mult > 1.) {
            // Precision hits gain a 1.5x power boost.
            pow *= 1.5;
        }

        int dmg = invoker.GetDamage(pow);
        A_RailAttack(dmg * 10,0,false,"9356a3","413c5a",RGF_FULLBRIGHT,8);
    }

    states {
        Select:
            AWND A 1 A_Raise(35);
            Loop;
        DeSelect:
            AWND A 1 A_Lower(35);
            Loop;

        Ready:
            AWND A 1 A_WeaponReady();
            Loop;
        
        Fire:
            AWND B 3 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            AWND B 0 Bright FireWand();
            AWND C 4 Bright A_WeaponOffset(0,33,WOF_INTERPOLATE);
            AWND D 3 Bright A_WeaponOffset(0,32,WOF_INTERPOLATE);
            AWND D 0 Reload();
            Goto Ready;
        
        AltFire:
            AWND C 4 A_WeaponOffset(0,40,WOF_INTERPOLATE);
            AWND C 0 Bright FireBolt();
            AWND B 5 Bright A_WeaponOffset(0,34,WOF_INTERPOLATE);
            AWND D 6 Bright A_WeaponOffset(0,32,WOF_INTERPOLATE);
            AWND EF 6 Bright;
            Goto Ready;
    }
}

class AmethystBolt : LegendShot {
    // A bolt of force and heat.
    default {
        Radius 6;
        Height 2;
        Speed 60;
        +BRIGHT;
        DeathSound "weapon/awandx";
    }

    states {
        Spawn:
            CHFR ABCB 3 A_SpawnItemEX("AmethystTrail");
            Loop;
        Death:
            CHFR ABCDEFGHIJKLMNOP 2;
            TNT1 A 0;
            Stop;
    }
}

class AmethystTrail : Actor {
    default {
        +NOINTERACTION;
        // +NOGRAVITY;
        +BRIGHT;
        RenderStyle "Translucent";
        Alpha 0.4;
    }

    states {
        Spawn:
            CHFR CBA 3;
            TNT1 A 0;
            Stop;
    }
}

class SidheFlamberge : LegendWeapon {
    default {
        LegendWeapon.Damage 0.,5;
        Weapon.SlotNumber 3;
        Weapon.AmmoType1 "RedAmmo";
        Weapon.AmmoUse1 10;
        Weapon.AmmoType2 "PinkAmmo";
        Weapon.AmmoUse2 10;
    }

    action void FireBalls() {
        TakeAmmo();
        for (int i = -2; i < 2; i++) {
            Shoot("FlambergeBall",ang: (i * 8)+4);
        }
        A_StartSound("weapons/flameswordswing");
    }

    action void FireThrower() {
        TakeAmmo(true);
        A_StartSound("weapon/flambef",1,flags:CHANF_LOOPING);
        Shoot("FlambergeFlames",ang:frandom(-5,5),pitch:frandom(0,-5));
    }

    states {
        Select:
            SRDF AAA 1 A_Raise(35);
            SRDI BBBCCC 1 A_Raise(35);
            Loop;
        DeSelect:
            SRDG AAA 1 A_Lower(35);
            SRDI BBBCCC 1 A_Lower(35);
            Loop;

        Ready:
            SRDF AAA 1 A_WeaponReady();
            SRDI BBBCCC 1 A_WeaponReady();
            Loop;
        
        Fire:
            SRDF BC 2;
        Swing:
            SRDF FGHIJ 1;
            SRDF K 1 FireBalls();
            SRDF LM 1;
            TNT1 A 4;
            TNT1 A 4 A_Refire("Backswing");
            SRDF CB 1;
            Goto Ready; 
        
        Backswing:
            SRDF NOPQR 1;
            SRDF S 1 FireBalls();
            SRDF TUV 1;
            TNT1 A 4 Reload();
            TNT1 A 4 A_Refire("Swing");
            SRDF CB 1;
            Goto Ready;

        Altfire:
            SRDF BC 2;
            SRDF NOPQR 1;
            SRDF S 0 A_StartSound("weapon/awandx",2);
        AltHold:
            SRDF S 1 FireThrower();
            SRDG S 1 {
                let btn = GetPlayerInput(INPUT_BUTTONS);
                if (btn & BT_ALTATTACK && CountInv(invoker.ammotype2) >= invoker.ammouse2) {
                    return ResolveState("AltHold");
                } else {
                    return ResolveState(null);
                }
            }
        AltEnd:
            SRDF R 1 A_StopSound(1);
            SRDF QPON 1;
            TNT1 A 6;
            SRDF CB 2;
            Goto Ready;
    }
}

class FlambergeBall : LegendShot {
    default {
        RenderStyle "Add";
        Scale 0.5;
        Speed 50;
        +BRIGHT;
    }

    override int DoSpecialDamage(Actor tgt, int dmg, Name mod) {
        if (precision > 1.) {
            tgt.GiveInventory("Burn",floor(precision/2));
        }
        return super.DoSpecialDamage(tgt,dmg,mod);
    }

    states {
        Spawn:
            MANF AB 3;
            Loop;
        Death:
            MISL BCD 4;
            Stop;
    }
}

class FlambergeFlames : LegendShot {
    default {
        RenderStyle "Add";
        Speed 30;
        +BRIGHT;
        +RIPPER;
    }

    override int DoSpecialDamage(Actor tgt, int dmg, Name mod) {
        tgt.GiveInventory("Burn",floor(precision));
        return super.DoSpecialDamage(tgt,dmg,mod);
    }

    states {
        Spawn:
            MANF ABABABAB 4;
        Death:
            MISL BCD 5;
            Stop;
    }
}

class SidheGauntlet : LegendWeapon {
    int cycle;

    default {
        LegendWeapon.Damage 0.,2;
        Weapon.SlotNumber 4;
        Weapon.AmmoType1 "GreenAmmo";
        Weapon.AmmoUse1 10;
        Weapon.AmmoType2 "PinkAmmo";
        Weapon.AmmoUse2 25;
    }

    action void CycleGauntlet() {
        invoker.cycle += 1;
        if (invoker.cycle > 2) {
            Reload();
            invoker.cycle = 0;
        }
    }
    action void FireSpread() {
        // Figure out a good firing sound for this?
        A_StartSound("weapon/dragonf");
        TakeAmmo();
        for (int i = -2; i < 3; i++) {
            Shoot("DragonShot", ang: i * 2, xy: i * 4);
        }
    }

    action void FireNades() {
        A_StartSound("weapon/dragonf2");
        TakeAmmo(true);
            Shoot("DragonNade", ang: frandom(-6,6));
    }

    action state ClawIdle() {
        if (frandom(0,1) < 0.005) {
            return ResolveState("Idle");
        } else {
            return ResolveState(null);
        }
    }

    states {
        Select:
            CLAW A 1 A_Raise(35);
            Loop;
        DeSelect:
            CLAW A 1 A_Lower(35);
            Loop;

        Ready:
            CLAW A 1 A_WeaponReady();
            CLAW A 0 ClawIdle();
            Loop;
        
        Idle:
            CLAW EEEFFFGGGHHHIII 1 Bright A_WeaponReady();
            CLAW HHHGGGFFFEEE 1 Bright A_WeaponReady();
            Goto Ready;
        
        Fire:
            CLAW D 2 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            CLAW D 0 Bright FireSpread();
            CLAW B 3 Bright A_WeaponOffset(0,34,WOF_INTERPOLATE);
            CLAW C 2 Bright A_WeaponOffset(0,33,WOF_INTERPOLATE);
            CLAW C 0 CycleGauntlet();
            Goto Ready;

        AltFire:
            CLAW BC 3 Bright A_WeaponOffset(frandom(-5,5),35,WOF_INTERPOLATE);
            CLAW D 2 Bright FireNades();
            CLAW A 1 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            Goto Ready;
    }
}

class DragonShot : LegendShot {
    // Deliberately did NOT call them DragonBalls.
    default {
        RenderStyle "Add";
        +BRIGHT;
        DeathSound "weapon/awandx";
    }

    states {
        Spawn:
            PLS1 AB 3;
            Loop;
        
        Death:
            PLS1 CDEFG 4;
            Stop;
    }
}

class DragonNade : LegendShot {
    default {
        RenderStyle "Add";
        Scale 2;
        +BRIGHT;
        DeathSound "weapon/dragonx";
    }

    action void DragonExplode() {
        double rad = 128;
        if (invoker.precision > 1) {
            double mult = 1 + (0.5 * (invoker.precision - 1)); // i.e., at 2 the multiplier is 1.5
            rad *= mult;
        }

        A_SplashDamage(invoker.power * 20,rad,selfdmg: false);
    }

    states {
        Spawn:
            PLS1 AB 5;
            Loop;
        Death:
            PLS1 C 6 { invoker.bNOGRAVITY = true; }
            PLS1 D 6 DragonExplode();
            PLS1 EFG 5;
            Stop;
    }
}

class SidheHellmouth : LegendWeapon {

    default {
        LegendWeapon.Damage 0.,12;
        Weapon.SlotNumber 5;
        Weapon.AmmoType1 "YellowAmmo";
        Weapon.AmmoUse1 25;
        Weapon.AmmoType2 "PinkAmmo";
        Weapon.AmmoUse2 25;
    }

    action void FirePain() {
        // Ouch.
        A_StartSound("weapon/dragonf2");
        Shoot("FirebluShard",xy: -8);
        Shoot("FirebluShard",xy: 8);
        TakeAmmo();
    }

    action void FireMorePain() {
        // OUCH.
        A_StartSound("weapon/dragonf2");
        Shoot("FirebluShard",ang:frandom(-2,2),xy: -8);
        Shoot("FirebluShard",ang:frandom(-2,2),xy: 8);
        TakeAmmo(true);
    }

    states {
        Select:
            DSKL A 1 A_Raise(35);
            Loop;
        DeSelect:
            DSKL A 1 A_Lower(35);
            Loop;

        Ready:
            DSKL A 1 A_WeaponReady();
            Loop;
        
        Fire:
            DSKL B 3 Bright A_WeaponOffset(frandom(-12,12),40,WOF_INTERPOLATE);
            DSKL B 0 FirePain();
            DSKL A 1 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            DSKL C 3 Bright A_WeaponOffset(frandom(-12,12),40,WOF_INTERPOLATE);
            DSKL C 0 FirePain();
            DSKL A 1 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            DSKL DEF 4 Bright;
            DSKL IHG 4 Bright;
            Goto Ready;
        
        AltFire:
            DSKL G 0 A_StartSound("weapon/dragonx");
            DSKL GHI 4 Bright;
            DSKL FED 4 Bright;
        AltHold:
            DSKL B 2 Bright A_WeaponOffset(frandom(-16,16),36,WOF_INTERPOLATE);
            DSKL B 0 FireMorePain();
            DSKL A 1 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            DSKL C 2 Bright A_WeaponOffset(frandom(-16,16),36,WOF_INTERPOLATE);
            DSKL C 0 FireMorePain();
            DSKL A 1 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            DSKL A 0 A_Refire();
            Goto Ready;
    }
}

class FirebluShard : LegendShot {
    default {
        RenderStyle "Add";
        +BRIGHT;
        +HITTRACER;
        DeathSound "weapon/awandx";
    }

    action void SpawnShrapnel() {
        if (!tracer) { return; }
        for (int i = 0; i < 9; i++) {
            vector3 spos = invoker.tracer.Vec3Angle(invoker.tracer.radius * 1.8,i * 45,invoker.tracer.height / 2.);
            let it = FirebluShrapnel(invoker.tracer.Spawn("FirebluShrapnel",spos));
            if (it) {
                it.target = invoker.target;
                it.power = invoker.power;
                it.dmg = invoker.dmg / 2;
                it.precision = invoker.precision;
                it.VelFromAngle(it.speed,i * 45);
            }
        }
    }

    states {
        Spawn:
            PLSS AB 4;
            PLS2 AB 4;
            Loop;
        Death:
            PLSE A 2 SpawnShrapnel();
            BAL1 C 2;
            PLSE B 2;
            BAL1 D 2;
            PLSE C 2;
            BAL1 E 2;
            PLSE DE 2;
            Stop;
    }
}

class FirebluShrapnel : LegendShot {
    default {
        RenderStyle "Add";
        +BRIGHT;
        DeathSound "weapon/awandx";
        ReactionTime 3;
        Speed 10;
    }

    states {
        Spawn:
            PLSS A 0 A_CountDown();
            PLSS AB 4;
            PLS2 AB 4;
            Loop;
        Death:
            PLSE A 2;
            BAL1 C 2;
            PLSE B 2;
            BAL1 D 2;
            PLSE C 2;
            BAL1 E 2;
            PLSE DE 2;
            Stop;
    }

}