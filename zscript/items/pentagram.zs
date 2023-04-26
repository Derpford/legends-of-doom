class SealedPentagram : LegendItem {
    // Make the Elder Sign.
    bool used;
    default {
        LegendItem.Icon "CEYEA0";
        Tag "Sealed Pentagram";
        LegendItem.Desc "Every 5s, your next attack frightens whatever it hits.";
        LegendItem.Remark "Witchin'.";
        LegendItem.Timer 5.;
        LegendItem.Rarity "RARE DEFENSE UTILITY";
    }

    override string GetLongDesc() {
        return "Every 5 seconds, your next attack fears the target for 2 seconds (+0.1s per stack).";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if (TimeUp() && tgt != owner) {
            // Flag our timer for triggering next tic.
            used = true;
            int amt = 19 + GetStacks();
            tgt.GiveInventory("Fear",amt);

        }
    }

    override string,int GetItemInfo() {
        if (!TimeUp()) {
            return String.Format("%0.2f",timer), Font.CR_DARKGRAY;
        } else {
            return "READY", Font.CR_WHITE;
        }
    }

    override void DoEffect() {
        Super.DoEffect();
        if (used && TimeUp()) {
            SetTimer();
            used = false;
        }
    }

    states {
        Spawn:
            CEYE ABCB 5 Bright;
            Loop;
    }
}