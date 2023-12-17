this.divine_spark_ascended_trait <- ::inherit("scripts/skills/traits/character_trait", {
	m = {},
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.divine_spark_ascended";
		this.m.Name = "Divine Spark (Ascended)";
		this.m.Description = "This character's essence has ascended mortal limitations."
		this.m.Icon = "ui/traits/trait_icon_39.png";
		this.m.Titles = [
		];
		this.m.Excluded = [
		];
	},

	function getTooltip()
	{
		local tooltip = this.skill.getTooltip();
		local apBonus = this.getActionPointBonus();

		tooltip.extend([
			{
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]+" + apBonus + "[/color] Action Points"
			}
		]);

		return tooltip;
	},

	function getActionPointBonus()
	{
		local level = this.getContainer().getActor().getLevel();
		local bonus = 1;

		if (level >= 3) bonus += 1;
		if (level >= 7) bonus += 1;
		if (level >= 11) bonus += 1;

		return bonus;
	},

	function onUpdate( _properties )
	{
		local actor = this.getContainer().getActor();
		local apBonus = this.getActionPointBonus();

		_properties.ActionPoints += apBonus;
	}
});
