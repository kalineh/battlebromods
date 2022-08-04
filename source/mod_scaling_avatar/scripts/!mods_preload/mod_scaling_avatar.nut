// CHANGELOG:
// 0.0.1
// - imported from druwski code
// - added percentage scaling
// - added msu options config
// 0.0.2
// - rewrite and simplify codebase
// - added talent-based modifiers

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
    Version = "0.0.2",
    StatBonusFlat = 0,
    ToggleSeperateStatRoll = true,
    StatRollPercent = 25,
    StatRollModifier = -10,
    StatRollPercentPerStar = 10,
    StatRollModifierPerStar = -5,
    PerkRollPercent = 25,
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

    // MSU options setup

    local page = ::ScalingAvatar.Mod.ModSettings.addPage("General");

    //function addRangeSetting( _id, _value, _min, _max, _step, _name = null, _description = null )

    local settingStat = page.addRangeSetting("StatRollPercent", 25, 0, 100, 1.0, "Stat Roll Percent", "Chance of gaining stats from killed enemy.");
    local settingStatPerStar = page.addRangeSetting("StatRollPercentPerStar", 10, 0, 100, 1.0, "Stat Roll Percent Per Star", "Extra gain chance per talent star.");
    local settingStatMod = page.addRangeSetting("StatRollModifier", -10, -100, 100, 1.0, "Stat Roll Modifier", "Extra difference between stats check (lower means easier gain).");
    local settingStatModPerStar = page.addRangeSetting("StatRollModifierPerStar", -5, -100, 100, 1.0, "Stat Roll Modifier Per Star", "Extra difference between stats check per star.");

    local settingPerk = page.addRangeSetting("PerkRollPercent", 1, 25, 100, 1.0, "Perk Roll Percent", "Chance of gaining perks from killed enemy.");
    //local settingFlat = page.addRangeSetting("StatFlat", 1, 1, 100, 1.0, "Stat Flat Bonus", "Additional flat bonus to all stats.");

    local settingSeperate = page.addBooleanSetting("ToggleSeperateStatRoll", false, "Seperate Stat Rolls", "Roll for stat gain per individual stat.");
    local settingVerbose = page.addBooleanSetting("VerboseLogging", false, "Verbose Logging", "Verbose logging for debugging.");

    settingStat.addCallback(function(_value) { ::ScalingAvatar.StatRollPercent = _value; });
    settingPerk.addCallback(function(_value) { ::ScalingAvatar.PerkRollPercent = _value; });
    settingSeperate.addCallback(function(_value) { ::ScalingAvatar.ToggleSeperateStatRoll = _value; });
    //settingFlat.addCallback(function(_value) { ::ScalingAvatar.StatBonusFlat = _value.tointeger(); });
    settingVerbose.addCallback(function(_value) { ::ScalingAvatar.VerboseLogging = _value; });

    // actual scaling code

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
            
            ::ScalingAvatar.Mod.Debug.printLog("ScalingAvatar: func1", "debug");
            local format_text = function(statName, statValue) {
                //return format("[color=%s]+%d[/color] %s gained due to scaling effect", this.Const.UI.Color.PositiveValue, statValue, statName);
                return "[color=" + this.Const.UI.Color.PositiveValue + "]+" + statValue + "[/color] " + statName + " gained due to scaling effect";
            };
            ::ScalingAvatar.Mod.Debug.printLog("ScalingAvatar: func2", "debug");

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

            if (::ScalingAvatar.ToggleSeperateStatRoll == false)
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

                //local talents = _event.m.Dude.getTalents();
                //talents.resize(this.Const.Attributes.COUNT, 0);
                //talents[this.Const.Attributes.MeleeSkill] = 2;
                //talents[this.Const.Attributes.MeleeDefense] = 3;
                //talents[this.Const.Attributes.RangedDefense] = 3;

            local talents = actor.getTalents();

            local pct = ::ScalingAvatar.StatRollPercent;
            local pctStar = ::ScalingAvatar.StatRollPercentPerStar;

            local chance_hitpoints = pct + pctStar * talents[this.Const.Attributes.Hitpoints];
            local chance_resolve = pct + pctStar * talents[this.Const.Attributes.Bravery];
            local chance_fatigue = pct + pctStar * talents[this.Const.Attributes.Stamina];
            local chance_melee_attack = pct + pctStar * talents[this.Const.Attributes.MeleeAtack];
            local chance_ranged_attack = pct + pctStar * talents[this.Const.Attributes.RangedAttack];
            local chance_melee_defense = pct + pctStar * talents[this.Const.Attributes.MeleeDefense];
            local chance_ranged_defense = pct + pctStar * talents[this.Const.Attributes.RangedDefense];
            local chance_initiative = pct + pctStar * talents[this.Const.Attributes.Initiative];

            local success_roll_hitpoints = scaling_roll_hitpoints < chance_hitpoints;
            local success_roll_resolve = scaling_roll_resolve < chance_resolve;
            local success_roll_fatigue = scaling_roll_fatigue < chance_fatigue;
            local success_roll_melee_attack = scaling_roll_melee_attack < chance_melee_attack;
            local success_roll_ranged_attack = scaling_roll_ranged_attack < chance_ranged_attack;
            local success_roll_melee_defense = scaling_roll_melee_defense < chance_melee_defense;
            local success_roll_ranged_defense = scaling_roll_ranged_defense < chance_ranged_defense;
            local success_roll_initiative = scaling_roll_initiative < chance_initiative;

            ::ScalingAvatar.VerboseLogDebug("rolling for stat increase...");
            ::ScalingAvatar.VerboseLogRoll("hitpoints", scaling_roll_hitpoints, chance_hitpoints);
            ::ScalingAvatar.VerboseLogRoll("fatigue", scaling_roll_fatigue, chance_fatigue);
            ::ScalingAvatar.VerboseLogRoll("resolve", scaling_roll_resolve, chance_resolve);
            ::ScalingAvatar.VerboseLogRoll("melee_attack", scaling_roll_melee_attack, chance_melee_attack);
            ::ScalingAvatar.VerboseLogRoll("ranged_attack", scaling_roll_ranged_attack, chance_ranged_attack);
            ::ScalingAvatar.VerboseLogRoll("melee_defense", scaling_roll_melee_defense, chance_melee_defense);
            ::ScalingAvatar.VerboseLogRoll("ranged_defense", scaling_roll_ranged_defense, chance_ranged_defense);
            ::ScalingAvatar.VerboseLogRoll("initiative", scaling_roll_initiative, chance_initiative);

            local roll_handler = function(internalStatName, statName, tagName, rollSuccess, statModifier) {
                if (rollSuccess == false)
                    return;
                if (actorProps[internalStatName] > targetProps[internalStatName] + statModifier)
                    return;

                actorProps[internalStatName] += 1;
                ::ScalingAvatar.IncrementStatTag(this, tagName);
                learned_something = true;
                learned_string += "[color=" + this.Const.UI.Color.PositiveValue + "]+1[/color] " + statName + ", ";
            };

            local modifier = ::ScalingAvatar.StatRollModification;
            local modifierStar = ::ScalingAvatar.StatRollModifierPerStar;

            local modifier_hitpoints = modifier + modifierStar * talents[this.Const.Attributes.Hitpoints];
            local modifier_resolve = modifier + modifierStar * talents[this.Const.Attributes.Bravery];
            local modifier_fatigue = modifier + modifierStar * talents[this.Const.Attributes.Stamina];
            local modifier_melee_attack = modifier + modifierStar * talents[this.Const.Attributes.MeleeAtack];
            local modifier_ranged_attack = modifier + modifierStar * talents[this.Const.Attributes.RangedAttack];
            local modifier_melee_defense = modifier + modifierStar * talents[this.Const.Attributes.MeleeDefense];
            local modifier_ranged_defense = modifier + modifierStar * talents[this.Const.Attributes.RangedDefense];
            local modifier_initiative = modifier + modifierStar * talents[this.Const.Attributes.Initiative];

            roll_handler("Hitpoints", "Hitpoints", "HitpointsGained", success_roll_hitpoints, modifier_hitpoints);
            roll_handler("Bravery", "Resolve", "BraveryGained", success_roll_resolve, modifier_resolve);
            roll_handler("Stamina", "Fatigue", "StaminaGained", success_roll_fatigue, modifier_fatigue);
            roll_handler("MeleeSkill", "Melee Skill", "MeleeSkillGained", success_roll_melee_attack, modifier_melee_attack);
            roll_handler("RangedSkill", "Ranged Skill", "RangedSkillGained", success_roll_ranged_attack, modifier_ranged_attack);
            roll_handler("MeleeDefense", "Melee Defense", "MeleeDefenseGained", success_roll_melee_defense, modifier_melee_defense);
            roll_handler("RangedDefense", "Ranged Skill", "RangedDefenseGained", success_roll_ranged_defense, modifier_ranged_defense);
            roll_handler("Initiative", "Initiative", "InitiativeGained", success_roll_initiative, modifier_initiative);

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