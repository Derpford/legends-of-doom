class BloodySerum : LegendItem {
    // You feel rabid.
    int kills;
    property kills : kills;

    default {
        Inventory.Icon "SRUMA0";
        BloodySerum.kills 0;
        Tag "Bloody Serum";
        LegendItem.Desc "Gain max health on kill.";
        LegendItem.Remark "You feel rabid.";
    }

    override void OnKill (Actor src, Actor tgt) {
        if (kills < (100 * GetStacks())) {
            kills += 1;
            if(owner is "LegendPlayer") {
                let plr = LegendPlayer(owner);
                plr.BonusHealth += 1;
                plr.GiveHealth(1);
            } else {
                owner.GiveBody(1);
            }
            owner.A_StartSound("misc/i_pkup",2,pitch:0.8);
        }
    }

    states {
        Spawn:
            SRUM A -1;
            Stop;
    }
}