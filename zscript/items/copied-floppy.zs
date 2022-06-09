class CopiedFloppy : LegendItem {
    // Yar har!
    default {
        Inventory.Icon "FLOPA0";
        Tag "Copied Floppy";
        LegendItem.Desc "Gain bonus XP on kill.";
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