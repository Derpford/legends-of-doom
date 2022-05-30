class VorpalHandler : EventHandler {
    // Catches and modifies Vorpal damage to be based on the target's max HP.

    override void WorldThingDamaged (WorldEvent e) {
        if (e.DamageType is "Vorpal") {
            // All instances of Vorpal damage do 10% of the target's max HP.
            if (e.Thing.bISMONSTER) {
                // We have to calculate max HP from the target's level tokens.
                // Otherwise I'd have to build a custom monster set!
                int bhealth = e.Thing.GetSpawnHealth;
                int level = e.Thing.CountInv("LevelToken");

                e.Damage = floor((bhealth+(0.1*bhealth*level))*0.1);
            }
        }
    }
}