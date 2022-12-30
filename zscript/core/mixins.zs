mixin class PinkGiver {
    // On pickup, also give the user pink ammo.
    override bool TryPickup(in out actor other) {
        bool success = super.TryPickup(other);
        if (success) {
            other.GiveInventory("PinkAmmo",10);
        }
        return success;
    }
}

mixin class AmmoRandom {
    // If +DROPPED, turns into an AmmoDrop.
    override void PostBeginPlay() {
        if (bDROPPED) {
            if (!owner) {
                let it = Spawn("AmmoDrop",pos);
                if (it) {
                    GoAwayAndDie();
                }
            }
        }
        super.PostBeginPlay();
    }
}

mixin class PlayerVac {
    // This item gets sucked toward the player.
    // Should only go on items with ALWAYSPICKUP!
    bool shouldSuck;
    property dontSuck : shouldSuck;
    void Suck() {
        if(shouldSuck) {return;}
        if (target && !target.bCORPSE) {
            Vector3 tv = vec3To(target);
            if (GetAge() > 48) { bNOGRAVITY = true; }
            bNOCLIP = (tv.length() > target.radius+radius);
            vel += tv.unit() * (min(GetAge(),48) * 0.1);
        } else {
            ThinkerIterator it = ThinkerIterator.Create("LegendPlayer",Thinker.STAT_PLAYER);
            double dist = -1.;
            Actor m;
            Actor closest;
            while(m = Actor(it.next())) {
                double newdist = Vec3To(m).length();
                if (newdist < 256.) {
                    if (dist < 0 || newdist < dist) {
                        closest = Actor(m);
                        dist = Vec3To(closest).length();
                    }
                }
            }
            target = closest;
        }
    }
}

mixin class SplashDamage {
    // A function for less-awful splash damage.
    action void A_SplashDamage(int damage, double radius = -1, int mindamage = 0, Name type = "Explosion", bool selfdmg = true) {
        if (radius < 0) { radius = damage; }
        let hits = BlockThingsIterator.Create(self,radius*2);
        while (hits.next()) {
            if (!selfdmg && hits.Thing == target) { continue; }
            if (!isVisible(hits.Thing,true)) { continue; }
            double len = max(0,Vec3To(hits.Thing).length()-hits.Thing.radius);
            double multi = 1. - (len/radius);
            if (len <= radius) { // BlockThingsIterator is imprecise!
                int deltadmg = damage - mindamage;
                int finaldmg = mindamage + (deltadmg * multi);
                hits.Thing.vel.z += finaldmg / hits.Thing.mass;
                hits.Thing.DamageMobj(self,target,finaldmg,type,DMG_EXPLOSION);
            }
        }
    }
}

mixin class NoClipProj {
    // A function that sets +NOCLIP based on distance to a tracer.
    void ClipCheck () {
        if(tracer) {
            if (Vec3To(tracer).length() < (tracer.radius + self.radius)) {
                // We're about to hit.
                bNOCLIP = false;
            } else {
                bNOCLIP = true;
            }
        } 
    }

    void Seek () {
        // If there's a tracer, chase it.
        // Otherwise, find the nearest monster and make that our tracer.
        // If the tracer is our owner, remove the tracer.
        if (tracer == target) {
            tracer == null;
        }
        if (tracer && tracer.health > 0) {
            Vector3 to = Vec3To(tracer).Unit();
            Vector3 v = vel.Unit();
            double multi = 1 + clamp(GetAge() / 35., 0, 1);
            vel = ((multi * to) + v).unit() * speed;
            A_Face(tracer);
        } else {
            ThinkerIterator it = ThinkerIterator.Create("Actor");
            Actor mo;
            Actor t;
            double dist = -1;
            while (mo = Actor(it.next())) {
                if (mo.bSHOOTABLE && mo != target) {
                    double len = Vec3To(mo).length();
                    if (dist == -1 || len < dist) {
                        t = mo;
                        dist = len;
                    }
                }
            }

            if (t) {
                tracer = t;
            }

        }
    }
}

mixin class LumpParser {
    // Has convenience functions for parsing lumps.

    void LumpToArray (string lname, out Array<String> list) {
        // Just pushes items to an array.
        int lump = Wads.FindLump(lname);
        console.printf("Loading %s",lname);
        while (lump != -1) {
            string found = Wads.ReadLump(lump);
            list.push(found);
            lump = Wads.FindLump(lname,lump+1);
        }
    }

    void LumpToDict (string lname, out Dictionary list) {
        // Takes in lumps formatted as a dictionary.
        int lump = Wads.FindLump(lname);
        console.printf("Loading %s",lname);
        while (lump != -1) {
            string found = Wads.ReadLump(lump);
            ParseDict(list,found);
            lump = Wads.FindLump(lname,lump+1);
        }
    }

    void ParseDict(out Dictionary dict, String found) {
        // Basically just appends found to tierlist.
        AppendToDict(dict, Dictionary.FromString(found));
    }

    void AppendToDict(out Dictionary a, Dictionary b) {
        let it = DictionaryIterator.Create(b);
        while (it.next()) {
            a.Insert(it.key(),it.value());
        }
    }

    void LumpToItems (string lname, out Dictionary list) {
        // Literally just LumpToDict but with ParseItemDict instead.
        // First class functions in zscript when :P
        int lump = Wads.FindLump(lname);
        console.printf("Loading %s",lname);
        while (lump != -1) {
            string found = Wads.ReadLump(lump);
            ParseItemDict(found,list);
            lump = Wads.FindLump(lname,lump+1);
        }
    }

    void ParseItemDict(String found, out Dictionary list) {
        Array<String> toks;
        found.Split(toks, "\n",TOK_SKIPEMPTY);
        for (int i = 0; i < toks.Size(); i++) {
            string it = toks[i].filter();
            it.replace("\n","");
            it.replace("\r",""); // WINDOOOOOWS
            class<LegendItem> cit = it;
            if(cit) {
                let cit = GetDefaultByType(cit);
                Array<String> r;
                cit.GetTiers(r);
                for (int i = 0; i < r.Size(); i++) {
                    list.insert(cit.GetClassName(),r[i]);
                    console.printf("Item registered: %s (%s)",cit.GetClassName(),r[i]);
                }
                // items.Push(cit);
            }
        }
    }
}

mixin class Lerps {
    // Various interpolation things.
    clearscope double SmoothCap(double base, double cap) {
        // Diminishing returns on base, such that base never reaches cap.
        // In other words, as base approaches infinity,
        // the return value approaches cap.
        return (atan(base / cap) / 180.) * 2 * cap;
    }

    clearscope double DimResist(double amt, double half) {
        // Returns a multiplier such that:
        // when amt = half, multiplier = 0.5.
        // when amt = 0, multiplier = 1
        // Diminishing returns kick in after that. 
        // i.e., when amt = 2*half, multiplier is 0.75
        // if amt < 0, the multiplier increases instead.
        // at amt = -half, the multiplier becomes 1.5.
        if (amt >= 0) {
            return half / amt + half;
        } else {
            return 2 - (half / half - amt); // thank you lolwiki
        }
    }

    clearscope double DimPower(double amt, double half) {
        // As above, but when amt = 0, mult = 1,
        // and when amt = half, mult = 2.
        // Note that at amt = -half, this returns 0!
        if (amt >= 0) {
            return half + amt / half;
        } else {
            return 2 - (half - amt / half);
        }
    }
}