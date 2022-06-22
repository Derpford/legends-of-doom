class WaveSpawnHandler : StaticEventHandler {
    // Handles the moment-to-moment details of spawning monsters.
    mixin LumpParser;

    bool initialized; // Some stuff has to happen AFTER OnRegister.

    int tickTimer;
    int seconds;
    int spawnTimeLimit;

    int wave;
    int difficulty; // increments whenever a Boss is killed.
    int spawncap; // How many monsters do we spawn each time? Multiplied by difficulty to get the actual cap.
    int bosswave; // Waves that are a multiple of bosswave spawn a boss.

    Array<String> spawns; // Fills up with things to spawn.
    Name bosstype; // What kind of monster is our current boss?
    Actor boss; // A pointer to The Boss!
    bool bossSpawned; // Has the boss for this wave been spawned?
    bool bossKilled; // Has it been killed yet?

    double spawnTokens; // What's our budget for spawning monsters?

    Dictionary spawnList; // What's the cost of spawning monsters?

    ThinkerIterator spawnSpots; // Persists so that spawns can be spread across multiple tics.
    ThinkerIterator bossSpots; // The same, but for boss spots specifically.

    void Initialize() {
        spawnSpots = ThinkerIterator.Create("SpawnMonster");
        bossSpots = ThinkerIterator.Create("SpawnBoss");
        SpawnItems();
        initialized = true;
        spawnList = Dictionary.Create();
        LumpToDict("MONSPAWN",spawnList); // Should take the form of { "ClassName" : "1.0" } where 1.0 is the cost of spawning
        spawnTimeLimit = 30; // Every 30 seconds, try to add more monsters to the spawnlist.
        seconds = 5; // Start with 5s before the first wave.
        tickTimer = 35;
        spawncap = 25;
        bosswave = 5;
        boss = null;

        wave = 0;
        difficulty = 0;
    }

    void MakeNewSpawns () {
        // Firstly, increment the wave number.
        wave += 1;
        // And calculate our spawnTokens from the current wave.
        spawnTokens += wave * 0.5;
        // Also, tell the players a new wave has started.
        String wavemsg = String.Format("Wave %d incoming!",wave);
        if (wave % bosswave == 0) { wavemsg = wavemsg.."\n BOSS TIME!"; }
        Console.MidPrint(Font.GetFont("BIGFONT"),wavemsg,true);
        // Now we populate an array with the keys of the spawnList so we can randomly select them.
        // We only use monsters whose cost is lower than our SpawnTokens, though! Later, we'll remove entries as they become too expensive.
        // If this is a wave multiple of 10, we also need to spawn a 'boss'.
        double bosscost = -1;
        Array<String> monsters;
        DictionaryIterator it = DictionaryIterator.Create(spawnList);
        while (it.next()) {
            double cost = it.value().toDouble();
            double modcost = cost - difficulty;
            if (cost <= -1) { continue; } 
            // You can use a cost of -1 to disable a monster.
            if (modcost > spawnTokens) { continue; }
            // Skip monsters that cost too much.
            monsters.push(it.key());
            if (wave % bosswave == 0 && cost > bosscost) {
                // The boss is always the highest-cost thing we can afford.
                console.printf("Set boss to "..it.key());
                bosscost = cost;
                bossType = it.key();
            }
        }
        
        // Now we need to populate spawns with a bunch of monsters.
        while (monsters.size() > 0 && spawns.size() < (spawncap + (spawncap * difficulty))) {
            // Pick a random monster from the monsters list!
            int idx = random(0,monsters.size()-1);
            Name mon = monsters[idx];
            double cost = spawnList.at(mon).ToDouble(); 
            double modcost = cost - difficulty;
            if (modcost > spawnTokens) {
                // This monster costs too much!
                monsters.delete(idx);
                continue;
            } else {
                // This monster is acceptable.
                spawns.push(mon);
                spawnTokens -= modcost;
            }
        }
        // Finally, spawn non-major items.
        SpawnItems(false);
    }

    void SpawnItems(bool major = true) {
        // On starting the map and on defeating a boss, items spawn on all SpawnItems.
        let it = ThinkerIterator.Create("SpawnItem");
        SpawnItem mo;
        while (mo = SpawnItem(it.next())) {
            if (!mo.target && major == mo.isMajor) {
                mo.target = mo.spawn(mo.type,mo.pos);
                mo.target.master = mo;
            }
        }
    }

    bool CheckCollision (Actor a, Actor b) {
        // returns true if something's in the way
        return (a != b && b.bSOLID && a.radius + b.radius > a.Vec3To(b).length());
    }

    void ProcessSpawns () {
        // As long as our spawn list isn't empty, we need to find places to spawn them.
        if (spawns.size() > 0) { // This is called every tick anyway.
            let mo = SpawnMonster(spawnSpots.next());
            Class<Actor> mname = spawns[0];
            if (mo && mname) {
                // Random chance of skipping a spawnspot.
                if (frandom(0,1) < 0.2) {
                    mo = SpawnMonster(spawnSpots.next());
                    if (!mo) { return; }
                }
                let mon = GetDefaultByType(mname);
                if (mon.radius > mo.radius) {
                    // Too big! Continue to the next.
                    return;
                }
                BlockThingsIterator it = BlockThingsIterator.Create(mo,mo.radius);
                while (it.next()) {
                    if (CheckCollision(mo,it.Thing)) {
                        // Something's blocking this spawnspot.
                        return;
                    }
                }

                // If we've reached this point, this spawnspot is safe! Spawn the thing.
                mo.spawn(mon.GetClassName(),mo.pos);
                mo.spawn("TeleportFog",mo.pos);
                spawns.delete(0);
            } else {
                // OTOH, we might be out of spawnspots.
                // If so, reinit the spawnSpots.
                spawnSpots.reinit();
            }
        }

    }

    void BossSpawn() {
        // Now we need to do all that, but for bosses :D
        if (wave % bosswave == 0) {
            if (!boss || boss.bCORPSE) {
                let mo = SpawnBoss(bossSpots.next());
                Class<Actor> b = bossType;
                if (mo && b) {
                    let mon = GetDefaultByType(b);
                    if (mon.radius > mo.radius) {
                        // Too big! Continue to the next.
                        return;
                    }
                    BlockThingsIterator it = BlockThingsIterator.Create(mo,mo.radius);
                    while (it.next()) {
                        if (CheckCollision(mo,it.thing)) {
                            // Something's blocking this spawnspot.
                            return;
                        }
                    }
                    // Now we can spawn the boss.
                    console.printf("Attempting to spawn a boss");
                    boss = mo.spawn(mon.GetClassName(),mo.pos);
                    if (boss && !bossSpawned) {
                        boss.bBOSS = true;
                        boss.GiveInventory("BossSparkler",1);
                        mo.spawn("TeleportFog",mo.pos);
                    }
                } else {
                    bossSpots.reinit();
                }
            }
        }
    }

    override void NewGame () {
        initialized = false;
        console.printf("Starting new game!");
    }

    override void WorldTick () {
        if (!initialized) { Initialize(); }
        if (boss == null || boss.bCORPSE) { // Only tick the timer if the boss is dead!
            tickTimer -= 1;
            if (tickTimer < 0) {
                tickTimer = 35;
                seconds -= 1;
                Console.MidPrint(Font.GetFont("SMALLFONT"),""..seconds,true);
            }
            if (seconds < 0) {
                seconds = spawnTimeLimit;
                MakeNewSpawns();
            }
        }

        ProcessSpawns();
        BossSpawn();
    }

    override void WorldThingDied (WorldEvent e) {
        // When something with +BOSS dies, increment difficulty and spawn new items.
        if (e.Thing.bBOSS) {
            difficulty += 1;
            SpawnItems();
            MakeNewSpawns();
        }
    }
}

class BossSparkler : Inventory {
    // Spews golden sparklies.
    override void DoEffect() {
        if (owner && !owner.bCORPSE) {
            if (owner.GetAge() % 10 == 0) {
                console.printf("Boss is here! "..owner.pos);
                double rad = owner.radius;
                double h = owner.height;
                Vector3 offs = (frandom(-rad,rad),frandom(-rad,rad),h);
                owner.Spawn("EpicSpark",owner.pos+offs);
            }
        } else {
            GoAwayAndDie();
        }
    }
}