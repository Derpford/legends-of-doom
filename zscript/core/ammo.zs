// There are four types of ammo: Green, Red, Yellow, and Blue.
// These correspond to Bullet, Shell, Rocket, and Cell in vanilla.

class GreenAmmo : Ammo replaces Clip {
    default {
        Scale 0.5;
        Inventory.PickupMessage "Green ammo!";
        Inventory.Amount 15;
        Inventory.MaxAmount 300;
        Ammo.BackpackAmount 30;
        Ammo.BackpackMaxAmount 600;
    }

    states {
        Spawn:
            AMMO A -1;
            Stop;
    }
}

class GreenAmmoBig : GreenAmmo replaces ClipBox {
    default {
        Scale 1.0;
        Inventory.Amount 75;
    }
}

class RedAmmo : Ammo replaces Shell {
    default {
        Inventory.PickupMessage "Red ammo!";
        Inventory.Amount 4;
        Inventory.MaxAmount 80;
        Ammo.BackpackAmount 8;
        Ammo.BackpackMaxAmount 160;
    }

    states {
        Spawn:
            SHEL A -1;
            Stop;
    }
}

class RedAmmoBig : RedAmmo replaces ShellBox {
    default {
        Scale 2.0;
        Inventory.Amount 20;
    }
}

class YellowAmmo : Ammo replaces RocketAmmo {
    default {
        Scale 0.5;
        Inventory.PickupMessage "Yellow ammo!";
        Inventory.Amount 5;
        Inventory.MaxAmount 100;
        Ammo.BackpackAmount 10;
        Ammo.BackpackMaxAmount 200;
    }

    states {
        Spawn:
            BROK A -1;
            Stop;
    }
}

class YellowAmmoBig : YellowAmmo replaces RocketBox {
    default {
        Scale 1.0;
        Inventory.Amount 50;
    }
}

class BlueAmmo : Ammo replaces Cell {
    default {
        Scale 0.5;
        Inventory.PickupMessage "Blue ammo!";
        Inventory.Amount 20;
        Inventory.MaxAmount 400;
        Ammo.BackpackAmount 40;
        Ammo.BackpackMaxAmount 800;
    }

    states {
        Spawn:
            CELP A -1;
            Stop;
    }
}

class BlueAmmoBig : BlueAmmo replaces CellPack {
    default {
        Scale 1.0;
        Inventory.Amount 100;
    }
}