class CopiedFloppy : LegendItem {
    default {
        LegendItem.Icon "FLOPA0";
        Tag "Copied Floppy";
        LegendItem.Desc "Gain bonus XP on kill.";
        LegendItem.Remark "Yar har!";
        LegendItem.Rarity "COMMON UTILITY";
    }

    override string GetLongDesc() {
        return "On kill, you gain 5 (+5 per stack) XP instantly.";
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
        LegendItem.Icon "FLOPC0";
        Tag "Treasured Floppy";
        LegendItem.Desc "Chance of dropping ammo on kill.";
        LegendItem.Remark "I loved this one!";
        LegendItem.Rarity "COMMON UTILITY";
    }

    override string GetLongDesc() {
        return "On kill, 25% (+25% per stack) chance to make the victim drop a tiny amount of all ammo types.";
    }

    override void OnKill (Actor src, Actor tgt) {
        int amt = RollDown(25. + (25. * GetStacks())) - 1;
        for (int i = 0; i < amt; i++) {
            tgt.spawn("AmmoTiny",tgt.pos);
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
        LegendItem.Icon "FLOPB0";
        Tag "Corrupt Floppy";
        LegendItem.Desc "Killing an enemy sometimes spawns a duplicate.";
        LegendItem.Remark "NIGHTMARE.EXE";
        LegendItem.Rarity "CURSED";
    }

    override string GetLongDesc() {
        return "On kill, 20% (+20% per stack) chance for the victim to spawn another enemy of the same type.";
    }

    override void OnKill (Actor src, Actor tgt) {
        if (LuckRoll(20. * GetStacks(),true)) {
            tgt.spawn(tgt.GetClassName(),tgt.pos);
            tgt.spawn("TeleportFog",tgt.pos);
        }
    }

    states {
        Spawn:
            FLOP B -1;
            Stop;
    }

}