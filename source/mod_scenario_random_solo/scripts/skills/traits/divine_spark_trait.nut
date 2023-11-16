this.divine_spark_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.divine_spark";
		this.m.Name = "Divine Spark";
		this.m.Description = "This character has a divine spark, the makings of a true hero."
		this.m.Icon = "ui/traits/trait_icon_39.png";
		this.m.Titles = [
		];
		this.m.Excluded = [
		];
	}

	function getTooltip()
	{
		local tooltip = this.skill.getTooltip();

		local skillBonus = this.getSkillBonus();

		tooltip.extend([
			{
				id = 10,
				type = "text",
				icon = "ui/icons/health.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]-" + skillMalus + "[/color] Hitpoints"
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/fatigue.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]-" + skillMalus + "[/color] Fatigue"
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/melee_skill.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]+" + skillBonus + "[/color] Melee Skill"
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/melee_defense.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]+" + skillBonus + "[/color] Melee Defense"
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/ranged_skill.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]+" + skillBonus + "[/color] Ranged Skill"
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/ranged_defense.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]+" + skillBonus + "[/color] Ranged Defense"
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/bravery.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]+" + skillBonus + "[/color] Resolve"
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/initiative.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]-" + skillBonus + "[/color] Initiative"
			}
		]);

		return tooltip;
	}


	function getSkillBonus()
	{
		local level = return this.getContainer().getActor().getLevel();
		local bonus = level * 1;

		if (level >= 3) bonus += 1;
		if (level >= 7) bonus += 1;
		if (level >= 11) bonus += 3;

		return bonus;
	}

	function onUpdate( _properties )
	{
		local actor = this.getContainer().getActor();
		if (this.isEnabled())
		{
			local skillBonus = this.getSkillBonus();
			_properties.Hitpoints += skillBonus;
			_properties.Stamina += skillBonus;
			_properties.MeleeSkill += skillBonus;
			_properties.MeleeDefense += skillBonus;
			_properties.RangedSkill += skillBonus;
			_properties.RangedDefense += skillBonus;
			_properties.Bravery += skillBonus;
			_properties.Initiative += skillBonus;
			_properties.DamageDirectAdd += skillBonus * 0.01;			
		}

		local skillMalus = this.getSkillMalus();
		_properties.Stamina -= skillMalus;
		_properties.Initiative -= skillMalus;
		_properties.Hitpoints -= skillMalus;
	}
});
