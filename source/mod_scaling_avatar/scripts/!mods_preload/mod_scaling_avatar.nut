// CHANGELOG:
// 0.0.1
// - imported from druwski code
// - added percentage scaling
// - added msu options config
// 0.0.2
// - rewrite and simplify codebase
// - added talent-based modifiers
// 0.0.3
// - fix some settings not being applied
// - added new perk level diff scaling
// 0.0.4
// - refactored into seperate trait
// - added passing on trait to bros

// TODO:
// - convert to trait instead
//   - this just check and add trait
// - apply a weaker version to allies
// IDEAS:
// - scale gain rates with stars
// - scale gain rates with starting stats
// - scale % up per diff % instead of just >

// flat stat use getpropertiesbeforeuse thing

/*

    // CLEANUP: move to serialized struct BonusStats {}, then override the get stats functions
    // CLEANUP: move to serialized perks BonusPerks {}, then override the get perks functions

    function onAfterUpdate( _properties )
    {
        local actor = this.getContainer().getActor();
        local headt = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Head);
        if (headt == null)
        {
            _properties.MeleeDefense += 20;
        }
        this.dark_wraith_background <- this.inherit("scripts/skills/backgrounds/character_background", {

    function onAfterUpdate( _properties )
    {
        local actor = this.getContainer().getActor();
        local headt = this.getContainer().getActor().getItems().getItemAtSlot(this.Const.ItemSlot.Head);
        if (headt == null)
        {
            _properties.MeleeDefense += 20;
        }
*/

::ScalingAvatar <- {
    ID = "mod_scaling_avatar",
    Name = "ScalingAvatar",
    Version = "0.0.4",

    Settings = { },

    VerboseLogging = true,

    VerboseLogDebug = function(str) {
        if (::ScalingAvatar.VerboseLogging == false)
            return;

        ::ScalingAvatar.Mod.Debug.printLog("ScalingAvatar: " + str, "debug");
    },

    ReadStatTag = function(o, tagName) {
        return o.getContainer().getActor().getLifetimeStats().Tags.getAsInt(tagName);
    },

    ReadStatTags = function(o) {
        return {
            HitpointsGained = ::ScalingAvatar.ReadStatTag(o, "HitpointsGained"),
            BraveryGained = ::ScalingAvatar.ReadStatTag(o, "BraveryGained"),
            StaminaGained = ::ScalingAvatar.ReadStatTag(o, "StaminaGained"),
            MeleeSkillGained = ::ScalingAvatar.ReadStatTag(o, "MeleeSkillGained"),
            RangedSkillGained = ::ScalingAvatar.ReadStatTag(o, "RangedSkillGained"),
            MeleeDefenseGained = ::ScalingAvatar.ReadStatTag(o, "MeleeDefenseGained"),
            RangedDefenseGained = ::ScalingAvatar.ReadStatTag(o, "RangedDefenseGained"),
            InitiativeGained = ::ScalingAvatar.ReadStatTag(o, "InitiativeGained"),
        };
    },

    CalculateLevelDifference = function(bro, actor) {
        local powerBro = bro.getLevel();
        local powerActor = actor.getXPValue() / 30;

        local delta = powerActor - powerBro;

        ::ScalingAvatar.VerboseLogDebug("ScalingAvatar: power " + powerBro + " vs " + powerActor + " (" + delta + ")");

        if (delta < 0)
            return 0;

        return delta;
    },

    IncrementStatTag = function(o, tagName) {
        o.getContainer().getActor().getLifetimeStats().Tags.increment(tagName);
    },
}

