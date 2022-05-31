extend class LegendPlayer {
    bool CanLevel() {
        return xp > (100.0 * level);
    }

    bool TryLevel() {
        if (CanLevel()) {
            xp -= (100.0 * level);
            level += 1;
            console.printf("Level is now "..level);
            A_StartSound("misc/p_pkup");
            return true;
        } else {
            return false;
        }
    }
}

class XPGem : Inventory {
    // A special class that handles the whole thing with XP being a double

    double value;
    Property Value : value;

    default {
        XPGem.Value 1.0;
        +DONTGIB;
        +INVENTORY.QUIET;
    }

    override void AttachToOwner(Actor other) {
        let plr = LegendPlayer(other);
        if(plr) {
            plr.A_StartSound("misc/i_pkup",2);
            plr.xp += value;
            GoAwayAndDie(); //wow rude >:(
        }
    }

    states {
        Spawn:
            XPRS A -1;
            Loop;
        Death:
            TNT1 A 0;
            Stop;
    }
}

class SmallXPGem : XPGem {
    // For debug purposes, has its Value set to 5.

    default {
        XPGem.Value 5.0;
    }

    states {
        Spawn:
            XPRS A 3;
            XPYS A 3;
            XPGS A 3;
            XPBS A 3;
            XPPS A 3;
            Loop;
    }
}

class MidXPGem : XPGem {

    default {
        XPGem.Value 25.0;
    }

    states {
        Spawn:
            XPRM A 3;
            XPYM A 3;
            XPGM A 3;
            XPBM A 3;
            XPPM A 3;
            Loop;
    }
}

class BigXPGem : XPGem {

    default {
        XPGem.Value 125.0;
    }

    states {
        Spawn:
            XPRB A 3;
            XPYB A 3;
            XPGB A 3;
            XPBB A 3;
            XPPB A 3;
            Loop;
    }
}

class XPDropHandler : EventHandler {
    // When a monster dies, drop XP equal to 10% of its HP.
    // TODO: Decide if this should scale up with monster level.

    override void WorldThingDied(WorldEvent e) {
        if (e.Thing.bISMONSTER) { // Only on monsters!
            double xpval = e.Thing.GetSpawnHealth() * 0.1;
            Name type = "SmallXPGem";
            if (xpval > 100) {
                type = "BigXPGem";
            } else if (xpval > 25) {
                type = "MidXPGem";
            }
            let gem = XPGem(e.Thing.spawn(type, e.Thing.pos));
            if (gem) {
                gem.value = xpval;
                gem.vel = (frandom(-6,6), frandom(-6,6), frandom(8,12));
            }
        }
    }
}