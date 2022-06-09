class MedicBag : LegendItem {
    // AAAAAAUUGH I'M DYYYYIIIIING
    default {
        Inventory.Icon "MBAGA0";
        Tag "Medic Bag";
        LegendItem.Desc "Enemies drop healing orbs on death.";
    }

    override void OnKill(Actor src, Actor tgt) {
        let it = tgt.Spawn("MedicOrb",tgt.pos);
        if (it) {
            it.vel = (frandom(-2,2),frandom(-2,2),frandom(4,8));
            let it = MedicOrb(it);
            it.heals = 5 * GetStacks();
            console.printf("Heals: "..it.heals);
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