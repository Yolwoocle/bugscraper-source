local upgrades = {
    -- Unlocked at beginning
    UpgradeTea =              require "scripts.upgrade.upgrade_tea",
    UpgradeEspresso =         require "scripts.upgrade.upgrade_espresso",
    UpgradeMilk =             require "scripts.upgrade.upgrade_milk",
    UpgradeBoba =             require "scripts.upgrade.upgrade_boba",
    UpgradeSoda =             require "scripts.upgrade.upgrade_soda",
    UpgradeAppleJuice =       require "scripts.upgrade.upgrade_apple_juice",
    UpgradeFizzyLemonade =    require "scripts.upgrade.upgrade_fizzy_lemonade",
    UpgradeHotSauce =         require "scripts.upgrade.upgrade_hot_sauce",
    UpgradeHotChocolate =     require "scripts.upgrade.upgrade_hot_chocolate",
    UpgradeCoconutWater =     require "scripts.upgrade.upgrade_coconut_water",

    -- Unlocked after
    UpgradePomegranateJuice = require "scripts.upgrade.upgrade_pomegranate_juice",
    UpgradeEnergyDrink =      require "scripts.upgrade.upgrade_energy_drink",
    -- UpgradeGazpacho =         require "scripts.upgrade.upgrade_gazpacho",
    -- UpgradeGuarana =          require "scripts.upgrade.upgrade_guarana",
    
    UpgradeWater =            require "scripts.upgrade.upgrade_water",
}

return upgrades