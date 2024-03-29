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
    double monsterxp;
    MonsterLevelThinker brain;
    bool braincheck; // Should we check for a MonsterLevelThinker?

    override void OnRegister() {
        // brain = MonsterLevelThinker.get();
        braincheck = false;
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
        // Each second, monsters gain 1 XP, plus 0.05 per level. This is capped at 2.5 XP (level 400).
        // At 150 XP (2.5 minutes the first time), they gain 1 level.
        if (!braincheck) {
            brain = MonsterLevelThinker.get();
            braincheck = true;
        }
        ticktimer += 1;
        if (ticktimer >= 35 ) {
            ticktimer = 0;
            brain.monsterxp += 1 + min(2.5,0.05 * brain.MonsterLevel);
        }
        if (brain.monsterxp >= 150) {
            brain.monsterxp -= 150;
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
    double monsterxp;
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
        if (!p) {
            p = new("MonsterLevelThinker");
            p.init();
        }

        return p;
    }
}