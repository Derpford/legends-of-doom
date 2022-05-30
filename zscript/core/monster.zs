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

class MonsterStaticHandler : StaticEventHandler {
    // Stores monster level during level transitions.

    int MonsterLevel;
    bool hasData;

    override void NetworkProcess(ConsoleEvent e) {
        // Receive the data!
        if (e.Name == "SaveMonsterLevel") {
            MonsterLevel = e.Args[0];
            hasData = true;
        }
    }

    override void WorldThingSpawned (WorldEvent e) {
        // Send a net event with the data! But only if hasData.
        if (hasData) {
            hasData = false;
            EventHandler.SendNetworkEvent("LoadMonsterLevel",MonsterLevel);
        }
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
        console.printf("Resetting Monster Level!");
    }

    override void NetworkProcess(ConsoleEvent e) {
        // Receive the data!
        if (e.Name == "LoadMonsterLevel") {
            MonsterLevel = e.Args[0];
        }
    }

    override void WorldUnloaded(WorldEvent e) {
        // Send a net event with the data!
        SendNetworkEvent("SaveMonsterLevel",MonsterLevel);
    }

    override void WorldThingSpawned(WorldEvent e) {
        if (e.Thing.bISMONSTER) {
            double multi = 1.0 + (MonsterLevel * 0.1);
            e.Thing.GiveInventory("LevelToken",MonsterLevel);
            e.Thing.health = (e.Thing.GetSpawnHealth() * multi);            
            console.printf("Spawning "..e.Thing.GetClassName().." with level "..MonsterLevel+1);
        }
    }

    override void WorldTick() {
        // Increase monster level every 5 minutes of game time.
        ticktimer += 1;
        if (ticktimer >= 35 ) {
            ticktimer = 0;
            seconds += 1;
            console.printf("MonsterLevel is "..MonsterLevel);
        }
        if (seconds >= 60) {
            seconds = 0;
            minutes += 1;
        }
        if (minutes >= 5) {
            minutes = 0;
            MonsterLevel += 1;
            console.printf("Monster Level increased to "..MonsterLevel+1);
        }
    }
}