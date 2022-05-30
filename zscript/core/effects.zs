class VorpalHandler : EventHandler {
    // Catches and modifies Vorpal damage to be based on the target's max HP.

    override void WorldThingSpawned (WorldEvent e) {
        // Give all players and monsters the VorpalModifier.
        if (e.Thing.bISMONSTER || e.Thing is "PlayerPawn") {
            e.Thing.GiveInventory("VorpalModifier",1);
        }
    }
}

class VorpalModifier : Inventory {
    // Uses ModifyDamage to apply Vorpal effects.

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inflictor, Actor src, int flags) {
        if(passive && type == "Vorpal") {
            if(owner is "LegendPlayer") {
                int amt = floor(owner.GetMaxHealth() * 0.1);
                new = amt;
            } else {
                // We have to calculate max HP from the target's level tokens.
                // Otherwise I'd have to build a custom monster set!
                double bhealth = owner.GetSpawnHealth();
                double level = owner.CountInv("LevelToken");
                double maxhealth = bhealth + (0.1*bhealth*level);
                console.printf("Vorpal hit for "..maxhealth*0.1.." damage!");
                new = floor(maxhealth*0.1);

            }
        }
    }
}

class Pain : Inventory {
    // Flinches the target for a certain number of frames.

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
    }

    override void DoEffect() {
        if (owner.health > 0 && !owner.bCORPSE && owner.ResolveState("pain") && !InStateSequence(owner.curstate,owner.ResolveState("Pain"))) {
            owner.SetState(owner.ResolveState("Pain"));
        }
        owner.A_TakeInventory("Pain",1);
    }
}