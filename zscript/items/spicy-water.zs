class SpicyWater : LegendItem {
    // mmmmm slorp
    int stack;
    int maxstack;
    Property Trigger = maxstack; // How many stacks before the next damage instance?
    default {
        Scale 0.5;
        Inventory.Icon "BAR1A0";
        Inventory.PickupMessage "Spicy Water: Retaliate with a radioactive aura.";
        LegendItem.Timer 5.;
        SpicyWater.Trigger 10;
    }

    override void OnRetaliate(int dmg, Name type, Actor src, Actor inf, Actor tgt) {
        SetTimer();
    }

    override void DoEffect() {
        super.DoEffect();

        if(!TimeUp()) {
            stack += owner.CountInv("SpicyWater");
            if (stack >= maxstack) {

                owner.A_Explode(floor(GetPower()*0.1),128,XF_NOTMISSILE,fulldamagedistance:128);
            }
        }
    }

}