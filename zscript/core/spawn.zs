class ItemSpawnHandler : EventHandler {
    // Reads all ICOMMON, IRARE, IEPIC, and ICURSED lumps.
    // Replaces non-dropped weapons with an item from the above lumps.
    // Replaces dropped weapons with ammo.

    Array<Class<Actor> > commonList;
    Array<String> rareList;
    Array<String> epicList;
    Array<String> cursedList;

    override void OnRegister() {
        int clump = Wads.FindLump("ICOMMON");
        while (clump != -1) {
            String found = Wads.ReadLump(clump);
            console.printf("Found:\n"..found);
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
                    commonList.Push(cit);
                }
            }
            // commonList.Append(toks);
            clump = Wads.FindLump("ICOMMON",clump+1);
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
            it.spawnList.Copy(commonList);
        }
    }
}

class DummyItem : Actor {
    // Placeholder for an item spawn.
    Array<Class<Actor> > spawnList;
    
    states {
        Spawn:
            TNT1 A 0;
            TNT1 A 0 {
                // Spawn something random from our spawnList.
                Class<Actor> sp = spawnList[random(0,spawnList.Size()-1)];
                console.printf("Spawning "..sp.GetClassName());
                let it = Spawn(sp,invoker.pos);
                if (it) {
                    // Transfer our special to it.
                    it.A_SetSpecial(invoker.Special,invoker.Args[0],invoker.Args[1],invoker.Args[2],invoker.Args[3],invoker.Args[4]);
                    it.ChangeTID(invoker.TID);
                }
            }
            TNT1 A 0;
            Stop;
    }
}