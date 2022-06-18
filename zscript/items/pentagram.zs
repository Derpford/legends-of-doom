class SealedPentagram : LegendItem {
    // Make the Elder Sign.
    bool used;
    default {
        LegendItem.Icon "CEYEA0";
        Tag "Sealed Pentagram";
        LegendItem.Desc "Every 5s, your next attack roots whatever it hits.";
        LegendItem.Remark "Witchin'.";
        LegendItem.Timer 5.;
        LegendItem.Rarity "RARE";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if (TimeUp()) {
            // Flag our timer for triggering next tic.
            used = true;
            int amt = 9 + GetStacks();
            let tinv = StatusEffect(tgt.FindInventory("Root"));
            if (tinv && tinv.stacks > 0) {
                amt = 0;
            }
            tgt.GiveInventory("Root",amt);

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