class LevelToken : Inventory {
    // Tracks monster levels.
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 999;
    }

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inflictor, Actor src, int flags) {
        // Each level adds 10% to the damage being dealt.
        if(!passive) {
            double multi = 1.0 + (owner.CountInv("LevelToken")*0.1);
            new = floor(dmg * multi);
            console.printf("Monster damage: "..dmg.." to "..new);
        }
    }
}

class LevelHealthItem : Inventory {
    // Handles giving monsters health when they get a LevelToken.

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
    }

    override bool HandlePickup (Inventory item) {
        if (item is "LevelToken") {
            owner.GiveBody(owner.GetSpawnHealth() * 0.1);
        }
        return false;
    }
}

class MonsterStaticHandler : StaticEventHandler {
    // Stores monster level during level transitions.

    int MonsterLevel;

    override void NetworkProcess(ConsoleEvent e) {
        // Receive the data!
        if (e.Name == "SaveMonsterLevel") {
            MonsterLevel = e.Args[0];
        }
    }

    override void WorldLoaded (WorldEvent e) {
        // Send a net event with the data!
        EventHandler.SendNetworkEvent("LoadMonsterLevel",MonsterLevel);
    }
}

class MonsterLevelHandler : EventHandler {
    // Increases monster level by 1 on certain events.

    int MonsterLevel;
    int ticktimer;
    int seconds;
    int minutes;

    override void NewGame() {
        MonsterLevel = 0;
        // console.printf("Resetting Monster Level!");
    }

    override void NetworkProcess(ConsoleEvent e) {
        // Receive the data!
        if (e.Name == "LoadMonsterLevel" && e.Args[0] != 0) {
            MonsterLevel = e.Args[0];
        }
    }

    override void WorldUnloaded(WorldEvent e) {
        // Send a net event with the data!
        SendNetworkEvent("SaveMonsterLevel",MonsterLevel);
    }

    override void WorldThingSpawned(WorldEvent e) {

        if (e.Thing.bISMONSTER) {
            e.Thing.GiveInventory("LevelHealthItem",1);
            // console.printf("Spawning "..e.Thing.GetClassName().." with level "..MonsterLevel+1);
        }
    }

    override void WorldTick() {
        // Increase monster level every 5 minutes of game time.
        ticktimer += 1;
        if (ticktimer >= 35 ) {
            ticktimer = 0;
            seconds += 1;
            // console.printf("MonsterLevel is "..MonsterLevel);
        }
        if (seconds >= 60) {
            seconds = 0;
            minutes += 1;
        }
        if (minutes >= 3) {
            minutes = 0;
            MonsterLevel += 1;
            console.printf("Monster Level increased to "..MonsterLevel+1);
        }

        // Iterate over all monsters, and update their levels.
        ThinkerIterator monsters = ThinkerIterator.Create("Actor",Thinker.STAT_DEFAULT);
        Actor mo;
        while(mo = Actor(monsters.next())) {
            if (mo.bISMONSTER && mo.CountInv("LevelToken") < MonsterLevel) {
                int diff = MonsterLevel - mo.CountInv("LevelToken");
                mo.GiveInventory("LevelToken",diff);
                // console.printf("Leveled "..mo.GetClassName().." to "..MonsterLevel+1);
            }
        }
    }
}