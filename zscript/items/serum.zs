class BloodySerum : LegendItem {
    // You feel rabid.
    int kills;
    property kills : kills;

    default {
        LegendItem.Icon "SRUMA0";
        BloodySerum.kills 0;
        Tag "Bloody Serum";
        LegendItem.Desc "Gain max health on kill.";
        LegendItem.Remark "You feel rabid.";
        LegendItem.Rarity "RARE HEALING";
    }

    clearscope int MaxStacks() {
        return (100 * GetStacks());
    }

    override void OnKill (Actor src, Actor tgt) {
        if (kills < MaxStacks()) {
            kills += 1;
            if(owner is "LegendPlayer") {
                let plr = LegendPlayer(owner);
                plr.stamina += 1;
                plr.GiveHealth(1);
            } else {
                owner.GiveBody(1);
            }
            owner.A_StartSound("items/serum",2,pitch:0.8);
        }
    }

    override string, int GetItemInfo() {
        int c = Font.CR_WHITE;
        if (kills >= MaxStacks()) { c = Font.CR_RED; }
        return String.Format("+%d",kills), c;
    }

    states {
        Spawn:
            SRUM A -1;
            Stop;
    }
}