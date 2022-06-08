class ItemSpawnHandler : EventHandler {
    // Reads all ICOMMON, IRARE, IEPIC, and ICURSED lumps.
    // Replaces non-dropped weapons with an item from the above lumps.
    // Replaces dropped weapons with ammo.

    Array<Class<Actor> > commonList;
    Array<Class<Actor> > rareList;
    Array<Class<Actor> > epicList;
    Array<Class<Actor> > cursedList;
    Array<Class<Actor> > AmmoList;

    void ParseItems(String found, out Array<Class<Actor> > items) {
        Array<String> toks;
        found.Split(toks, "\n",TOK_SKIPEMPTY);
        for (int i = 0; i < toks.Size(); i++) {
            string it = toks[i].filter();
            console.printf("Got "..it);
            it.replace("\n","");
            it.replace("\r",""); // WINDOOOOOWS
            class<Actor> cit = it;
            console.printf("Checking "..it);
            if(cit) {
                console.printf("Found "..cit.GetClassName());
                items.Push(cit);
            }
        }
    }

    override void OnRegister() {
        // Ammunition!
        Class<Actor> ga = "GreenAmmo";
        Class<Actor> ra = "RedAmmo";
        Class<Actor> ya = "YellowAmmo";
        Class<Actor> ba = "BlueAmmo";
        AmmoList.push(ga);
        AmmoList.push(ra);
        AmmoList.push(ya);
        AmmoList.push(ba);
        // Start with commons.
        int clump = Wads.FindLump("ICOMMON");
        while (clump != -1) {
            String found = Wads.ReadLump(clump);
            console.printf("Found:\n"..found);
            ParseItems(found,commonList);
            clump = Wads.FindLump("ICOMMON",clump+1);
        }
        // Next, rares.
        int rlump = Wads.FindLump("IRARE");
        while (rlump != -1) {
            String found = Wads.ReadLump(rlump);
            console.printf("Found:\n"..found);
            ParseItems(found,rareList);
            rlump = Wads.FindLump("IRARE",rlump+1);
        }
        // Now Epics.
        int elump = Wads.FindLump("IEPIC");
        while (elump != -1) {
            String found = Wads.ReadLump(elump);
            console.printf("Found:\n"..found);
            ParseItems(found,epicList);
            elump = Wads.FindLump("IEPIC",elump+1);
        }
        // And finally, Curseds.
        int blump = Wads.FindLump("ICURSED");
        while (blump != -1) {
            String found = Wads.ReadLump(blump);
            console.printf("Found:\n"..found);
            ParseItems(found,cursedList);
            blump = Wads.FindLump("ICURSED",blump+1);
        }
    }

    override void CheckReplacement (ReplaceEvent e) {
        if (e.Replacee is "Weapon" && !(e.Replacee is "LegendWeapon")) {
            e.Replacement = "DummyItem";
        }
    }

    override void WorldThingSpawned(WorldEvent e) {
        if (e.Thing is "DummyItem") {
            let it = DummyItem(e.Thing);
            if(e.Thing.bDROPPED) {
                // Tell it to spawn an ammo item.
                it.spawnList.Copy(AmmoList);
                it.rarity = -1;
            } else {

                // Items spawn 70% common, 20% rare, 5% epic, 5% cursed.
                // TODO: Better weighting system.
                static const Int odds[] = {0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,1,1,1,1,2,3};
                int rarity = odds[random(0,19)];
                switch (rarity) {
                    case 0:
                        it.spawnList.Copy(commonList);
                        break;
                    case 1:
                        it.spawnList.Copy(rareList);
                        break;
                    case 2:
                        it.spawnList.Copy(epicList);
                        break;
                    case 3:
                        it.spawnList.Copy(cursedList);
                        break;
                }
                it.rarity = rarity;
            }
        }
    }
}

class DummyItem : Actor {
    // Placeholder for an item spawn.
    Array<Class<Actor> > spawnList;
    int rarity;
    
    states {
        Spawn:
            TNT1 A 0;
            TNT1 A 0 {
                // Spawn something random from our spawnList.
                if (spawnList.Size() > 0) {
                    Class<Actor> sp = spawnList[random(0,spawnList.Size()-1)];
                    let it = Spawn(sp,invoker.pos);
                    if (it) {
                        // Transfer our special to it.
                        it.A_SetSpecial(invoker.Special,invoker.Args[0],invoker.Args[1],invoker.Args[2],invoker.Args[3],invoker.Args[4]);
                        it.ChangeTID(invoker.TID);
                        // Spawn a sparkle spawner based on rarity.
                        if (rarity >= 0) {

                            Name sparkType;
                            switch (rarity) {
                                case 0:
                                    sparkType = "ItemSparkSpawner";
                                    break;
                                case 1:
                                    sparkType = "RareSparkSpawner";
                                    break;
                                case 2:
                                    sparkType = "EpicSparkSpawner";
                                    break;
                                case 3:
                                    sparkType = "CursedSparkSpawner";
                                    break;
                            }
                            
                            let sp = Spawn(sparkType,pos);
                            sp.master = it;
                        }
                    }
                }
            }
            TNT1 A 0;
            Stop;
    }
}

class CommonSpark : Actor {
    // A sparkle to indicate rarity.
    default {
        +NOINTERACTION;
        +BRIGHT;
    }
    
    override void Tick() {
        Super.Tick();
        vel.z = 2;
        if (GetAge() > 18) {
            A_FadeOut(.2);
        }
    }

    states {
        Spawn:
            SPRK AB 3; 
            Loop;
    }
}

class RareSpark : CommonSpark {
    states {
        Spawn:
            SPRK CD 3;
            Loop;
    }
}

class EpicSpark : CommonSpark {
    states {
        Spawn:
            SPRK EF 3;
            Loop;
    }
}

class CursedSpark : CommonSpark {
    states {
        Spawn:
            SPRK GH 5;
            Loop;
    }
}

class ItemSparkSpawner : Actor {
    // Dies when its master is picked up. Spawns sparkles.
    Name sparkType;
    Property sparkType : sparkType;
    default {
        +NOINTERACTION;
        ItemSparkSpawner.sparkType "CommonSpark";
    }

    override void Tick() {
        Super.Tick();
        let m = LegendItem(master);
        if (m) {
            if (m.owner) {
                A_Remove(AAPTR_DEFAULT);
            } else {
                SetOrigin(m.pos,false);
                if (GetAge() % 15 == 0) {
                    double ang = GetAge();
                    A_SpawnItemEX(sparkType,xofs:32,zofs:8,angle:ang);
                    A_SpawnItemEX(sparkType,xofs:32,zofs:8,angle:180+ang);
                }
            }
        }
    }
}

class RareSparkSpawner : ItemSparkSpawner {
    default {
        ItemSparkSpawner.sparkType "RareSpark";
    }
}

class EpicSparkSpawner : ItemSparkSpawner {
    default {
        ItemSparkSpawner.sparkType "EpicSpark";
    }
}

class CursedSparkSpawner : ItemSparkSpawner {
    default {
        ItemSparkSpawner.sparkType "CursedSpark";
    }
}
