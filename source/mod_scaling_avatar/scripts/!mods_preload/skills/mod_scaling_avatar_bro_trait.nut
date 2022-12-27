this.scaling_avatar_trait <- this.inherit("scripts/skills/traits/mod_scaling_avatar_trait", {
	m = {},
	function create()
	{
		this.character_trait.create();
		this.m.ID = "trait.scaling_avatar_bro";
		this.m.Name = "Scaling Avatar Bro";
		this.m.Icon = "ui/traits/trait_icon_17.png";
		this.m.Description = "Gains some effects from Scaling Avatar leader.";
		this.m.Titles = [
		];
		this.m.Excluded = [
		];
	}
});

