class ItemSpawnHandler : StaticEventHandler {
    // Reads all ICOMMON, IRARE, IEPIC, and ICURSED lumps.
    // Replaces non-dropped weapons with an item from the above lumps.
    // Replaces dropped weapons with ammo.

    mixin LumpParser;

    Array<Class<Actor> > AmmoList;

    Dictionary itemList; // Holds all items and their rarities.
    Dictionary tierList; // Holds all rarity tiers.
    Dictionary crateList; // Holds all item crates.
    Dictionary sparkList; // Holds one spark per rarity tier.

    int WeightedRandom(Array<Double> weights) {
        double sum;
        for (int i = 0; i < weights.size(); i++) {
            sum += weights[i];
        }

        // And now we roll.
        double roll = frandom(0,sum);
        for (int i = 0; i < weights.size(); i++) {
            if (roll < weights[i]) {
                return i;
            } else {
                roll -= weights[i];
            }
        }
        // If we reach this point, something went wrong.
        return -1;
    }

    String SelectRarity(String whitelist = "") {
        // Start by splitting the whitelist, unless it's an empty string.
        Array<String> splitWhitelist;
        bool skipWhitelist = false;
        if (whitelist == "") {
            skipWhitelist = true;
        } else {
            whitelist.split(splitWhitelist, " ",TOK_SKIPEMPTY);
        }
        Array<String> tiers;
        Array<Double> weights;
        DictionaryIterator it = DictionaryIterator.Create(tierList);
        int breaker = 0;
        while (it.next() && breaker < 32) {
            if (skipWhitelist || splitWhitelist.find(it.key()) != splitWhitelist.size()) {
                // console.printf("Tier added : %s",it.key());
                tiers.push(it.key());
                weights.push(it.value().toDouble());
            }
            breaker += 1;
        }

        String res;
        // If there's only one tier, pick that.
        if (tiers.Size() == 1) {
            res = tiers[0];
        } else {
            // Now do a weighted random roll on weights...
            int idx = WeightedRandom(weights);
            res = tiers[idx];
        }
        // And that's the tier we return.
        // console.printf("Selected %s",res);
        return res;
    }

    String SelectItem(String tier) {
        // Given a tier, collect all items from that tier, then spawn one at random.
        Array<String> spawns;
        DictionaryIterator it = DictionaryIterator.Create(itemList);
        while (it.next()) {
            // console.printf("Checking %s (%s)",it.key(),it.value());
            Array<String> ts;
            it.value().split(ts," ",TOK_SKIPEMPTY);
            if(ts.find(tier) != ts.size()) {
                // console.printf("Added %s to spawn list",it.key());
                spawns.push(it.key());
            }
        }

        if(spawns.size() > 0) {
            return spawns[random(0,spawns.size()-1)];
        } else {
            return "";
        }
    }

    String SelectCrate() {
        Array<String> tiers;
        Array<Double> weights;
        DictionaryIterator it = DictionaryIterator.Create(cratelist);
        while (it.next()) {
            tiers.push(it.key());
            weights.push(it.value().toDouble());
        }
        int idx = WeightedRandom(weights);
        return tiers[idx];
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

        itemList = Dictionary.Create();
        tierList = Dictionary.Create();
        sparkList = Dictionary.Create();
        crateList = Dictionary.Create();

        // LumpToDict("TIERS",tierList);
        // LumpToDict("ISPARKS",sparkList);
        // LumpToItems("ITEMS",itemList);

        // Grab all LegendItem, RarityTier, and Crate classes that are non-abstract.
        for (int i = 0; i < AllClasses.Size(); i++) {
            if (AllClasses[i].IsAbstract()) { continue; }

            if (AllClasses[i] is "LegendItem") {
                Class<Actor> it = AllClasses[i].GetClassName();
                let cit = LegendItem(GetDefaultByType(it));
                // Array<String> r;
                // cit.GetTiers(r);
                itemList.insert(cit.GetClassName(),cit.GetRarity());
                console.printf("Item registered: %s (%s)",cit.GetClassName(),cit.GetRarity());
            }

            if (AllClasses[i] is "ItemCrate") {
                Class<Actor> it = AllClasses[i].GetClassName();
                let cit = ItemCrate(GetDefaultByType(it));
                String w = String.Format("%f",cit.weight);
                crateList.insert(cit.GetClassName(),w);
                console.printf("Crate registered: %s (%s)",cit.GetClassName(),w);
            }

            if (AllClasses[i] is "RarityTier") {
                let it = AllClasses[i].GetClassName();
                Console.printf(""..it);
                if (it) {
                    let cit = RarityTier(new(it)).get();
                    String w = String.Format("%f",cit.weight);
                    String spark = "";
                    if (cit.hasSparkle) {
                        spark = cit.sparkle;
                        sparkList.insert(cit.tiername, spark);
                    }
                    tierList.insert(cit.tiername,w);
                }
            }
        }
    }

    override void CheckReplacement (ReplaceEvent e) {
        if (e.Replacee is "Weapon" && !(e.Replacee is "LegendWeapon")) {
            e.Replacement = "DummyItem";
        }
        
        // Champions compat.
        String champbonus = "champion_HealthBonus";
        class<Actor> cbonusclass = champbonus;
        if (cbonusclass && e.Replacee is cbonusclass) {
            e.Replacement = "SmallXPGem";
        }

        // ColourfulHell compat.
        String dropbase = "DropBaseItem";
        class<Actor> dropbaseclass = dropbase;
        if (dropbaseclass && e.Replacee is dropbaseclass) {
            e.Replacement = "MidXPGem";
        }
    }

    override void WorldThingSpawned(WorldEvent e) {
        if (e.Thing is "DummyItem") {
            let it = DummyItem(e.Thing);
            if(e.Thing.bDROPPED) {
                // Tell it to spawn an ammo item.
                it.spawntype = "AmmoDrop";
            } else {
                it.spawntype = SelectCrate();
            }
        }

        if (e.Thing is "LegendItem") {
            // Spawn an item spark.
            let lit = LegendItem(e.Thing);
            Array<String> tiers;
            lit.GetTiers(tiers);
            if (tiers.size() > 0) {
                let rarity = tiers[0];
                let sparkType = sparkList.at(rarity);
                let spark = ItemSparkSpawner(lit.spawn("ItemSparkSpawner",lit.pos));
                spark.master = lit;
                spark.sparkType = sparkType;
            }
        }
    }

}

class DummyItem : Actor {
    // Placeholder for an item spawn.
    Array<Class<Actor> > spawnList;
    Class<Actor> spawntype;
    String rarity;
    String sparkType;
    
    states {
        Spawn:
            TNT1 A 0;
            TNT1 A 0 {
                // Spawn something random from our spawnList.
                if (spawntype == "") {return;}
                let it = Spawn(spawntype,invoker.pos);
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
