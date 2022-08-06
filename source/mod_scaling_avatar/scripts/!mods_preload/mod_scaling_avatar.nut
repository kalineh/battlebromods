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

// TODO:
// - apply bonus stats easier
// - remove avatar built-in resolve
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
    Version = "0.0.3",

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
        ::ScalingAvatar.Settings.StatRollPercent.set(25);
        ::ScalingAvatar.Settings.StatRollPercentPerStar.set(10);
        ::ScalingAvatar.Settings.StatRollModifier.set(0);
        ::ScalingAvatar.Settings.StatRollModifierPerStar.set(-5);
        ::ScalingAvatar.Settings.PerkRollPercent.set(25);
        ::ScalingAvatar.Settings.PerkRollPercentPerLevelDifference.set(5);
    });
    page.addButtonSetting("PresetStrong", "Strong", "Strong", "Faster scaling and higher limits, for a very strong avatar.").addCallback(function() {
        ::ScalingAvatar.VerboseLogDebug("setting preset strong...");
        ::ScalingAvatar.Settings.StatRollPercent.set(50);
        ::ScalingAvatar.Settings.StatRollPercentPerStar.set(15);
        ::ScalingAvatar.Settings.StatRollModifier.set(-15);
        ::ScalingAvatar.Settings.StatRollModifierPerStar.set(-5);
        ::ScalingAvatar.Settings.PerkRollPercent.set(50);
        ::ScalingAvatar.Settings.PerkRollPercentPerLevelDifference.set(10);
    });
    page.addButtonSetting("PresetBeggar", "Beggar", "Beggar", "Simple 100% rolls, same as standard Scaling Beggar.").addCallback(function() {
        ::ScalingAvatar.VerboseLogDebug("setting preset beggar...");
        ::ScalingAvatar.Settings.StatRollPercent.set(100);
        ::ScalingAvatar.Settings.StatRollPercentPerStar.set(0);
        ::ScalingAvatar.Settings.StatRollModifier.set(0);
        ::ScalingAvatar.Settings.StatRollModifierPerStar.set(0);
        ::ScalingAvatar.Settings.PerkRollPercent.set(100);
        ::ScalingAvatar.Settings.PerkRollPercentPerLevelDifference.set(0);
    });

    page.addDivider("Stats");
    page.addTitle("Stats", "Stats");

    local settingStat = page.addRangeSetting("StatRollPercent", 25, 0, 100, 1.0, "Stat Roll Percent", "Chance of gaining stats from killed enemy.");
    local settingStatPerStar = page.addRangeSetting("StatRollPercentPerStar", 10, 0, 100, 1.0, "Stat Roll Percent Per Star", "Extra gain chance per talent star.");
    local settingStatModifier = page.addRangeSetting("StatRollModifier", 0, -100, 100, 1.0, "Stat Roll Modifier", "Extra difference between stats check (lower means easier gain).");
    local settingStatModifierPerStar = page.addRangeSetting("StatRollModifierPerStar", -5, -100, 100, 1.0, "Stat Roll Modifier Per Star", "Extra difference between stats check per star.");
    local settingSeperate = page.addBooleanSetting("StatRollPerStatRolls", true, "Seperate Stat Rolls", "Roll for stat gain per individual stat.");

    page.addDivider("Perks");
    page.addTitle("Perks", "Perks");

    local settingPerk = page.addRangeSetting("PerkRollPercent", ::ScalingAvatar.PerkRollPercent, 0, 100, 1.0, "Perk Roll Percent", "Chance of gaining perks from killed enemy.");
    local settingPerkPerLevelDifference = page.addRangeSetting("PerkRollPercentPerLevelDifference", ::ScalingAvatar.PerkRollPercentPerLevelDifference, 0, 100, 1.0, "Perk Roll Percent Per Level Difference", "Chance increase for each level target is above.");

    page.addDivider("Debug");
    page.addTitle("DebugSettings", "Debug Settings");

    local settingVerbose = page.addBooleanSetting("VerboseLogging", false, "Verbose Logging", "Verbose logging for debugging.");

    settingVerbose.addCallback(function(_value) { ::ScalingAvatar.VerboseLogging = _value; });

    ::ScalingAvatar.Settings = {
        StatRollPercent = ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollPercent"),
        StatRollPercentPerStar = ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollPercentPerStar"),
        StatRollModifier = ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollModifier"),
        StatRollModifierPerStar = ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollModifierPerStar"),
        StatRollPerStatRolls = ::ScalingAvatar.Mod.ModSettings.getSetting("StatRollPerStatRolls"),
        PerkRollPercent = ::ScalingAvatar.Mod.ModSettings.getSetting("PerkRollPercent"),
        PerkRollPercentPerLevelDifference = ::ScalingAvatar.Mod.ModSettings.getSetting("PerkRollPercentPerLevelDifference"),
    };

    ::mods_hookExactClass("skills/traits/player_character_trait", function(o) {

        //foreach (k,v in o)
            //::ScalingAvatar.Mod.Debug.printLog("trait: " + k + "=" + v, "debug");
        // this = root table? msu core stuff?
        // o = trait object
        // o.m = member data? class-specific?

        local base_getTooltip = ::mods_getMember(o, "getTooltip");
        ::mods_override(o, "getTooltip", function() {
            local actor = this.getContainer().getActor();
            local stats = ::ScalingAvatar.ReadStatTags(this);
            local results = base_getTooltip();
            
            local format_text = function(statName, statValue) {
                //return format("[color=%s]+%d[/color] %s gained due to scaling effect", this.Const.UI.Color.PositiveValue, statValue, statName);
                return "[color=" + this.Const.UI.Color.PositiveValue + "]+" + statValue + "[/color] " + statName + " gained due to scaling effect";
            };

            results.append({ id = 10, type = "text", icon = "ui/icons/health.png", text = format_text("Hitpoints", stats.HitpointsGained), });
            results.append({ id = 10, type = "text", icon = "ui/icons/bravery.png", text = format_text("Resolve", stats.BraveryGained), });
            results.append({ id = 10, type = "text", icon = "ui/icons/fatigue.png", text = format_text("Fatigue", stats.StaminaGained), });
            results.append({ id = 10, type = "text", icon = "ui/icons/initiative.png", text = format_text("Initiative", stats.InitiativeGained), });
            results.append({ id = 10, type = "text", icon = "ui/icons/melee_skill.png", text = format_text("Melee Skill", stats.MeleeSkillGained), });
            results.append({ id = 10, type = "text", icon = "ui/icons/ranged_skill.png", text = format_text("Ranged Skill", stats.RangedSkillGained), });
            results.append({ id = 10, type = "text", icon = "ui/icons/melee_defense.png", text = format_text("Melee Defense", stats.MeleeDefenseGained), });
            results.append({ id = 10, type = "text", icon = "ui/icons/ranged_defense.png", text = format_text("Ranged Defense", stats.RangedDefenseGained), });

            return results;
        });

        local scalingAvatarOnTargetKilledStats = function(_targetEntity, _skill) {
            local actor = this.getContainer().getActor();
            local actorProps = actor.getBaseProperties();
            local targetProps = _targetEntity.getBaseProperties();

            local learned_something = false;
            local learned_string = "";

            local scaling_roll_all = Math.rand(0, 100);
            local scaling_roll_hitpoints = Math.rand(0, 100);
            local scaling_roll_resolve = Math.rand(0, 100);
            local scaling_roll_fatigue = Math.rand(0, 100);
            local scaling_roll_melee_attack = Math.rand(0, 100);
            local scaling_roll_ranged_attack = Math.rand(0, 100);
            local scaling_roll_melee_defense = Math.rand(0, 100);
            local scaling_roll_ranged_defense = Math.rand(0, 100);
            local scaling_roll_initiative = Math.rand(0, 100);

            if (::ScalingAvatar.Settings.StatRollPerStatRolls.getValue().tointeger() == 0)
            {
                scaling_roll_hitpoints = scaling_roll_all;
                scaling_roll_resolve = scaling_roll_all;
                scaling_roll_fatigue = scaling_roll_all;
                scaling_roll_melee_attack = scaling_roll_all;
                scaling_roll_ranged_attack = scaling_roll_all;
                scaling_roll_melee_defense = scaling_roll_all;
                scaling_roll_ranged_defense = scaling_roll_all;
                scaling_roll_initiative = scaling_roll_all;
            }

            local talents = actor.getTalents();

            local pct = ::ScalingAvatar.Settings.StatRollPercent.getValue().tointeger();
            local pctStar = ::ScalingAvatar.Settings.StatRollPercentPerStar.getvalue().tointeger();

            local chance_hitpoints = pct + pctStar * talents[this.Const.Attributes.Hitpoints];
            local chance_resolve = pct + pctStar * talents[this.Const.Attributes.Bravery];
            local chance_fatigue = pct + pctStar * talents[this.Const.Attributes.Fatigue];
            local chance_melee_attack = pct + pctStar * talents[this.Const.Attributes.MeleeSkill];
            local chance_ranged_attack = pct + pctStar * talents[this.Const.Attributes.RangedSkill];
            local chance_melee_defense = pct + pctStar * talents[this.Const.Attributes.MeleeDefense];
            local chance_ranged_defense = pct + pctStar * talents[this.Const.Attributes.RangedDefense];
            local chance_initiative = pct + pctStar * talents[this.Const.Attributes.Initiative];

            local modifier = ::ScalingAvatar.Settings.StatRollModifier.getValue().tointeger();
            local modifierStar = ::ScalingAvatar.Settings.StatRollModifierPerStar.getValue().tointeger();

            local modifier_hitpoints = modifier + modifierStar * talents[this.Const.Attributes.Hitpoints];
            local modifier_resolve = modifier + modifierStar * talents[this.Const.Attributes.Bravery];
            local modifier_fatigue = modifier + modifierStar * talents[this.Const.Attributes.Fatigue];
            local modifier_melee_attack = modifier + modifierStar * talents[this.Const.Attributes.MeleeSkill];
            local modifier_ranged_attack = modifier + modifierStar * talents[this.Const.Attributes.RangedSkill];
            local modifier_melee_defense = modifier + modifierStar * talents[this.Const.Attributes.MeleeDefense];
            local modifier_ranged_defense = modifier + modifierStar * talents[this.Const.Attributes.RangedDefense];
            local modifier_initiative = modifier + modifierStar * talents[this.Const.Attributes.Initiative];

            ::ScalingAvatar.VerboseLogDebug("rolling for stat increase...");

            local roll_handler = function(internalStatName, statName, statTagName, roll, chance, statModifier) {

                local roll_result_str = function(rollResult, statResult)
                {
                    if (rollResult == false) return "failed roll";
                    if (statResult == false) return "failed stat check";
                    return "success";
                };
            
                local stat_self = actorProps[internalStatName];
                local stat_self_modified = stat_self + statModifier;
                local stat_target = targetProps[internalStatName];
                local roll_result = roll < chance;
                local stat_result = stat_self_modified < stat_target;

                if (::ScalingAvatar.VerboseLogging)
                {
                    local text = "rolling " + statName + ": " + roll + " vs " + chance + "% (" + roll_result_str(roll_result, stat_result) + ") (raw: " + stat_self + ", mod: " + stat_self_modified + " vs " + stat_target + ")";
                    ::ScalingAvatar.Mod.Debug.printLog(text, "debug");
                    this.Tactical.EventLog.log(text);
                }

                if (roll_result == false)
                    return;
                if (stat_result == false)
                    return;

                actorProps[internalStatName] += 1;
                ::ScalingAvatar.IncrementStatTag(this, statTagName);
                learned_something = true;
                learned_string += "[color=" + this.Const.UI.Color.PositiveValue + "]+1[/color] " + statName + ", ";
            };

            roll_handler("Hitpoints", "Hitpoints", "HitpointsGained", scaling_roll_hitpoints, chance_hitpoints, modifier_hitpoints);
            roll_handler("Bravery", "Resolve", "BraveryGained", scaling_roll_resolve, chance_resolve, modifier_resolve);
            roll_handler("Stamina", "Fatigue", "StaminaGained", scaling_roll_fatigue, chance_fatigue, modifier_fatigue);
            roll_handler("MeleeSkill", "Melee Skill", "MeleeSkillGained", scaling_roll_melee_attack, chance_melee_attack, modifier_melee_attack);
            roll_handler("RangedSkill", "Ranged Skill", "RangedSkillGained", scaling_roll_ranged_attack, chance_ranged_attack, modifier_ranged_attack);
            roll_handler("MeleeDefense", "Melee Defense", "MeleeDefenseGained", scaling_roll_melee_defense, chance_melee_defense, modifier_melee_defense);
            roll_handler("RangedDefense", "Ranged Skill", "RangedDefenseGained", scaling_roll_ranged_defense, chance_ranged_defense, modifier_ranged_defense);
            roll_handler("Initiative", "Initiative", "InitiativeGained", scaling_roll_initiative, chance_initiative, modifier_initiative);

            // remove ", "  from end of string using slice function
            if (learned_string != "") {
                local length = learned_string.len();
                learned_string = learned_string.slice(0, length - 2);
            }

            learned_string += ".";

            if (learned_something) {
                this.Tactical.EventLog.log(actor.getName() + " has acquired new attributes: " + learned_string);
            }
        };

        local scalingAvatarOnTargetKilledPerks = function(_targetEntity, _skill) {
            local actor = this.getContainer().getActor();
            local actor_level = actor.getLevel();
            local target_level = _targetEntity.getLevel();
            local level_difference = this.Math.max(target_level - actor_level, 0);

            local scaling_roll_perk = Math.rand(0, 100);
            local scaling_roll_perk_chance = ::ScalingAvatar.Settings.PerkRollPercent.getValue().tointeger();
            local success_roll_perk = scaling_roll_perk < scaling_roll_perk_chance;

            ::ScalingAvatar.VerboseLogDebug("rolling for perk increase...");

            if (::ScalingAvatar.VerboseLogging)
            {
                local result_str_perk = "failure";
                if (success_roll_perk)
                    result_str_perk = "success";
                local text = "ScalingAvatar: rolling perk: " + scaling_roll_perk + " vs " + scaling_roll_perk_chance + "% (" + result_str_perk + ")";
                ::ScalingAvatar.Mod.Debug.printLog(text, "debug");
                this.Tactical.EventLog.log(text);
            }

            if (success_roll_perk == false)
                return;

            local target_skills = _targetEntity.getSkills().getSkillsByFunction(@(skill) skill.isType(::Const.SkillType.Perk));
            local target_skills_clean = target_skills.filter(function(index, val) {
                local perk_id = val.getID();
                if (perk_id == "perk.stalwart" || perk_id == "perk.legend_composure" || perk_id == "perk.battering_ram")
                    return false;
                if (actor.getSkills().hasSkill(perk_id))
                    return false;
                return true;
            });

            if (target_skills_clean.len() == 0)
                return;

            local perk_index = ::Math.rand(0, target_skills_clean.len() - 1);
            local perk = target_skills_clean[perk_index];

            foreach(i, v in this.Const.Perks.PerkDefObjects)
            {
                if (perk.getID() == v.ID) {
                    if (v.Script != "") {
                        this.Tactical.EventLog.log("[color=#3b3fe7]" + actor.getName() + "[/color] learned [color=#3b3fe7]" + perk.getName() + "[/color] from his enemy!");
                        actor.m.PerkPointsSpent++;
                        actor.getSkills().add(this.new(v.Script));
                        local rowToAddPerk = 0;
                        local length = actor.getBackground().getPerkTree()[0].len();
                        foreach(i, row in actor.getBackground().getPerkTree()) {
                            if (row.len() < length) rowToAddPerk = i;
                        }
                        actor.getBackground().addPerk(i, rowToAddPerk);
                        break;
                    }
                }
            }
        };

        local base_onTargetKilled = ::mods_getMember(o, "onTargetKilled");
        ::mods_override(o, "onTargetKilled", function(_targetEntity, _skill) {
            base_onTargetKilled(_targetEntity, _skill);

            local actor = this.getContainer().getActor();
            local background = actor.getBackground().getID();

            if (background == "background.legend_commander_beggar_op")
            {
                ::ScalingAvatar.VerboseLogDebug("skipping because already scaling beggar...");
                return;
            }

            scalingAvatarOnTargetKilledStats(_targetEntity, _skill);
            scalingAvatarOnTargetKilledPerks(_targetEntity, _skill);
        });
    });
});