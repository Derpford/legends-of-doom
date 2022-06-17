class SpicyWater : LegendItem {
    // mmmmm slorp
    int stack;
    int maxstack;
    Property Trigger : maxstack; // How many stacks before the next damage instance?
    default {
        Scale 1.5;
        LegendItem.Icon "JNUKA0";
        LegendItem.Timer 5.;
        SpicyWater.Trigger 10;
        Tag "Spicy Water";
        LegendItem.Desc "Retaliate with a radioactive aura.";
        LegendItem.Remark "Mmmm. [slorp]";
        LegendItem.Rarity "RARE";
    }

    override void OnRetaliate(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        SetTimer();
    }

    override void DoEffect() {
        super.DoEffect();

        if(!TimeUp()) {
            stack += GetStacks();
            if (stack >= maxstack && !owner.bCORPSE) {
                // owner.A_Explode(floor(GetOwnerPower()*0.1),128,XF_NOTMISSILE,fulldamagedistance:128);
                let it = RadBurst(owner.spawn("RadBurst",owner.pos+(0,0,16)));
                if (it) {
                    it.target = owner;
                    it.power = floor(GetOwnerPower()*0.1);
                    it.radius = 128;
                    stack -= maxstack;
                }
            }
        }
    }

    states {
        Spawn:
            JNUK A -1;
            Stop;
    }
}