class CopiedFloppy : LegendItem {
    // Yar har!
    default {
        Inventory.Icon "FLOPA0";
        Inventory.PickupMessage "Copied Floppy: Bonus XP on kill.";
    }

    override void OnKill (Actor src, Actor tgt) {
        // On kill, gain 5*stacks XP.
        let plr = LegendPlayer(src);
        if (plr) {
            plr.xp += 5. * GetStacks();
        }
    }
}