# Legends of Doom
A mod for GZDoom, inspired by Risk of Rain 2

## What?
This mod aims to implement mechanics and gameplay similar to Risk of Rain 2. In particular:

1. Damage values are based on your character's Power, multiplied by a scaling value. Your Power goes up when you level up, increasing all damage you do.
2. Weapon spawn spots contain Items, which grant passive effects of various kinds. Most of these are conditional in some way.

While I'm going to try and make the stuff in this mod as distinct as possible, there's definitely gonna be some items that are straight up borrowed from RoR2. (Things like Infusion or Focus Crystal are too good an idea to pass up.)

## Details

### Stats
All characters have the following stats:

Power: All damage scales off of Power. The stats you gain from leveling up vary between characters, but everyone gains some Power when leveling up.

Precision: As your Precision increases, you get a chance of temporarily doubling your Power when calculating damage. Once you start consistently getting double Power, you can start rolling for triple power.

Toughness: Toughness grants damage reduction. At 50 Toughness, you have ~50% damage reduction from all sources. Beyond that, diminishing returns start kicking in.

Luck: Modifies the chance of random rolls directly related to your character. However, it's capped at 50%. Or -50%, if you have *bad* luck...

Bonus Health: Most characters gain additional Health as they level up.

### Weapons
Characters start with all of their guns! You don't need to go hunting for weapons. Places where weapons spawn will instead spawn crates (I'll explain those later).

Weapons can use one of five ammo types: Green (replaces Clips), Red (replaces Shells), Yellow (replaces Rockets), Blue (replaces Cells), or Pink (special).

Green, Red, Yellow, and Blue function as you'd expect: picking up the color-coded ammo items gives you some ammo. Larger pickups will be unpacked into smaller ones when you walk over them, ensuring that you don't waste too much if you're nearly full on ammo. Picking up a backpack doubles your capacity for each type.

It's worth noting that, under the hood, every character has a capacity of 1000 for each ammo type. The ammo counter on the HUD calculates the number of shots remaining from the amount of ammo the weapon actually uses per shot. Small ammo pickups grant 25 ammo each, ammo bonuses grant 15 each, and large ammo pickups contain 5 small ammo pickups for a total of 125. It takes 8 boxes of any ammo type to go from empty to full, in other words.

Pink ammo, also known as Ultimate ammo or Ult ammo, is special; you gain Ult ammo in small amounts from picking up any other ammo type. In addition, Ult ammo capacity is not increased by backpacks.

### Other Pickups
#### Health
If your health goes higher than 100 + your max health, it will slowly drain back down to 100+max.

The stimpack and medkit heal 10% and 25% of your *maximum* health, respectively. As your max health increases, the benefit you gain from most forms of healing will also increase.

Health bonuses can overheal indefinitely, though they don't scale with max health.

Huge Medkits (which replace Soulspheres) overheal you for 100% of your max health.

#### Armor
Your max armor is the same as your max health. Increasing your max health will increase your max armor as well.

If your armor goes higher than 2x your max armor, it will slowly drain back down, much like health does.

The amount of damage absorbed by armor depends on how many armor points you have. At 30% of max armor or lower, armor will absorb 30% of damage. Above that, armor protection scales up, to 100% absorption when at 100% max armor or higher. Being above max armor is called being "Over-Armored". Some items will only trigger when absorbing 100% of damage with armor, while others will only trigger if health damage is taken.

Green armor will provide 75% of your max armor value. Blue armor will provide 150% of your max armor value. Picking up more armor will add it to your existing armor, rather than replacing it.

Armor bonuses provide 2 armor each and do not scale with your max armor value.

Red armor (which replaces the Megasphere) will provide 300% of your armor value.

#### Experience
Killing monsters causes them to drop experience, based on their total health. Monsters drop 0.1 experience for each point of health they spawned with.

The player levels up whenever their experience total reaches `100.0 * ((10 + (level * level)) / 10)`, where `level` is their current level. The simple version is that the difficulty of leveling up goes up exponentially as the player's level increases.

Monsters level up over time as well. At the start of a run, monsters gain 1 XP per second. Each additional monster level adds 0.05 to the XP gain per second, up to a maximum of 2.5 XP per second. Each time the monster XP total hits 150, monsters level up (this takes 2.5 minutes at level 1 and 1 minute at level 400).

In other words: Monster level will eventually outpace the player level.

Players gain stats on level-up based on their character class.

Monsters gain 10% additional damage and 10% additional HP each level.

The exact pace of leveling depends on the mapset and how many monsters you kill. Some items will also boost your XP gains in various ways. Slaughtermaps will be highly lucrative, while smaller, lower-monstercount maps may leave you underleveled.

#### Crates and Items
Crates spawn wherever a weapon normally spawns. Upon receiving enough damage, a crate will pop open, dropping a random item from its assigned tiers. Tiers are weighted, but items within tiers are not.

An item can belong to any number of tiers. This is how the Healing, Utility, Attack, and Defense chests work.

The following rarities are built into the core file:
- COMMON (white sparks): Random Weight of 70. The most common tier of item. Simple effects.
- RARE (Green sparks): Random Weight of 20. Typically contains advanced items that interact with COMMON items or have more complex effects.
- EPIC (Gold sparks): Random Weight of 5. Incredibly powerful items that make entirely new playstyles possible or radically buff you in some way.
- CURSED (FIREBLU sparks): Random Weight of 5. Strange and terrible magics await those who use the most eye-searing texture. Great power, but at a cost...
- HEALING: RW of 5. Contains items that can heal the player or improve their healing in some way.
- ATTACK: RW of 5. Contains items that can improve the player's damage output.
- DEFENSE: RW of 5. Contains items that make the player harder to kill, without necessarily providing/improving healing.
- UTILITY: RW of 5. Contains items that improve the player's ammo economy or XP gain, or items that provide other benefits that don't fit into Attack, Defense, or Healing.

The following crates are built into the core file:
- Regular Crate: White. Draws from the COMMON, RARE, and EPIC loot tables.
- Big Crate: Green. Draws from RARE and EPIC loot tables.
- !! Cursed !!: Red/Blue. Draws from CURSED loot table. Don't say I didn't warn you.
- Heal Crate: White/Red. Draws from the HEALING loot table.
- Attack Crate: Olive drab/Red. Draws from the ATTACK loot table.
- Defense Crate: Blue/White. Draws from the DEFENSE loot table.
- Utility Crate: Purple/White. Draws from the UTILITY loot table.