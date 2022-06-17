// There are four types of ammo: Green, Red, Yellow, and Blue.
// These correspond to Bullet, Shell, Rocket, and Cell in vanilla.

class AmmoDrop : RandomSpawner {
    default {
        DropItem "GreenAmmo";
        DropItem "RedAmmo";
        DropItem "YellowAmmo";
        DropItem "BlueAmmo";
    }
}

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
        Inventory.Amount 15;
        Inventory.MaxAmount 300;
        Ammo.BackpackAmount 30;
        Ammo.BackpackMaxAmount 600;
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
        Inventory.Amount 4;
        Inventory.MaxAmount 80;
        Ammo.BackpackAmount 8;
        Ammo.BackpackMaxAmount 160;
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
        Inventory.Amount 5;
        Inventory.MaxAmount 100;
        Ammo.BackpackAmount 10;
        Ammo.BackpackMaxAmount 200;
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
        Inventory.Amount 20;
        Inventory.MaxAmount 400;
        Ammo.BackpackAmount 40;
        Ammo.BackpackMaxAmount 800;
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