this.mod_scaling_avatar_bro_trait <- this.inherit("scripts/skills/traits/character_trait", {
	m = { },
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.scaling_avatar_bro";
		this.m.Name = "Scaling Avatar (Bro)";
		this.m.Icon = "ui/traits/trait_icon_19.png";
		this.m.Description = "Gains perks and stats from enemy kills (bro edition).";
		this.m.Titles = [
		];
		this.m.Excluded = [
		];
	}

	function getTooltip()
	{
        local actor = this.getContainer().getActor();
        local stats = ::ScalingAvatar.ReadStatTags(this);
        local results = [ ];
            
        local format_text = function(statName, statValue) {
            return "[color=" + this.Const.UI.Color.PositiveValue + "]+" + statValue + "[/color] " + statName;
        };

        local chanceText = "";
        if (this.m.ID == "trait.scaling_avatar_bro")
            chanceText = " (" + ::ScalingAvatar.Settings.ApplyToBroRate + "% rate)";

        results.append({ id = 1, type = "title", text = this.getName(), });
        results.append({ id = 2, type = "description", text = this.getDescription() + chanceText, });

        results.append({ id = 10, type = "text", icon = "ui/icons/health.png", text = format_text("Hitpoints", stats.HitpointsGained), });
        results.append({ id = 10, type = "text", icon = "ui/icons/bravery.png", text = format_text("Resolve", stats.BraveryGained), });
        results.append({ id = 10, type = "text", icon = "ui/icons/fatigue.png", text = format_text("Fatigue", stats.StaminaGained), });
        results.append({ id = 10, type = "text", icon = "ui/icons/initiative.png", text = format_text("Initiative", stats.InitiativeGained), });
        results.append({ id = 10, type = "text", icon = "ui/icons/melee_skill.png", text = format_text("Melee Skill", stats.MeleeSkillGained), });
        results.append({ id = 10, type = "text", icon = "ui/icons/ranged_skill.png", text = format_text("Ranged Skill", stats.RangedSkillGained), });
        results.append({ id = 10, type = "text", icon = "ui/icons/melee_defense.png", text = format_text("Melee Defense", stats.MeleeDefenseGained), });
        results.append({ id = 10, type = "text", icon = "ui/icons/ranged_defense.png", text = format_text("Ranged Defense", stats.RangedDefenseGained), });

        return results;
	}

	function onUpdate( _properties )
	{
		local stats = ::ScalingAvatar.ReadStatTags(this);

		_properties.Hitpoints += stats.HitpointsGained;
		_properties.Bravery += stats.BraveryGained;
		_properties.Stamina += stats.StaminaGained;
		_properties.Initiative += stats.InitiativeGained;
		_properties.MeleeSkill += stats.MeleeSkillGained;
		_properties.RangedSkill += stats.RangedSkillGained;
		_properties.MeleeDefense += stats.MeleeDefenseGained;
		_properties.RangedDefense += stats.RangedDefenseGained;
	}

	function onTargetKilled( _targetEntity, _skill )
	{
        local actor = this.getContainer().getActor();
        local background = actor.getBackground().getID();

        if (background == "background.legend_commander_beggar_op")
        {
            ::ScalingAvatar.VerboseLogDebug("skipping because already scaling beggar...");
            return;
        }

        local rollChance = 100;

        if (this.m.ID = "trait.scaling_avatar_bro")
        {
            rollChance = ::ScalingAvatar.Settings.ApplyToBroRate;
        }


        scalingAvatarOnTargetKilledStats(_targetEntity, _skill);
        scalingAvatarOnTargetKilledPerks(_targetEntity, _skill);
	}

    function scalingAvatarOnTargetKilledStats(_targetEntity, _skill)
    {
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
        local pctStar = ::ScalingAvatar.Settings.StatRollPercentPerStar.getValue().tointeger();

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
    }

    function scalingAvatarOnTargetKilledPerks (_targetEntity, _skill)
    {
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
    }
});

