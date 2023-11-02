class TankJr : LegendPlayer {
    // A big stompy nasty cyborg.
    // Low Power/Precision growth; high Toughness growth and health growth.
    // Tank Jr passively gains a small amount of Power based on its current health percentage.
    // Two weapon 'modes', each with a primary and alternate fire. Weapons have lower individual power, but can be fired simultaneously.
    // Brawler mode's primary fire is a close-range flamethrower that rips through enemies.
    // Brawler mode's secondary fire is a 3-shot grenade burst.
    // Artillery mode's primary fire is a long-distance plasma lance, piercing enemies.
    // Artillery mode's secondary fire is an autocannon that chugs along, firing accurate slugs that do greater single-target damage than the lance but are slower and have some arc to them.
    // Tank Jr.'s Ultimate is an experimental energy shield, covering an arc in front of it.
    // While active, it stores damage dealt to it, releasing that damage in a shockwave upon switching away from it, pressing the fire button, or running out of charge.
    // Damage storage happens pre-mitigation (specifically, in ModifyDamage), but ammo used is based on postmitigation damage (checked in TakeSpecialDamage).
    // This means that as Toughness increases, Tank Jr's ult lasts longer and potentially hits harder!
}