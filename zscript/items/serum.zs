class BloodySerum : LegendItem {
    // You feel rabid.
    int kills;
    property kills : kills;

    default {
        Inventory.Icon "SRUMA0";
        Inventory.PickupMessage "Bloody Serum: Gain max health on kill.";
        BloodySerum.kills 0;
    }

    override void OnKill (Actor src, Actor tgt) {
        if (kills < (100 * owner.CountInv("BloodySerum"))) {
            kills += 1;
            if(owner is "LegendPlayer") {
                let plr = LegendPlayer(owner);
                plr.BonusHealth += 1;
            }
            owner.GiveBody(1);
            owner.A_StartSound("misc/i_pkup",2,pitch:0.8);
        }
    }

    states {
        Spawn:
            SRUM A -1;
            Stop;
    }
}