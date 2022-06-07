class Doomslayer : LegendPlayer {
    // They are rage, brutal, without mercy. But you...you will be worse.
    // High initial Power and good Precision scaling, but no Luck or Toughness by default.
    // The Great Communicator causes enemies to drop random ammo.
    // The Chaingun is a solid weapon that makes up for low damage with a chance of inflicting Pain.
    // The Super Shotgun does huge damage at close range, including Vorpal damage in a small AoE centered in front of the user.
    // The Plasma Rifle eats ammo rapidly, but has higher Power scaling.
    // The Rocket Launcher explodes for 5xPower damage in a 128 unit AoE.

    default {
        LegendPlayer.Power 47.6, 0.4;
        LegendPlayer.Precision -1.5, 1.5;
        LegendPlayer.Toughness 0.,0.;
        LegendPlayer.Luck 0.,0.;
        LegendPlayer.BonusHealth 0,0.5;

        Player.StartItem "GreenAmmo",60;
        Player.StartItem "RedAmmo",10;
        Player.StartItem "SlayerChaingun";
        Player.StartItem "SlayerSaw";
        Player.StartItem "SlayerShotgun";
        Player.StartItem "SlayerPlasma";
        Player.StartItem "SlayerLauncher";
    }
}

class BulletShot : LegendShot {
    // A small bullet projectile.

    default {
        Scale 0.5;
        Speed 80;
        Radius 2;
        Height 2;
    }

    states {
        Spawn:
            PUFF AB 3 Bright;
            Loop;
        Death:
        Crash:
            PUFF BCD 4;
            Stop;
        XDeath:
            TNT1 A 0;
            Stop;
    }
}

class PainBullet : BulletShot {
    // Every so often, the Chaingun fires a particularly pain-inducing bullet.
    override int DoSpecialDamage(Actor tgt, int dmg, Name type) {
        int diff = 17 - tgt.CountInv("Pain");
        tgt.A_GiveInventory("Pain",diff);
        return super.DoSpecialDamage(tgt,dmg,type);
    }
}

class PlasmaShot : LegendShot {
    // Slower, wider, more likely to melt your face.
    default {
        Radius 13;
        Height 8;
        Speed 30;
        DeathSound "weapons/plasmax";
    }

    states {
        Spawn:
            PLSS AB 5 Bright;
            Loop;
        Death:
            PLSE ABCDE 4 Bright;
            Stop;
    }
}

class RocketShot : LegendShot {
    // Big, slightly slower than PlasmaShot, but it explodes!
    default {
        Radius 13;
        Height 8;
        Speed 24;
        DeathSound "weapons/rocklx";
    }
    
    states {
        Spawn:
            MISL A 1;
            Loop;
        Death:
            MISL BC 4;
            MISL D 4 A_Explode(power*5,128);
            MISL E 4;
            TNT1 A 0;
            Stop;
    }
}

class VorpalSplash : LegendShot {
    // An invisible shockwave that bursts for Vorpal damage.

    default {
        Speed 25;
        Scale 0.5;
        RenderStyle "Add";
        +THRUACTORS;
    }

    states {
        Spawn:
            MISL BCD 2;
            MISL D 2 A_Explode(96, 96, XF_EXPLICITDAMAGETYPE,damagetype:"Vorpal");
            Stop;
    }
}

class SlayerSaw : LegendWeapon {
    // Chainsaw! The great communicator!
    // Damaging an enemy with this weapon gives them Efficiency.
    // Enemies who die while holding Efficiency drop some ammo.
    // Also, it hits for pow*0.15 every 4 ticks. It's like a slightly more powerful Chaingun, sort of!
    default {
        LegendWeapon.Damage 0., 0.15;
        Weapon.SlotNumber 1;
        Weapon.UpSound "weapons/sawup";
    }

    states {
        Select:
            SAWG C 1 A_Raise(35);
            Loop;
        Deselect:
            SAWG C 1 A_Lower(35);
            Loop;
        Ready:
            SAWG C 1 {
                A_WeaponReady();
                A_StartSound("weapons/sawidle");
            }
            SAWG CC 1 A_WeaponReady();
            SAWG D 1 {
                A_WeaponReady();
                A_StartSound("weapons/sawidle");
            }
            SAWG DD 1 A_WeaponReady();
            Loop;
        Fire:
            SAWG AB 4 {
                A_StartSound("weapons/sawhit");
                A_CustomPunch(invoker.GetDamage(),true,CPF_PULLIN);
                let tgt = invoker.owner.AimTarget();
                if(tgt && invoker.owner.Vec3To(tgt).length() < 64 + tgt.radius) {
                    tgt.GiveInventory("Efficiency",1);
                }
            }
            Goto Ready;
    }
}

class Efficiency : Inventory {
    // On owner death, spawns ammo and then removes itself.
    override void DoEffect() {
        if (owner.bISMONSTER && owner.health <= 0) {
            for (int i = random(1,3); i > 0; i--) {
                owner.Spawn("AmmoSpawner",owner.pos);
            }
            owner.A_TakeInventory("Efficiency",1);
        }
    }
}

class SlayerChaingun : LegendWeapon {
    // The chaingun attacks rapidly for 5+pow*0.1 damage with a small amount of spread.
    int stacks;
    int ammo;

    default {
        LegendWeapon.Damage 5, 0.1;
        Weapon.SlotNumber 2;
        Weapon.AmmoType "GreenAmmo";
        Weapon.AmmoUse 1;
    }

    action void PainBullet() {
        A_StartSound("weapons/chngun",pitch:1.1);
        Shoot("PainBullet",ang: frandom(-2,2),pitch: frandom(-1.0,1.0));
        invoker.stacks -= 5;
    }

