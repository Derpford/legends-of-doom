// There are four types of ammo: Green, Red, Yellow, and Blue.
// These correspond to Bullet, Shell, Rocket, and Cell in vanilla.

class AmmoSpawner : RandomSpawner {
    default {
        DropItem "GreenAmmo";
        DropItem "RedAmmo";
        DropItem "YellowAmmo";
        DropItem "BlueAmmo";
    }
}

class GreenAmmo : Ammo replaces Clip {
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

class GreenAmmoBig : GreenAmmo replaces ClipBox {
    default {
        Scale 1.5;
        Inventory.Amount 75;
    }

    states {
        Spawn:
            AMMG B -1;
            Stop;
    }
}

class RedAmmo : Ammo replaces Shell {
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

class RedAmmoBig : RedAmmo replaces ShellBox {
    default {
        Scale 1.5;
        Inventory.Amount 20;
    }

    states {
        Spawn:
            AMMR B -1;
            Stop;
    }
}

class YellowAmmo : Ammo replaces RocketAmmo {
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

class YellowAmmoBig : YellowAmmo replaces RocketBox {
    default {
        Scale 1.5;
        Inventory.Amount 25;
    }

    states {
        Spawn:
            AMMY B -1;
            Stop;
    }
}

class BlueAmmo : Ammo replaces Cell {
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

class BlueAmmoBig : BlueAmmo replaces CellPack {
    default {
        Scale 1.5;
        Inventory.Amount 100;
    }

    states {
        Spawn:
            AMMB B -1;
            Stop;
    }
}