class BehemothShell : LegendItem {
    // I Can't Believe It's Not Brilliant Behemoth
    default {
        LegendItem.Icon "ROCKA0";
        Tag "Behemoth Shell";
        LegendItem.Desc "All of your attacks explode!";
        LegendItem.Remark "Legally Distinct Brillaince";
        LegendItem.Rarity "EPIC ATTACK";
        DamageFactor "Explosion", 0.5;
    }

    override string GetLongDesc() {
        return "On-hit, create an explosion that does 60% of the initial hit's damage in a radius of 128 units (+32 units per stack).";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        // attacks also explode for 60% original damage in a 128-unit radius
        if (type != "Behemoth") {
            let it = BehemothBlast(tgt.spawn("BehemothBlast",inf.pos));
            it.power = dmg * 0.6;
            it.stacks = GetStacks();
            it.target = src;
        }
    }

    states {
        Spawn:
            ROCK A -1;
            Stop;
    }
}

class BehemothBlast : Actor {
    double power;
    int stacks;
    Mixin SplashDamage;

    default {
        Gravity -0.1;
        RenderStyle "Add";
    }
    
    states {
        Spawn:
            MISL C 0;
            MISL C 4 {
                A_SplashDamage(power,128 + (32*stacks),type:"Behemoth",selfdmg:false);
                A_StartSound("weapons/barrelx",volume:0.5);
                double scl = float(power)/64.;
                //scale = (scl, scl);
            }
            MISL D 5;
            MISL E 6;
            TNT1 A 0;
            Stop;
    }
}