::mods_registerMod(::ScalingAvatar.ID, ::ScalingAvatar.Version, ::ScalingAvatar.Name);
::mods_queue(::ScalingAvatar.ID, "mod_legends", function() {

    ::ScalingAvatar.Mod <- ::MSU.Class.Mod(::ScalingAvatar.ID, ::ScalingAvatar.Version, ::ScalingAvatar.Name);
    ::ScalingAvatar.Mod.Debug.setFlag("debug", true)

    local page = ::ScalingAvatar.Mod.ModSettings.addPage("General");

    //function addRangeSetting( _id, _value, _min, _max, _step, _name = null, _description = null )

    page.addTitle("Presets", "Presets");
    page.addButtonSetting("PresetBalanced", "Balanced", "Balanced", "Balance preset for eventually powerful avatar but not too extreme.").addCallback(function() {
        ::ScalingAvatar.VerboseLogDebug("setting preset balanced...");
        ::ScalingAvatar.Settings.StatRollPercent.set(20);
        ::ScalingAvatar.Settings.StatRollPercentPerStar.set(10);
        ::ScalingAvatar.Settings.StatRollPercentPerLevelDifference.set(10);
        ::ScalingAvatar.Settings.StatRollModifier.set(0);
        ::ScalingAvatar.Settings.StatRollModifierPerStar.set(-5);
        ::ScalingAvatar.Settings.StatRollModifierPerLevelDifference.set(-5);
        ::ScalingAvatar.Settings.PerkRollPercent.set(20);
        ::ScalingAvatar.Settings.PerkRollPercentPerLevelDifference.set(10);
        ::ScalingAvatar.Settings.ApplyToBroRate.set(5);
        ::ScalingAvatar.Settings.ApplyToBroRatePerLevelDifference.set(5);
    });
    page.addButtonSetting("PresetStrong", "Strong", "Strong", "Faster scaling and higher limits, for a very strong avatar.").addCallback(function() {
        ::ScalingAvatar.VerboseLogDebug("setting preset strong...");
        ::ScalingAvatar.Settings.StatRollPercent.set(50);
        ::ScalingAvatar.Settings.StatRollPercentPerStar.set(15);
        ::ScalingAvatar.Settings.StatRollPercentPerLevelDifference.set(15);
        ::ScalingAvatar.Settings.StatRollModifier.set(-15);
        ::ScalingAvatar.Settings.StatRollModifierPerStar.set(-5);
        ::ScalingAvatar.Settings.StatRollModifierPerLevelDifference.set(-5);
        ::ScalingAvatar.Settings.PerkRollPercent.set(50);
        ::ScalingAvatar.Settings.PerkRollPercentPerLevelDifference.set(15);
        ::ScalingAvatar.Settings.ApplyToBroRate.set(15);
        ::ScalingAvatar.Settings.ApplyToBroRatePerLevelDifference.set(10);
    });
    page.addButtonSetting("PresetBeggar", "Beggar", "Beggar", "Simple 100% rolls, same as standard Scaling Beggar.").addCallback(function() {
        ::ScalingAvatar.VerboseLogDebug("setting preset beggar...");
        ::ScalingAvatar.Settings.StatRollPercent.set(100);
        ::ScalingAvatar.Settings.StatRollPercentPerStar.set(0);
        ::ScalingAvatar.Settings.StatRollPercentPerLevelDifference.set(0);
        ::ScalingAvatar.Settings.StatRollModifier.set(0);
        ::ScalingAvatar.Settings.StatRollModifierPerStar.set(0);
        ::ScalingAvatar.Settings.StatRollModifierPerLevelDifference.set(0);
        ::ScalingAvatar.Settings.PerkRollPercent.set(100);
        ::ScalingAvatar.Settings.PerkRollPercentPerLevelDifference.set(0);
        ::ScalingAvatar.Settings.ApplyToBroRate.set(0);
        ::ScalingAvatar.Settings.ApplyToBroRatePerLevelDifference.set(0);
    });
    page.addButtonSetting("PresetRare", "Rare", "Rare", "Only very rarely get a perk or stat bonus.").addCallback(function() {
        ::ScalingAvatar.VerboseLogDebug("setting preset beggar...");
        ::ScalingAvatar.Settings.StatRollPercent.set(1);
        ::ScalingAvatar.Settings.StatRollPercentPerStar.set(1);
        ::ScalingAvatar.Settings.StatRollPercentPerLevelDifference.set(1);
        ::ScalingAvatar.Settings.StatRollModifier.set(-5);
        ::ScalingAvatar.Settings.StatRollModifierPerStar.set(-5);
        ::ScalingAvatar.Settings.StatRollModifierPerLevelDifference.set(-5);
        ::ScalingAvatar.Settings.PerkRollPercent.set(1);
        ::ScalingAvatar.Settings.PerkRollPercentPerLevelDifference.set(1);
        ::ScalingAvatar.Settings.ApplyToBroRate.set(1);
        ::ScalingAvatar.Settings.ApplyToBroRatePerLevelDifference.set(1);
    });

    page.addDivider("Stats");
    page.addTitle("Stats", "Stats");

    local settingStat = page.addRangeSetting("StatRollPercent", 25, 0, 100, 1.0, "Stat Roll Percent", "Chance of gaining stats from killed enemy.");
    local settingStatPerStar = page.addRangeSetting("StatRollPercentPerStar", 10, 0, 100, 1.0, "Stat Roll Percent Per Star", "Extra gain chance per talent star.");
    local settingStatPerLevelDifference = page.addRangeSetting("StatRollPercentPerLevelDifference", 10, 0, 100, 1.0, "Stat Roll Percent Per Level Difference", "Extra gain chance per level difference");
    local settingStatModifier = page.addRangeSetting("StatRollModifier", 0, -100, 100, 1.0, "Stat Roll Modifier", "Extra difference between stats check (lower means easier gain).");
    local settingStatModifierPerStar = page.addRangeSetting("StatRollModifierPerStar", -5, -100, 100, 1.0, "Stat Roll Modifier Per Star", "Extra difference between stats check per star.");
    local settingStatModifierPerLevelDifference = page.addRangeSetting("StatRollModifierPerLevelDifference", -5, -100, 100, 1.0, "Stat Roll Modifier Per Level Difference", "Extra difference between stats check per level difference.");
    local settingSeperate = page.addBooleanSetting("StatRollPerStatRolls", true, "Seperate Stat Rolls", "Roll for stat gain per individual stat.");

    page.addDivider("Perks");
    page.addTitle("Perks", "Perks");

    local settingPerk = page.addRangeSetting("PerkRollPercent", 25, 0, 100, 1.0, "Perk Roll Percent", "Chance of gaining perks from killed enemy.");
    local settingPerkPerLevelDifference = page.addRangeSetting("PerkRollPercentPerLevelDifference", 5, 0, 100, 1.0, "Perk Roll Percent Per Level Difference", "Bonus chance per level difference.");

    page.addDivider("BroRate");
    page.addTitle("ApplyToBroRate", "Apply To Bro Rate");

    local settingApplyToBroRate = page.addRangeSetting("ApplyToBroRate", 5, 0, 100, 1.0, "Apply to Bro Rate", "Amount to apply the same effect to other Bros");
    local settingApplyToBroRatePerLevelDifference = page.addRangeSetting("ApplyToBroRatePerLevelDifference", 5, 0, 100, 1.0, "Apply to Bro Rate Per Level Difference", "Extra amount per level difference");

    page.addDivider("Debug");
    page.addTitle("DebugSettings", "Debug Settings");

    local settingVerbose = page.addBooleanSetting("VerboseLogging", false, "Verbose Logging", "Verbose logging for debugging.");

    settingVerbose.addCallback(function(_value) { ::ScalingAvatar.VerboseLogging = _value; });

    ::ScalingAvatar.Settings.StatRollPercent <- ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollPercent"),
    ::ScalingAvatar.Settings.StatRollPercentPerStar <- ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollPercentPerStar"),
    ::ScalingAvatar.Settings.StatRollPercentPerLevelDifference <- ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollPercentPerLevelDifference"),
    ::ScalingAvatar.Settings.StatRollModifier <- ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollModifier"),
    ::ScalingAvatar.Settings.StatRollModifierPerStar <- ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollModifierPerStar"),
    ::ScalingAvatar.Settings.StatRollModifierPerLevelDifference <- ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollModifierPerLevelDifference"),
    ::ScalingAvatar.Settings.StatRollPerStatRolls <- ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollPerStatRolls"),
    ::ScalingAvatar.Settings.PerkRollPercent <- ::ScalingAvatar.Mod.ModSettings.getSetting("PerkRollPercent"),
    ::ScalingAvatar.Settings.PerkRollPercentPerLevelDifference <- ::ScalingAvatar.Mod.ModSettings.getSetting("PerkRollPercentPerLevelDifference"),
    ::ScalingAvatar.Settings.ApplyToBroRate <- ::ScalingAvatar.Mod.ModSettings.getSetting("ApplyToBroRate"),
    ::ScalingAvatar.Settings.ApplyToBroRatePerLevelDifference <- ::ScalingAvatar.Mod.ModSettings.getSetting("ApplyToBroRatePerLevelDifference"),

    ::ScalingAvatar.Mod.Debug.printLog("initalized msu with settings:", "debug");
    foreach (k,v in ::ScalingAvatar.Settings)
        ::ScalingAvatar.Mod.Debug.printLog("> " + k + " = " + v, "debug");

    ::mods_hookExactClass("skills/traits/player_character_trait", function(o) {
        local base_onAdded = ::mods_getMember(o, "onAdded");
        ::mods_override(o, "onAdded", function() {
            base_onAdded();

            local actor = this.getContainer().getActor();
            local skills = actor.getSkills();

            if (skills.hasSkill("trait.scaling_avatar") == false)
            {
                ::ScalingAvatar.VerboseLogDebug("adding scaling avatar trait to player character...");
                skills.add(this.new("scripts/skills/traits/mod_scaling_avatar_trait"));
            }
        });
    });
});