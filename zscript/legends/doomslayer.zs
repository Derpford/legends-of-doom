class Doomslayer : LegendPlayer {
    // They are rage, brutal, without mercy. But you...you will be worse.
    // High initial Power and good Precision scaling, but no Luck or Toughness by default.
    // The Great Communicator causes enemies to drop random ammo.
    // The Chaingun is a solid weapon that makes up for low damage with a chance of inflicting Pain.
    // The Super Shotgun does huge damage at close range, including Vorpal damage in a small AoE centered in front of the user.
    // The Plasma Rifle eats ammo rapidly, but has higher Power scaling.
    // The Rocket Launcher explodes for 5xPower damage in a 128 unit AoE.

    default {
        LegendPlayer.Power 48., 0.4;
        LegendPlayer.Precision 0., 1.5;
        LegendPlayer.Toughness 0.,0.;
        LegendPlayer.Luck 0.,0.;
        LegendPlayer.BonusHealth 0,0.5;

        Player.StartItem "SlayerChaingun";
    }
}

class SlayerChaingun : LegendWeapon {
    // The chaingun attacks rapidly for pow*0.1 damage with a small amount of spread.

    default {
        LegendWeapon.Damage 5, 0.1;
        Weapon.SlotNumber 2;
    }

    states {
        Select:
            CHGG A 1 A_Raise;
            Loop;
        Deselect:
            CHGG A 1 A_Lower;
            Loop;
        Ready:
            CHGG A 1 A_WeaponReady();
            Loop;
        Fire:
            CHGG A 1 {
                A_StartSound("weapons/chngun");
                Shoot("BulletShot",ang: frandom(-4,4),pitch: frandom(-1.5,1.5));
                A_GunFlash();
            }
            CHGG A 2;
            CHGG B 1;
            CHGG B 0 A_Refire();
            Goto Ready;

        Flash:
            CHGF A 1 Bright A_Light1();
            Goto LightDone;
    }
}

class BulletShot : LegendShot {
    // A small bullet projectile.

    default {
        Scale 0.5;
        Radius 2;
    }

    states {
        Spawn:
            PUFF AB 3 Bright;
            Loop;
        Death:
            PUFF BCD 4;
            Stop;
    }
}