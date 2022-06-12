class BehemothShell : LegendItem {
    // I Can't Believe It's Not Brilliant Behemoth
    default {
        LegendItem.Icon "ROCKA0";
        Tag "Behemoth Shell";
        LegendItem.Desc "All of your attacks explode!";
        LegendItem.Remark "Legally Distinct Brillaince";
    }

    override void OnHit(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        // attacks also explode for 100% original damage in a 128-unit radius
        if (type != "Behemoth") {
            let it = BehemothBlast(tgt.spawn("BehemothBlast",inf.pos));
            it.power = dmg;
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
    int power;
    int stacks;

    default {
        Gravity -0.1;
        RenderStyle "Add";
    }
    
    states {
        Spawn:
            MISL C 0;
            MISL C 4 {
                A_Explode(power,128*stacks,flags:0,fulldamagedistance:(128*stacks)-power,damagetype:"Behemoth");
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