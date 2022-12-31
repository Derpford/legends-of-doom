class HPBonus : Inventory replaces HealthBonus {
    // adds 1 to health. does *not* respect max health (or any maximum!).

    mixin PlayerVac;
    override void Tick() {
        super.Tick();
        Suck();
    }

    int heals;
    property Heal : heals;
    bool overheal;
    property Overheal : overheal;

    default {
        HPBonus.Heal 1;
        HPBonus.Overheal true;
        Inventory.PickupMessage "Health Bonus!";
        +Inventory.ALWAYSPICKUP;
    }

    int GetTrueHeal(Actor plr) {
        if (plr && heals < 0) {
            return plr.GetMaxHealth(true) * (heals / -100.);
            // Replicate Health item behavior.
        } else {
            return heals;
        }
    }

    override bool TryPickup (in out actor other) {
        let plr = LegendPlayer(other);
        if(plr) {
            if (!bALWAYSPICKUP && plr.health >= plr.GetMaxHealth(true)) {
                // Can't pick up!
                return false;
            }
            int heal = GetTrueHeal(plr);
            console.printf("Healed for %d",heal);
            plr.GiveHealth(heal,overheal);
            plr.GiveInventory("DummyHPBonus",1);
            GoAwayAndDie();
            return true;
        }
        return false;
    }

    states {
        spawn:
            BON1 ABCDCB 5;
            Loop;
    }
}

class BonusDrop : actor {
    // spawns either an hpbonus or an armorbonus.

    states {
        spawn:
            tnt1 a 0;
            tnt1 a 0 {
                name bon;
                if(frandom(0,1)>0.5) {
                    bon = "hpbonus"; 
                } else {
                    bon = "armbonus";
                }
                let it = spawn(bon,pos);
                if (it) {
                    it.vel = (frandom(-4,4), frandom(-4,4), frandom(6,12));
                }
            }
            stop;
    }
}

class DummyHPBonus : Inventory {
    // Exists solely to trigger OnBonus correctly.
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 9999;
    }

    override void DoEffect() {
        // Clear all copies of DummyHPBonus!
        owner.TakeInventory("DummyHPBonus",9999);
    }
}

class ArmBonus: ArmorBonus replaces ArmorBonus {
    // just the old armorbonus, plus succ.
    mixin PlayerVAc;
    override void Tick() {
        super.Tick();
        Suck();
    }
    default {
        Inventory.PickupMessage "Armor Bonus!";
    }
}

class Supersoul : HPBonus replaces Soulsphere {
    // the soulsphere, but without a maximum!

    default {
        HPBonus.Heal 100;
        HPBonus.DontSuck true;
        Inventory.PickupMessage "Super Soul!";
        +INVENTORY.BIGPOWERUP;
    }

    states {
        spawn:
            SOUL ABCDCB 6 Bright;
    }
}

class MegaSoul : SuperSoul replaces MegaSphere {
    // the megasphere, but without a (health) maximum!
    default {
        HPBonus.Heal 200;
        HPBonus.DontSuck true;
        Inventory.PickupMessage "Mega Soul!";
        +INVENTORY.BIGPOWERUP;
    }

    override bool TryPickup (in out actor other) {
        other.GiveInventory("BlueArmor",1);
        return super.TryPickup(other);
    }

    states {
        spawn:
            MEGA ABCD 6 bright;
    }
}

class ProtectionSphere : Inventory replaces Blursphere {
    // Shields you for the rest of the level, adding 1 to your Toughness divisor.
    // It's like having 100 extra toughness!
    default {
        Inventory.Amount 1;
        Inventory.PickupSound "misc/p_pkup";
        Inventory.PickupMessage "Protection Sphere!";
        +INVENTORY.BIGPOWERUP;
    }

    states {
        Spawn:
            PINS ABCD 6 Bright;
            Loop;
    }
}