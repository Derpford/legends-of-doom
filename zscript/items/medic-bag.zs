class MedicBag : LegendItem {
    // AAAAAAUUGH I'M DYYYYIIIIING
    default {
        LegendItem.Icon "MBAGA0";
        Tag "Medic Bag";
        LegendItem.Desc "Enemies drop healing orbs on death.";
        LegendItem.Remark "AAAA I'M DYING";
        LegendItem.Rarity "RARE HEALING";
    }

    override void OnKill(Actor src, Actor tgt) {
        let it = tgt.Spawn("MedicOrb",tgt.pos);
        if (it) {
            it.vel = (frandom(-2,2),frandom(-2,2),frandom(4,8));
            let it = MedicOrb(it);
            it.heals = -3 * GetStacks();
        }
    }

    states {
        Spawn:
            MBAG A -1;
            Stop;
    }
}

class MedicOrb : HPBonus {
    // An orb that heals.
    default {
        Inventory.PickupMessage "Got a healing orb!";
        HPBonus.Overheal false;
    }

    override void Tick() {
        Super.Tick();
        if(GetAge() > (10 * 35) && InStateSequence(curstate,ResolveState("Spawn"))) {
            SetState(ResolveState("Flicker"));
        }

        if(GetAge() > (12 * 35) && InStateSequence(curstate,ResolveState("Flicker"))) {
            GoAwayAndDie();
        }
    }
    
    states {
        Spawn:
            HORB ABCDCB 3 Bright;
            Loop;

        Flicker:
            HORB A 3 Bright;
            TNT1 A 3;
            HORB B 3 Bright;
            TNT1 A 3;
            HORB C 3 Bright;
            TNT1 A 3;
            HORB D 3 Bright;
            TNT1 A 3;
            HORB C 3 Bright;
            TNT1 A 3;
            HORB B 3 Bright;
            TNT1 A 3;
            Loop;
    }
}

class FirstAidKit : LegendItem {
    // Rapid trauma response.
    default {
        LegendItem.Icon "AIDKA0";
        Tag "First Aid";
        LegendItem.Desc "Receive healing 6 seconds after you stop taking damage.";
        LegendItem.Remark "It contains...mushrooms?";
        LegendItem.Rarity "COMMON HEALING";
        LegendItem.Timer 6.0;
    }

    override void OnTimer() {
        int baseheal = floor(2.5 * GetStacks());
        int percentheal = floor(owner.GetMaxHealth() * 0.1);
        let plr = LegendPlayer(owner);
        plr.GiveHealth(percentheal + baseheal);
    }

    override void OnRetaliate(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        SetTimer();
    }

    states {
        Spawn:
            AIDK A -1;
            Stop;
    }
}