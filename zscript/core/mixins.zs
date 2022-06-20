mixin class PinkGiver {
    // On pickup, also give the user pink ammo.
    override bool TryPickup(in out actor other) {
        bool success = super.TryPickup(other);
        if (success) {
            other.GiveInventory("PinkAmmo",1);
        }
        return success;
    }
}

mixin class PlayerVac {
    // This item gets sucked toward the player.
    // Should only go on items with ALWAYSPICKUP!
    bool shouldSuck;
    property dontSuck : shouldSuck;
    void Suck() {
        if(shouldSuck) {return;}
        if (target && !target.bCORPSE) {
            Vector3 tv = vec3To(target);
            if (GetAge() > 48) { bNOGRAVITY = true; }
            bNOCLIP = (tv.length() > target.radius+radius);
            vel += tv.unit() * (min(GetAge(),48) * 0.1);
        } else {
            ThinkerIterator it = ThinkerIterator.Create("LegendPlayer",Thinker.STAT_PLAYER);
            double dist = -1.;
            Actor m;
            Actor closest;
            while(m = Actor(it.next())) {
                double newdist = Vec3To(m).length();
                if (newdist < 256.) {
                    if (dist < 0 || newdist < dist) {
                        closest = Actor(m);
                        dist = Vec3To(closest).length();
                    }
                }
            }
            target = closest;
        }
    }
}

mixin class SplashDamage {
    // A function for less-awful splash damage.
    action void A_SplashDamage(int damage, double radius = -1, int mindamage = 0, Name type = "Explosion", bool selfdmg = true) {
        if (radius < 0) { radius = damage; }
        let hits = BlockThingsIterator.Create(self,radius*2);
        while (hits.next()) {
            if (!selfdmg && hits.Thing == target) { continue; }
            double len = max(0,Vec3To(hits.Thing).length()-hits.Thing.radius);
            double multi = 1. - (len/radius);
            if (len <= radius) { // BlockThingsIterator is imprecise!
                int deltadmg = damage - mindamage;
                int finaldmg = mindamage + (deltadmg * multi);
                hits.Thing.DamageMobj(self,target,finaldmg,type,DMG_EXPLOSION);
                hits.Thing.vel.z += finaldmg / hits.Thing.mass;
            }
        }
    }
}

mixin class NoClipProj {
    // A function that sets +NOCLIP based on distance to a tracer.
    void ClipCheck () {
        if(tracer) {
            if (Vec3To(tracer).length() < (tracer.radius + self.radius)) {
                // We're about to hit.
                bNOCLIP = false;
            } else {
                bNOCLIP = true;
            }
        } 
    }
}
