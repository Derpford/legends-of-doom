class OwlsightAmulet : LegendItem {
    // Sniping's a good job, mate.
    bool active;
    default {
        Inventory.Icon "AMLTE0";
        Inventory.PickupMessage "Owlsight Amulet: Boosts Precision...but when monsters are near, penalizes you.";
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