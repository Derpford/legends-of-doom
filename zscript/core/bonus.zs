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
        +DONTGIB;
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
        +DONTGIB;
    }

    override void DoEffect() {
        // Clear all copies of DummyHPBonus!
        owner.TakeInventory("DummyHPBonus",9999);
    }
}

class ArmBonus: LegendArmorGiver replaces ArmorBonus {
    // just the old armorbonus, plus succ.
    mixin PlayerVAc;
    override void Tick() {
        super.Tick();
        Suck();
    }
    default {
        Inventory.PickupMessage "Armor Bonus!";
        LegendArmorGiver.Give 0.02;
        +DONTGIB;
    }

    states {
        Spawn:
            BON2 ABCDCB 5 Bright;
            Loop;
    }
}

class HugeMedkit : HPBonus replaces Soulsphere {
    // Overheals 50% of your health.

    default {
        HPBonus.Heal -50;
        HPBonus.DontSuck true;
        Inventory.PickupMessage "Huge Medkit!";
        +INVENTORY.BIGPOWERUP;
        +DONTGIB;
    }

    states {
        spawn:
            MHUG A -1 Bright;
            Stop;
    }
}

class MegaArmor : LegendArmorGiver replaces MegaSphere {
    // Grants 300% of your health as armor.
    default {
        LegendArmorGiver.Give 3.0;
        Inventory.PickupMessage "Mega Armor!";
        +INVENTORY.BIGPOWERUP;
        +DONTGIB;
    }

    states {
        spawn:
            ARMR AB 5 bright;
            Loop;
    }
}

class InvulnSigil : InvulnerabilitySphere replaces InvulnerabilitySphere {
    default {
        Inventory.PickupMessage "Greater Protection Sigil!";
    }

    states {
        Spawn:
            PPRT A 5 Bright;
            PPRT A 5;
            PPRT B 5 Bright;
            PPRT B 5;
            Loop;
    }
}

class LegendPowerup : Inventory {
    // A powerup that goes away after a time.
    double duration;
    Property Duration : duration;
    default {
        LegendPowerup.Duration 90; // 1.5 minutes by default
        Inventory.Amount 1;
        Inventory.PickupSound "misc/p_pkup";
        +INVENTORY.BIGPOWERUP;
        +DONTGIB;
        Inventory.InterHubAmount 0;
    }

    override void DoEffect() {
        duration -= 1./35.;
        if (duration <= 0) {
            owner.TakeInventory(self.GetClassName(),1);
        }
    }
}

class ProtectionSigil : LegendPowerup replaces Blursphere {
    // Shields you for a while, granting 50% extra DR.
    default {
        Inventory.PickupMessage "Lesser Protection Sigil! Temporary 50% damage resist!";
    }

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inf, Actor src, int flags) {
        if (passive) {
            new = dmg * 0.5;
        }
    }

    states {
        Spawn:
            PPRT C 6 Bright;
            PPRT C 6;
            PPRT D 6 Bright;
            PPRT D 6 ;
            Loop;
    }
}

class DamageAmp : LegendPowerup {
    // Boosts your outgoing damage by 50%.
    default {
        Inventory.PickupMessage "Damage Amplifier! Temporary 50% damage boost!";
    }

    override void ModifyDamage (int dmg, Name type, out int new, bool passive, Actor inf, Actor src, int flags) {
        if (!passive) {
            new = dmg * 1.5;
        }
    }

    states {
        Spawn:
            PPOW A -1 Bright;
            Stop;
    }
}

class RegenBooster : LegendPowerup {
    // Heals you for 5% of your health once a second for 90 seconds.
    int timer;
    default {
        Inventory.PickupMessage "Regen Booster! Temporary health regen!";
    }

    override void DoEffect() {
        super.DoEffect();
        timer += 1;
        if (timer >= 35) {
            let plr = LegendPlayer(owner);
            timer = 0;
            if (plr) {
                int amt = plr.GetMaxHealth(true) * 0.05;
                plr.GiveHealth(amt,true);
            }
        }
    }

    states {
        Spawn:
            PRGN A -1;
            Stop;
    }
}

class AimComp : LegendPowerup {
    // Makes your attacks more Precise for a while.
    // Implemented in the playerclass.
    default {
        Inventory.PickupMessage "Aim Computer! Temporary Precision boost!";
    }

    states {
        Spawn:
            PACC ABCDEFGHIJ 5;
            Loop;
    }
}

class LegendPowerSpawn : RandomSpawner replaces Berserk {
    // Drops one of the powerup items.
    default {
        DropItem "AimComp";
        DropItem "RegenBooster";
        DropItem "ProtectionSigil";
        DropItem "DamageAmp";
    }
}