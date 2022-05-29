extend class LegendPlayer {
    bool CanLevel() {
        return xp > (100.0 * level);
    }

    bool TryLevel() {
        if (CanLevel()) {
            xp -= (100.0 * level);
            level += 1;
            console.printf("Level is now "..level);
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
    }

    override void AttachToOwner(Actor other) {
        let plr = LegendPlayer(other);
        if(plr) {
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