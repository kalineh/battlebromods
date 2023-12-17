this.divine_spark_wisdom_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.divine_spark_wisdom";
		this.m.Name = "Divine Spark (Wisdom)";
		this.m.Description = "This character's soul is one with divine wisdom."
		this.m.Icon = "ui/traits/trait_icon_39.png";
		this.m.Titles = [
		];
		this.m.Excluded = [
		];
	},

	function getTooltip()
	{
		local tooltip = this.skill.getTooltip();
		local tooltipText = "";

		for (local i = 0; i < 11; i = ++i)
		{
			local level = (i + 1);
			local bonus = getPerkBonusAtLevel(level);

			if (bonus > 0)
				tooltipText += "[color=" + ::Const.UI.Color.PositiveValue + "]+" + bonus + "[/color] perk at level " + level + ".\n";
		}

		tooltip.extend([
			{
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = tooltipText
			}
		]);

		return tooltip;
	},

	function getPerkBonusAtLevel(_level)
	{
		if (_level == 1) return 1;
		if (_level == 3) return 1;
		if (_level == 7) return 1;
		if (_level == 11) return 2;

		return 0;
	},
});
