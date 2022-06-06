class RuneOfPain : LegendItem {
    // It has such sights to show you...
    bool active;
    default {
        Inventory.Icon "RKYYA0";
        Inventory.PickupMessage "Rune of Pain: Hitting pained enemies spawns XP.";
        LegendItem.Timer .25;
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if (tgt.InStateSequence(tgt.curstate, tgt.ResolveState("Pain")) && TimeUp()) {
            let gem = XPGem(tgt.spawn("SmallXPGem", tgt.pos));
            if (gem) {
                gem.value = 0.25 * GetStacks();
                gem.vel = (frandom(-4,4), frandom(-4,4), frandom(6,12));
            }
            active = true;
        }
    }

    override void DoEffect() {
        super.DoEffect();
        if (active) {
            SetTimer();
            active = false;
        }
    }

    states {
        Spawn:
            RKYY ABCDEFGHIJ 4;
            Loop;
    }
}