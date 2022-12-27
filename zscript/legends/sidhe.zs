class Sidhe : LegendPlayer {
    // It's pronounced 'Shee'.
    // This ancient master of the magical arts is also a skilled warrior and weaponsmith.
    // What the Sidhe lack in brute Power, they more than make up for with high Precision scaling and weapons that benefit greatly from it.
    // Each of the Sidhe's weapons also benefits from an alternate firing mode that consumes Pink Ammo for a more powerful version of its primary fire.
    // The Amethyst Wand is a variant of the Topaz Wand, rapidly firing projectiles with primary fire. It can fire without ammo, too.
    // Its altfire shoots a piercing beam of force that gains additional damage from Precision hits, but costs 25 pink ammo.
    // The Flamberge is a wide-angle flame launcher that ignites enemies on Precision Hit.
    // Its altfire is a flamethrower, guaranteeing an ignite at the cost of 2 pink ammo per shot.
    // The Dragon Gauntlet fires green bolts in a spread pattern, great for dealing with crowds.
    // Its altfire throws fewer bolts, but they fly straighter and explode on impact. Precision hits explode in a wider area. 10 pink ammo per shot.
    // The Skullmelter throws red-and-blue shards of pain given form in four-shot bursts. It makes a good long-distance weapon, and can also be swap-canceled.
    // Its altfire rapid-fires the painshards at the cost of 5 pink ammo per shot. With a full bar, this nukes single targets.

    default {
        LegendPlayer.Power 1, 0.2; // Much lower power scaling than the Doomslayer.
        LegendPlayer.Precision 5, 1.8; // Starts with more Precision and scales faster too.
        LegendPlayer.Toughness 0.,0.3; // Gradually gains Toughness...
        LegendPlayer.Luck 2.,0.; // And has a tiny bit of luck.
        LegendPlayer.BonusHealth 0,0.4; // Scales health slightly slower than Doomslayer.
    }
}

class SidheWand : LegendWeapon {
    default {
        LegendWeapon.Damage 0.,4.; // Less damage at level 1 than the chaingun, but hoo boy, when it hits...
        Weapon.SlotNumber 2;
        Weapon.AmmoType1 "GreenAmmo";
        Weapon.AmmoUse1 5;
        +Weapon.AMMO_OPTIONAL;
        Weapon.AmmoType2 "PinkAmmo";
        Weapon.AmmoUse2 25;
    }

    void FireWand() {
        // TODO: Fire projectile
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
            AWND B 3 Bright FireWand();
            AWND CD 4 Bright;
            Goto Ready;
    }
}