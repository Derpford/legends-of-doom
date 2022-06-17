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
            // Give the target Root.
            if (tgt.CountInv("Root") == 0) { // But only if they're not already rooted!
                tgt.GiveInventory("Root",30 + (5 * GetStacks()));
            }
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