    action void Bullet(bool accurate) {
        double multi = 1.;
        if (!accurate) {
            multi = 2.;
        }

        A_StartSound("weapons/chngun");
        Shoot("BulletShot",ang: frandom(-4,4)*multi,pitch: frandom(-1.5,0.5)*multi);
    }

    action void ChainBullet(bool accurate) {
        invoker.stacks += 1;
        if(invoker.stacks >= 5) {
            PainBullet();
        } else {
            Bullet(accurate);
        }
    }

    states {
        Select:
            CHGG A 1 A_Raise(35);
            Loop;
        Deselect:
            CHGG A 1 A_Lower(35);
            Loop;
        Ready:
            CHGG A 1 A_WeaponReady();
            Loop;
        Fire:
            CHGG A 1 {
                A_TakeInventory("GreenAmmo",1);
                invoker.ammo += 1;

                if(invoker.ammo >= 10) {
                    Reload();
                    invoker.ammo = 0;
                }

                ChainBullet(true);

                A_GunFlash();
            }
            CHGG A 1;
            CHGG B 1 {
                A_GunFlash("Flash2");
                if (GetPlayerInput(INPUT_BUTTONS) & BT_ALTATTACK) {
                    A_TakeInventory("GreenAmmo",1);
                    ChainBullet(false);
                }
            }
            CHGG B 1;
            CHGG B 0 A_Refire();
            Goto Ready;

        Flash:
            CHGF A 2 Bright A_Light1();
            Goto LightDone;
        Flash2:
            CHGF B 2 Bright A_Light2();
            Goto LightDone;
    }
}

class SlayerShotgun : LegendWeapon {
    // The shotgun fires 21 pellets, each of which does pow*0.16 damage. It also produces a blast in front of it that does Vorpal damage.

    default {
        LegendWeapon.Damage 0., 0.16;
        Weapon.SlotNumber 3;
        Weapon.AmmoType "RedAmmo";
        Weapon.AmmoUse 2;
    }

    states {
        Select:
            SHT2 A 1 A_Raise(35);
            Loop;
        Deselect:
            SHT2 A 1 A_Lower(35);
            Loop;
        Ready:
            SHT2 A 1 A_WeaponReady();
            Loop;
        Fire:
            SHT2 A 1 {
                A_StartSound("weapons/sshotf");
                A_TakeInventory("RedAmmo",2);
                for(int i = -5; i < 5; i++) {
                    Shoot("BulletShot",ang: i, pitch:frandom(-1,0));
                    Shoot("BulletShot",ang: i, pitch:frandom(0,1));
                }
                Shoot("VorpalSplash");
                A_GunFlash();
            }
            SHT2 A 7;
            SHT2 B 6;
            SHT2 C 6 A_CheckReload();
            SHT2 D 6 A_StartSound("weapons/sshoto");
            SHT2 E 6;
            SHT2 F 6 A_StartSound("weapons/sshotl");
            SHT2 G 5 Reload();
            SHT2 H 5 A_StartSound("weapons/sshotc");
            SHT2 A 4 A_Refire();
            Goto Ready;
        
        Flash:
            SHT2 I 4 Bright A_Light1();
            SHT2 J 3 Bright A_Light2();
            Goto LightDone;
    }
}

class SlayerPlasma : LegendWeapon {
    // The plasma rifle! Melts enemies like hot lightning through butter. Melts your ammo supply, too.

    int ammo;

    default {
        LegendWeapon.Damage 0., .6;
        Weapon.SlotNumber 4;
        Weapon.AmmoType "BlueAmmo";
        Weapon.AmmoUse 4;
    }

    states {
        Select:
            PLSG A 1 A_Raise(35);
            Loop;
        Deselect:
            PLSG A 1 A_Lower(35);
            Loop;
        Ready:
            PLSG A 1 A_WeaponReady();
            Loop;
        Fire:
            PLSG A 3 {
                A_StartSound("weapons/plasmaf");
                A_TakeInventory("BlueAmmo",4);
                invoker.ammo += 1;
                if(invoker.ammo >= 15) {
                    Reload();
                    invoker.ammo = 0;
                }
                Shoot("PlasmaShot");
                if (frandom(0,1) > 0.5) { A_GunFlash(); } else { A_GunFlash("Flash2"); }
            }
            PLSG B 0 A_Refire();
            PLSG B 16;
            Goto Ready;

        Flash:
            PLSF A 2 Bright A_Light1();
            Goto LightDone;
        Flash2:
            PLSF B 2 Bright A_Light1();
            Goto LightDone;
    }
}

class SlayerLauncher : LegendWeapon {
    // Fires rockets that impact for pow*1.0 damage and explode for up to pow*5.0 damage.
    int ammo;
    
    default {
        LegendWeapon.Damage 0., 1.;
        Weapon.SlotNumber 5;
        Weapon.AmmoType "YellowAmmo";
        Weapon.AmmoUse 5;
    }

    states {
        Select:
            MISG A 1 A_Raise(35);
            Loop;
        Deselect:
            MISG A 1 A_Lower(35);
            Loop;
        Ready:
            MISG A 1 A_WeaponReady();
            Loop;
        Fire:
            MISG B 1 {
                invoker.ammo += 1;
                if (invoker.ammo >= 3) {
                    Reload();
                    invoker.ammo = 0;
                }
                A_StartSound("weapons/rocklf");
                A_TakeInventory("YellowAmmo",5);
                Shoot("RocketShot");
                A_GunFlash();
            }
            MISG B 19;
            MISG B 0 A_Refire();
            Goto Ready;
        Flash:
            MISF A 3 Bright A_Light1();
            MISF B 4 Bright;
            MISF CD 4 Bright A_Light2();
            Goto LightDone;
    }
}