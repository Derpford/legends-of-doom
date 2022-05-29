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
    }
}