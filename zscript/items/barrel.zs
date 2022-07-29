class BarrelOfFun : LegendItem {
    // This isn't Barrels Of Fun at all!
    default {
        Scale 0.75;
        LegendItem.Icon "BAR1A0";
        Tag "Barrel of Fun";
        LegendItem.Desc "Chance of spawning a time-bomb barrel on hit.";
        LegendItem.Remark "*not actually fun";
        LegendItem.RandomDecay 0.01; // Barrels should be infrequent.
        LegendItem.Rarity "COMMON ATTACK";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if(LuckRoll(5  * GetStacks())) {
            let it = TimeBarrel(tgt.Spawn("TimeBarrel",tgt.pos));
            if (it) {
                it.vel = (frandom(-4,4),frandom(-4,4),frandom(6,8));
                it.power = floor(dmg * 3.5);
                it.target = owner;
            }
            randomAdjust += 0.1;
        }
    }

    states {
        Spawn:
            BAR1 A -1;
            Stop;
    }
}

class TimeBarrel : LegendShot {
    // An exploding barrel!
    int timer;
    default {
        +THRUACTORS;
        -NOGRAVITY;
        -MISSILE;
        Scale 0.5;
    }

    states {
        Spawn:
            BAR1 A 0;
            BAR1 A 0 {
                timer = 70;
            }
        TimerLoop:
            BAR1 AAABBB 1 {
                timer -= 1;
                if (timer % 10 == 0) {
                    A_StartSound("items/barbeep",attenuation:0.3,pitch:(70./(70 + timer)));
                }

                if (timer <= 0) {
                    return ResolveState("Death");
                } else {
                    return ResolveState(null);
                }
            }
            loop;
        Death:
            BEXP A 5 Bright A_StartSound("world/barrelx");
            BEXP B 4 Bright;
            BEXP C 3 Bright;
            BEXP D 3 Bright A_SplashDamage(power,128,selfdmg:false);
            BEXP E 5 Bright;
            TNT1 A 0;
            Stop;
    }
}

class OilBarrel : LegendItem {
    // Captain Planet villain.
    default {
        Scale 0.75;
        LegendItem.Icon "FCANA0";
        Tag "Oil Barrel";
        LegendItem.Desc "On kill, ignite everything nearby.";
        LegendItem.Remark "Captain Planet villain.";
        LegendItem.Rarity "COMMON ATTACK";
    }

    override void OnKill(Actor src, Actor tgt) {
        let b = FlameBurst(tgt.Spawn("FlameBurst",tgt.pos+(0,0,tgt.height/2)));
        if (b) {
            b.power = GetStacks();
            b.giveradius = tgt.radius * 4;
            b.target = owner;
        }
    } 

    states {
        Spawn:
            FCAN ABC 4 Bright;
            Loop;
    }
}