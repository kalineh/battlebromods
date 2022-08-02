
// TODO:
// - apply bonus stats easier
// - remove avatar built-in resolve
// IDEAS:
// - scale gain rates with stars
// - scale gain rates with starting stats

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
    Version = "0.0.2",
    StatBonusFlat = 0,
    ToggleSeperateStatRoll = true,
    StatRollPercent = 100,
    PerkRollPercent = 100,
    VerboseLogging = true,

    VerboseLogDebug = function(str) {
        if (::ScalingAvatar.VerboseLogging == false)
            return;

        ::ScalingAvatar.Mod.Debug.printLog("ScalingAvatar: " + str, "debug");
    },

    VerboseLogRoll = function(str, roll, chance) {
        if (::ScalingAvatar.VerboseLogging == false)
            return;

        local result_str = "failure";
        if (roll < chance)
            result_str = "success";

        local text = "ScalingAvatar: " + str + " (rolled " + roll + " with chance " + chance + "% (" + result_str + ")";

        ::ScalingAvatar.Mod.Debug.printLog(text, "debug");
        this.Tactical.EventLog.log(text);
    },
}

::mods_registerMod(::ScalingAvatar.ID, ::ScalingAvatar.Version, ::ScalingAvatar.Name);
::mods_queue(::ScalingAvatar.ID, "mod_legends", function() {

    ::ScalingAvatar.Mod <- ::MSU.Class.Mod(::ScalingAvatar.ID, ::ScalingAvatar.Version, ::ScalingAvatar.Name);
    ::ScalingAvatar.Mod.Debug.setFlag("debug", true)

    // MSU options setup

    local page = ::ScalingAvatar.Mod.ModSettings.addPage("General");

    local settingStat = page.addRangeSetting("StatRollPercent", 1, 1, 100, 1.0, "Stat Roll Percent", "Chance of gaining stats from killed enemy.");
    local settingPerk = page.addRangeSetting("PerkRollPercent", 1, 1, 100, 1.0, "Perk Roll Percent", "Chance of gaining perks from killed enemy.");
    local settingSeperate = page.addBooleanSetting("StatRollSeperate", false, "Seperate Stat Rolls", "Roll for stat gain per individual stat.");
    local settingFlat = page.addRangeSetting("StatFlat", 1, 1, 100, 1.0, "Stat Flat Bonus", "Additional flat bonus to all stats.");
    local settingVerbose = page.addBooleanSetting("VerboseLogging", false, "Verbose Logging", "Verbose logging for debugging.");

    settingStat.addCallback(function(_value) { ::ScalingAvatar.StatRollPercent = _value; });
    settingPerk.addCallback(function(_value) { ::ScalingAvatar.PerkRollPercent = _value; });
    settingSeperate.addCallback(function(_value) { ::ScalingAvatar.ToggleSeperateStatRoll = _value; });
    settingFlat.addCallback(function(_value) { ::ScalingAvatar.StatBonusFlat = _value.tointeger(); });
    settingVerbose.addCallback(function(_value) { ::ScalingAvatar.VerboseLogging = _value; });

    // actual scaling code

    ::mods_hookExactClass("skills/traits/player_character_trait", function(o) {

        readStatTag = function(tagName) {
            return this.getContainer().getActor().getLifetimeStats().Tags.getAsInt(tagName);
        }

        readStatTags = function() {
            return {
                HitpointsGained = readStatTag("HitpointsGained"),
                BraveryGained = readStatTag("BraveryGained"),
                StaminaGained = readStatTag("StaminaGained"),
                MeleeSkillGained = readStatTag("MeleeSkillGained"),
                RangedSkillGained = readStatTag("RangedSkillGained"),
                MeleeDefenseGained = readStatTag("MeleeDefenseGained"),
                RangedDefenseGained = readStatTag("RangedDefenseGained"),
                InitiativeGained = readStatTag("InitiativeGained"),
            };
        };

        incrementTag = function(tagName) {
            this.getContainer().getActor().getLifetimeStats().Tags.increment(tagName);
        };

        local getTooltip = ::mods_getMember(o, "getTooltip");
        ::mods_override(o, "getTooltip", function(o) {
            local results = getTooltip(o);

            local actor = this.getContainer().getActor();
            local stats = readStatTags();

            local format_text = function(statName, statValue) {
                return "[color=" + this.Const.UI.Color.PositiveValue + "]+" + statValue + "[/color] " + statName + " gained due to scaling effect.";
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

        function onTargetKilledStats(_targetEntity, _skill) {
            local actorProps = actor.getBaseProperties();
            local targetProps = targetEntity.getBaseProperties();

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

            if (::ScalingAvatar.StatRollSeperate == false)
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

            local success_roll_hitpoints = scaling_roll_hitpoints < ::ScalingAvatar.StatRollPercent;
            local success_roll_resolve = scaling_roll_resolve < ::ScalingAvatar.StatRollPercent;
            local success_roll_fatigue = scaling_roll_fatigue < ::ScalingAvatar.StatRollPercent;
            local success_roll_melee_attack = scaling_roll_melee_attack < ::ScalingAvatar.StatRollPercent;
            local success_roll_ranged_attack = scaling_roll_ranged_attack < ::ScalingAvatar.StatRollPercent;
            local success_roll_melee_defense = scaling_roll_melee_defense < ::ScalingAvatar.StatRollPercent;
            local success_roll_ranged_defense = scaling_roll_ranged_defense < ::ScalingAvatar.StatRollPercent;
            local success_roll_initiative = scaling_roll_initiative < ::ScalingAvatar.StatRollPercent;

            ::ScalingAvatar.VerboseLogDebug("rolling for stat increase...");
            ::ScalingAvatar.VerboseLogRoll("hitpoints", scaling_roll_hitpoints, ::ScalingAvatar.StatRollPercent);
            ::ScalingAvatar.VerboseLogRoll("fatigue", scaling_roll_fatigue, ::ScalingAvatar.StatRollPercent);
            ::ScalingAvatar.VerboseLogRoll("resolve", scaling_roll_resolve, ::ScalingAvatar.StatRollPercent);
            ::ScalingAvatar.VerboseLogRoll("melee_attack", scaling_roll_melee_attack, ::ScalingAvatar.StatRollPercent);
            ::ScalingAvatar.VerboseLogRoll("ranged_attack", scaling_roll_ranged_attack, ::ScalingAvatar.StatRollPercent);
            ::ScalingAvatar.VerboseLogRoll("melee_defense", scaling_roll_melee_defense, ::ScalingAvatar.StatRollPercent);
            ::ScalingAvatar.VerboseLogRoll("ranged_defense", scaling_roll_ranged_defense, ::ScalingAvatar.StatRollPercent);
            ::ScalingAvatar.VerboseLogRoll("initiative", scaling_roll_initiative, ::ScalingAvatar.StatRollPercent);

            local roll_handler = function(internalStatName, statName, tagName, rollSuccess) {
                if (rollSuccess == false)
                    return;
                if (actorProps[internalStatName] > targetProps[internalStatName])
                    return;

                actorProps[internalStatName] += 1;
                incrementTag(tagName);
                learned_something = true;
                learned_string += "[color=" + this.Const.UI.Color.PositiveValue + "]+1[/color] " + statName + ", ";
            };

            roll_handler("Hitpoints", "Hitpoints", "HitpointsGained", success_roll_hitpoints);
            roll_handler("Bravery", "Resolve", "HitpointsGained", success_roll_resolve);
            roll_handler("Stamina", "Fatigue", "StaminaGained", success_roll_fatigue);
            roll_handler("MeleeSkill", "Melee Skill", "MeleeSkillGained", success_roll_melee_attack);
            roll_handler("RangedSkill", "Ranged Skill", "RangedSkillGained", success_roll_ranged_attack);
            roll_handler("MeleeDefense", "Melee Defense", "MeleeDefenseGained", success_roll_melee_defense);
            roll_handler("RangedDefense", "Ranged Skill", "RangedDefenseGained", success_roll_ranged_defense);
            roll_handler("Initiative", "Initiative", "InitiativeGained", success_roll_initiative);

            // remove ", "  from end of string using slice function
            if (learned_string != "") {
                local length = learned_string.len();
                learned_string = learned_string.slice(0, length - 2);
            }

            learned_string += ".";

            if (learned_something) {
                this.Tactical.EventLog.log(actor.getName() + " has acquired new attributes: " + learned_string);
            }
        }

        function onTargetKilledPerks(_targetEntity, _skill) {
            local scaling_roll_perk = Math.rand(0, 100);
            local success_roll_perk = scaling_roll_perk < ::ScalingAvatar.PerkRollPercent;

            ::ScalingAvatar.VerboseLogDebug("rolling for perk increase...");
            ::ScalingAvatar.VerboseLogRoll("perk", scaling_roll_perk, ::ScalingAvatar.PerkRollPercent);

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

            local candidate_index = ::Math.rand(0, candidate_perks.len() - 1);
            local perk = candidate_perks[candidate_index];

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
        }

        local onTargetKilled = ::mods_getMember(o, "onTargetKilled");
        ::mods_override(o, "onTargetKilled", function(_targetEntity, _skill) {
            onTargetKilled(_targetEntity, _skill);

            if (background == "background.legend_commander_beggar_op")
            {
                ::ScalingAvatar.VerboseLogDebug("skipping because already scaling beggar...");
                return;
            }

            onTargetKilledStats(_targetEntity, _skill);
            onTargetKilledPerks(_targetEntity, _skill);
        });
    });
});