// There are four types of ammo: Green, Red, Yellow, and Blue.
// These correspond to Bullet, Shell, Rocket, and Cell in vanilla.

class AmmoDrop : Inventory {
    default {}

    override bool CanPickup(Actor other) {
        // Not meant to be grabbed directly!
        return false;
    }

    override void PostBeginPlay() {
        // Spawn a random ammo type.
        Array<String> ammo;
        ammo.push("GreenAmmo");
        ammo.push("RedAmmo");
        ammo.push("YellowAmmo");
        ammo.push("BlueAmmo");
        let it = spawn(ammo[random(0,3)],pos);
        it.target = target;
        it.master = master;
        it.tracer = tracer;
        if (it.master && it.master.target) {
            it.master.target = it; // handle SpawnAmmoBonus
        }
        it.A_SetSpecial(Special,Args[0],Args[1],Args[2],Args[3],Args[4]);
        it.ChangeTID(TID);
        GoAwayAndDie();
    }
}

class AmmoBig : Inventory {
    // Spawns four of AmmoType when "picked up".
    Name ammotype;
    Property Type : ammotype;

    default {
        +FLOATBOB;
        +BRIGHT;
        Scale 1.5;
        Inventory.PickupMessage "Unpacked some ammo...";
    }
    
    override bool TryPickup(in out actor other) {
        A_SpawnItemEX(ammotype,zvel:4);
        double ang = random(0,18) * 5;
        for (int i = 0; i < 4; i++) {
            A_SpawnItemEX(ammotype,xvel:2,zvel:4,angle:ang + (i * 90));
        }
        GoAwayAndDie();
        return true;
    }
}

class GreenAmmo : Ammo replaces Clip {
    mixin PinkGiver;
    default {
        +FLOATBOB;
        +BRIGHT;
        Inventory.PickupMessage "Green ammo!";
        // factor of 3.3
        Inventory.Amount 50; // used to be 15
        Inventory.MaxAmount 1000; // used to be 300
        Ammo.BackpackAmount 100;
        Ammo.BackpackMaxAmount 2000;
    }

    states {
        Spawn:
            AMMG A -1;
            Stop;
    }
}

class GreenAmmoBig : AmmoBig replaces ClipBox {
    default {
        AmmoBig.Type "GreenAmmo";
    }

    states {
        Spawn:
            AMMG B -1;
            Stop;
    }
}

class RedAmmo : Ammo replaces Shell {
    mixin PinkGiver;
    default {
        +FLOATBOB;
        +BRIGHT;
        Inventory.PickupMessage "Red ammo!";
        // factor of 12.5
        Inventory.Amount 50; // used to be 4
        Inventory.MaxAmount 1000; // used to be 80
        Ammo.BackpackAmount 100;
        Ammo.BackpackMaxAmount 1000;
    }

    states {
        Spawn:
            AMMR A -1;
            Stop;
    }
}

class RedAmmoBig : AmmoBig replaces ShellBox {
    default {
        AmmoBig.Type "RedAmmo";
    }

    states {
        Spawn:
            AMMR B -1;
            Stop;
    }
}

class YellowAmmo : Ammo replaces RocketAmmo {
    mixin PinkGiver;
    default {
        +FLOATBOB;
        +BRIGHT;
        Inventory.PickupMessage "Yellow ammo!";
        // factor of 10
        Inventory.Amount 50; // used to be 5
        Inventory.MaxAmount 1000; // used to be 100
        Ammo.BackpackAmount 100;
        Ammo.BackpackMaxAmount 2000;
    }

    states {
        Spawn:
            AMMY A -1;
            Stop;
    }
}

class YellowAmmoBig : AmmoBig replaces RocketBox {
    default {
        AmmoBig.Type "YellowAmmo";
    }

    states {
        Spawn:
            AMMY B -1;
            Stop;
    }
}

class BlueAmmo : Ammo replaces Cell {
    mixin PinkGiver;
    default {
        +FLOATBOB;
        +BRIGHT;
        Inventory.PickupMessage "Blue ammo!";
        // factor of 2.5
        Inventory.Amount 50; // used to be 20
        Inventory.MaxAmount 1000; // used to be 400
        Ammo.BackpackAmount 100;
        Ammo.BackpackMaxAmount 2000;
    }

    states {
        Spawn:
            AMMB A -1;
            Stop;
    }
}

class BlueAmmoBig : AmmoBig replaces CellPack {
    default {
        AmmoBig.Type "BlueAmmo";
    }

    states {
        Spawn:
            AMMB B -1;
            Stop;
    }
}

class PinkAmmo : Ammo {
    // Exclusively for Big Fucking Guns.
    default {
        +FLOATBOB;
        +BRIGHT;
        Inventory.PickupMessage "Ultra Ammo!";
        Inventory.Amount 1;
        Inventory.MaxAmount 100;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount 100; // Does not get bigger with backpack.
    }

    states {
        Spawn:
            AMMP A -1;
            Stop;
    }
}

class PinkAmmoBig : AmmoBig {
    default {
        AmmoBig.Type "PinkAmmo";
    }

    states {
        Spawn:
            AMMP B -1;
            Stop;
    }
}