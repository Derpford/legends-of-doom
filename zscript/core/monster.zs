class LevelToken : Inventory {
    // Tracks monster levels.
    int level;
    MonsterLevelThinker brain;
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
    }

    override void PostBeginPlay () {
        super.PostBeginPlay();
        brain = MonsterLevelThinker.get();
    }

    override void Tick() {
        // Sync our level to the MonsterLevelThinker's level.
        super.Tick();
        level = brain.MonsterLevel;
    }

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inflictor, Actor src, int flags) {
        // Each level adds 10% to the damage being dealt.
        if(!passive) {
            double multi = 1.0 + (level*0.1);
            new = floor(dmg * multi);
        }
    }
}

class LevelHealthItem : Inventory {
    // Handles giving monsters health when they get a LevelToken.
    int level;
    MonsterLevelThinker brain;

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
    }

    override void PostBeginPlay() {
        super.PostBeginPlay();
        brain = MonsterLevelThinker.get();
    }

    override void Tick() {
        while (level < brain.MonsterLevel) {
            owner.GiveBody(owner.GetSpawnHealth() * 0.1);
            level += 1;
        }
    }

    // override bool HandlePickup (Inventory item) {
    //     if (item is "LevelToken") {
    //         owner.GiveBody(owner.GetSpawnHealth() * 0.1);
    //     }
    //     return false;
    // }
}

class MonsterLevelHandler : EventHandler {
    // Gives monsters a LevelHealthItem and a LevelToken. Also ticks the monster level.
    int ticktimer;
    int seconds;
    int minutes;
    MonsterLevelThinker brain;

    override void OnRegister() {
        brain = MonsterLevelThinker.get();
    }

    int MonsterMaxHealth(Actor it) {
        // Get the max health of a monster.
        LevelToken lt = LevelToken(it.FindInventory("LevelToken"));
        if (lt) {
            int lv = lt.level;
            double bhealth = it.GetSpawnHealth();
            double maxhealth = bhealth + (bhealth * 0.1 * lv);
            return floor(maxhealth);
        } else {
            return it.GetMaxHealth();
        }
    }

    override void WorldTick() {
        // Increase monster level every 3 minutes of game time.
        ticktimer += 1;
        if (ticktimer >= 35 ) {
            ticktimer = 0;
            seconds += 1;
        }
        if (seconds >= 60) {
            seconds = 0;
            minutes += 1;
        }
        if (minutes >= 3) {
            minutes = 0;
            brain.MonsterLevel += 1;
            console.printf("Monster Level increased to "..brain.MonsterLevel+1);
        }
    }

    override void WorldThingSpawned(WorldEvent e) {
        if (e.Thing.bISMONSTER) {
            e.Thing.GiveInventory("LevelHealthItem",1);
            e.Thing.GiveInventory("LevelToken",1);
            // console.printf("Spawning "..e.Thing.GetClassName().." with level "..MonsterLevel+1);
        }
    }
}

class MonsterLevelThinker : Thinker {
    // Tracks monster level. Increases monster level by 1 on certain events.

    int MonsterLevel;
    int ticktimer;
    int seconds;
    int minutes;

    MonsterLevelThinker init() {
        ChangeStatNum(STAT_STATIC);
        console.printf("Initialized monster leveling system");
        return self;
    }

    static MonsterLevelThinker get() {
        ThinkerIterator it = ThinkerIterator.create("MonsterLevelThinker",STAT_STATIC);
        let p = MonsterLevelThinker(it.next());
        if (p == null) {
            p = new("MonsterLevelThinker").init();
        }

        return p;
    }
}