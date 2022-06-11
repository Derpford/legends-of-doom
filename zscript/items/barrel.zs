class BarrelOfFun : LegendItem {
    // This isn't Barrels Of Fun at all!
    default {
        Scale 0.75;
        Inventory.Icon "BAR1A0";
        Tag "Barrel of Fun";
        LegendItem.Desc "Chance of spawning a time-bomb barrel on hit.";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        if(LuckRoll(10. + (2.5 * GetStacks()))) {
            let it = TimeBarrel(tgt.Spawn("TimeBarrel",tgt.pos));
            if (it) {
                it.vel = (frandom(-4,4),frandom(-4,4),frandom(6,8));
                it.power = floor(dmg * 3.5);
                it.target = owner;
            }
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
                    A_StartSound("misc/i_pkup",attenuation:0.3,pitch:(70./(70 + timer)));
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
            BEXP D 3 Bright A_Explode(power,128,flags:0,fulldamagedistance:128 - power);
            BEXP E 5 Bright;
            TNT1 A 0;
            Stop;
    }
}