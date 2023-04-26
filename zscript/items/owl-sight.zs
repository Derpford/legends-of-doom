class OwlsightAmulet : LegendItem {
    // Sniping's a good job, mate.
    bool active;
    default {
        LegendItem.Icon "AMLTE0";
        Tag "Owlsight Amulet";
        LegendItem.Desc "Boosts Precision, but penalizes you if monsters are near.";
        LegendItem.Remark "I'm a professional.";
        LegendItem.Rarity "CURSED";
    }

    override string GetLongDesc() {
        return "If there are no visible enemies within 256 units, gain 25 (+25 per stack) Precision. Otherwise, suffer a -25 (-25 per stack) Precision debuff.";
    }

    override double GetPrecision() {
        if (active) {
            return 25. * GetStacks();
        } else {
            return -25. * GetStacks();
        }
    }

    override void DoEffect() {
        Super.DoEffect();
        ThinkerIterator it = ThinkerIterator.Create("Actor",Thinker.STAT_DEFAULT);
        Actor m;
        bool found = false;
        while (m = Actor(it.next())) {
            if (!m.bISMONSTER || m.bCORPSE) { continue; }
            if (owner.vec3To(m).length() > 256 || !m.CheckSight(owner,SF_IGNOREVISIBILITY)) { continue; }
            found = true;
        }
        active = !found;
    }

    states {
        Spawn:
            AMLT E -1;
            Stop;
    }
}