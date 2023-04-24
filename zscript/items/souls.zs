class CalmSoul : LegendItem {

    int stock;
    default {
        LegendItem.Icon "SOULA0";
        Tag "Calm Soul";
        LegendItem.Desc "Taking damage heals you over time, per instance of damage.";
        LegendItem.Remark "Turn the other cheek.";
        LegendItem.Rarity "EPIC DEFENSE HEALING";
    }

    override void OnRetaliateRaw (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        stock += 5 * GetStacks();
    }

    override void DoEffect() {
        super.DoEffect();
        if (stock > 0) {
            stock -= GetStacks();
            let plr = LegendPlayer(owner);
            if (plr) {
                plr.GiveHealth(GetStacks(),true);
            } else {
                Owner.GiveBody(GetStacks());
            }
        }
    }

    states {
        Spawn:
            SOUL ABCDCB 6 Bright;
            Loop;
    }
}

class StoneSoul : LegendItem {
    int buff;
    default {
        LegendItem.Icon "MEGAA0";
        Tag "Stone Soul";
        LegendItem.Desc "Taking damage stacks small amounts of Toughness.";
        LegendItem.Remark "Forgive them, Father...";
        LegendItem.Rarity "EPIC DEFENSE";
        LegendItem.Timer 1.0;
    }

    override void OnRetaliateRaw (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        buff += 1;
        if (TimeUp()) {
            SetTimer();
        }
    }

    override void OnTimer() {
        if (buff > 0) {
            int decay = ceil(buff * 0.1);
            buff = max(0,buff - decay);
            SetTimer();
        }
    }

    override double GetToughness() {
        return buff * 0.5 * GetStacks();
    }

    states {
        Spawn:
            MEGA ABCDCB 6 Bright;
            Loop;
    }
}

class HiddenSoul : LegendItem {
    int buff;
    default {
        LegendItem.Icon "PINSA0";
        Tag "Hidden Soul";
        LegendItem.Desc "Dealing damage stacks small amounts of Precision.";
        LegendItem.Remark "Look upon my works.";
        LegendItem.Rarity "EPIC ATTACK";
        LegendItem.Timer 1.0;
    }

    override void OnHit (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        buff += 1;
        if (TimeUp()) {
            SetTimer();
        }
    }

    override void OnTimer() {
        if (buff > 0) {
            int decay = ceil(buff * 0.1);
            buff = max(0,buff - decay);
            SetTimer();
        }
    }

    override double GetPrecision() {
        return buff * 0.5 * GetStacks();
    }

    states {
        Spawn:
            PINS ABCD 6 Bright;
            Loop;
    }
}

class UndyingSoul : LegendItem {
    int buff;
    default {
        LegendItem.Icon "PINVA0";
        Tag "Undying Soul";
        LegendItem.Desc "Dealing damage stacks Power. Taking damage removes Power.";
        LegendItem.Remark "I am the Alpha and the Omega.";
        LegendItem.Rarity "CURSED";
        LegendItem.Timer 0.1;
    }

    override void OnHit (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if(TimeUp()) {
            buff += 1;
            SetTimer();
        }
    }

    override void OnRetaliate (int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if(TimeUp()) {
            buff -= 1;
            SetTimer();
        }
    }

    override double GetPower() {
        return buff * 0.5 * GetStacks();
    }

    states {
        Spawn:
            PINV ABCD 6 Bright;
            Loop;
    }
}