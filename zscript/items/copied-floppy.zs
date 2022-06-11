class CopiedFloppy : LegendItem {
    default {
        Inventory.Icon "FLOPA0";
        Tag "Copied Floppy";
        LegendItem.Desc "Gain bonus XP on kill.";
        LegendItem.Remark "Yar har!";
    }

    override void OnKill (Actor src, Actor tgt) {
        // On kill, gain 5*stacks XP.
        let plr = LegendPlayer(src);
        if (plr) {
            plr.xp += 5. * GetStacks();
        }
    }
    
    states {
        Spawn:
            FLOP A -1;
            Stop;
    }
}

class TreasuredFloppy : LegendItem {
    default {
        Inventory.Icon "FLOPC0";
        Tag "Treasured Floppy";
        LegendItem.Desc "Chance of dropping ammo on kill.";
        LegendItem.Remark "I loved this one!";
    }

    override void OnKill (Actor src, Actor tgt) {
        int amt = RollDown(5. + (5. * GetStacks())) - 1;
        for (int i = 0; i < amt; i++) {
            tgt.spawn("AmmoSpawner",tgt.pos);
        }
    }

    states {
        Spawn:
            FLOP C -1;
            Stop;
    }
}

class CorruptFloppy : LegendItem {
    default {
        Inventory.Icon "FLOPB0";
        Tag "Corrupt Floppy";
        LegendItem.Desc "Killing an enemy sometimes spawns a duplicate.";
        LegendItem.Remark "NIGHTMARE.EXE";
    }

    override void OnKill (Actor src, Actor tgt) {
        if (LuckRoll(10. * GetStacks(),true)) {
            tgt.spawn(tgt.GetClassName(),tgt.pos);
        }
    }

}