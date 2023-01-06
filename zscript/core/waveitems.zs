// Classes for wave-survival modes!
class SpawnMonster : Actor {
    // For demons and lower.
    // Spawn spots contain no logic of their own!
    default {
        radius 32;
        +FLATSPRITE;
        +BRIGHT;
        +SYNCHRONIZED;
    }

    states {
        Spawn:
            BAL1 AB 6;
            Loop;
    }
}

class SpawnMonsterBig : SpawnMonster {
    // For up to Arachnotron-size enemies.
    // This actually can fit Cyberdemons, but not Spider Masterminds.
    default {
        radius 80;
        +FLATSPRITE;
        +BRIGHT;
        +SYNCHRONIZED;
    }

    states {
        Spawn:
            MANF AB 6;
            Loop;
    }
}

class SpawnBoss : SpawnMonster {
    // For Cybies and Masterminds.
    default {
        Radius 128;
        Scale 2;
        +FLATSPRITE;
        +BRIGHT;
        +SYNCHRONIZED;
    }

    states {
        Spawn:
            PLS2 AB 6;
            Loop;
    }
}

class SpawnItem : Actor {
    // Spawns a DummyItem, which then spawns a random item.
    Name type;
    Property type : type;
    bool isMajor;
    Property isMajor : isMajor;
    default {
        +FLATSPRITE;
        +SYNCHRONIZED;
        +BRIGHT;
        SpawnItem.type "DummyItem";
        SpawnItem.isMajor true;
    }

    states {
        Spawn:
            PLS1 AB 6;
            Loop;
    }
}

class SpawnHealth : SpawnItem {
    // Spawns healing!
    default {
        SpawnItem.type "LargeHealthPack";
        SpawnItem.isMajor false;
    }

    states {
        Spawn:
            PLSS AB 6;
            Loop;
    }
} 

class SpawnStim : SpawnItem {
    // Smaller healing.
    default {
        SpawnItem.type "SmallHealthPack";
        SpawnItem.isMajor false;
    }

    states {
        Spawn:
            PLSS AB 6;
            Loop;
    }
}

class SpawnGreenArmor : SpawnItem {
    // Spawns a green armor!
    default {
        SpawnItem.type "GreenArmor";
        Scale 2;
        SpawnItem.isMajor false; // Green armor is easy to replenish.
    }

    states {
        Spawn:
            PLSS AB 6;
            Loop;
    }
}

class SpawnBlueArmor : SpawnItem {
    // A blue armor!
    default {
        SpawnItem.type "BlueArmor";
        Scale 2;
    }

    states {
        Spawn:
            PLSS AB 6;
            Loop;
    }
}

// Big ammo box!
class SpawnGreenAmmo : SpawnItem {
    default {
        SpawnItem.type "GreenAmmoBig";
        SpawnItem.isMajor false;
    }

    states {
        Spawn:
            APLS AB 6;
            Loop;
    }
}

class SpawnRedAmmo : SpawnGreenAmmo {
    default {
        SpawnItem.type "RedAmmoBig";
    }
}

class SpawnYellowAmmo : SpawnGreenAmmo {
    default {
        SpawnItem.type "YellowAmmoBig";
    }
}

class SpawnBlueAmmo : SpawnGreenAmmo {
    default {
        SpawnItem.type "BlueAmmoBig";
    }
}

class SpawnHPBonus : SpawnItem {
    // HP bonuses.
    default {
        SpawnItem.type "HPBonus";
        scale 0.5;
        SpawnItem.isMajor false;
    }

    states {
        Spawn:
            PLSS AB 6;
            Loop;
    }
}

class SpawnArmBonus : SpawnHPBonus {
    default {
        SpawnItem.type "ArmBonus";
    }
}

class SpawnAmmoBonus : SpawnHPBonus {
    default {
        SpawnItem.type "AmmoTiny";
    }
}

class SpawnSuperSoul : SpawnHPBonus {
    default {
        Scale 1;
        SpawnItem.Type "SuperSoul";
        SpawnItem.isMajor true;
    }

    states {
        Spawn: 
            PLSS AB 6;
            Loop;
    }
}