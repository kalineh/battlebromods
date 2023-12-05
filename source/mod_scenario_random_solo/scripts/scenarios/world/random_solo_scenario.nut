this.random_solo_scenario <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},
	function create()
	{
		this.m.ID = "scenario.random_solo";
		this.m.Name = "Random Solo";
		this.m.Description = "[p=c][img]gfx/ui/events/event_35.png[/img][/p][p]You\'re alone and afraid, but it is time for bravery. You feel the spark of something that makes you special. \n[color=#bcad8c]Avatar:[/color] If your character dies, the campaign ends.[/p]";
		this.m.Difficulty = 2;
		this.m.Order = 50;
		this.m.IsFixedLook = true;
	}

	function isValid()
	{
		return true;
	}

	function addRandomTrait( _bro )
	{
		for ( local i = 0; i < 10; i = ++i )
		{
			local trait = this.Const.CharacterTraits[this.Math.rand(0, this.Const.CharacterTraits.len() - 1)];
			local traitId = trait[0];
			local traitScript = trait[1];

			//if (traitId == "trait.survivor") continue;
			//if (traitId == "trait.greedy") continue;
			//if (traitId == "trait.loyal") continue;
			//if (traitId == "trait.disloyal") continue;

			if (_bro.getSkills().hasSkill(traitId))
			{
				continue;
			}

			_bro.getSkills().add(this.new(traitScript));
			break;
		}
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();
		local bro;
		bro = roster.create("scripts/entity/tactical/player");
		//bro.setStartValuesEx([
			//"hedge_knight_background"
		//]);
		bro.setStartValuesEx(this.getroottable().Const.CharacterBackgrounds);

		bro.getBackground().m.RawDescription = "A lone wanderer, thrust into the world, ready to live or die.";
		bro.getBackground().buildDescription(true);
		bro.setTitle("the Lonely");

		addRandomTrait(bro); // +1 trait

		bro.getSkills().removeByID("trait.survivor");
		bro.getSkills().removeByID("trait.greedy");
		bro.getSkills().removeByID("trait.loyal");
		bro.getSkills().removeByID("trait.disloyal");
		bro.getSkills().add(this.new("scripts/skills/traits/player_character_trait"));
		bro.getSkills().add(this.new("scripts/skills/traits/divine_spark_trait"));

		bro.setPlaceInFormation(4);
		bro.getFlags().set("IsPlayerCharacter", true);
		bro.getSprite("miniboss").setBrush("bust_miniboss_lone_wolf");
		bro.m.HireTime = this.Time.getVirtualTimeF();
		bro.m.PerkPoints = 3; // +3 free perks
		bro.m.LevelUps = 0;
		bro.m.Level = 1;
		bro.getBaseProperties().Hitpoints += this.Math.rand(5, 15);
		bro.getBaseProperties().Stamina += this.Math.rand(5, 15);
		bro.getBaseProperties().MeleeSkill += this.Math.rand(4, 11)
		bro.getBaseProperties().MeleeDefense += this.Math.rand(4, 11);
		bro.getBaseProperties().RangedSkill += this.Math.rand(4, 11);
		bro.getBaseProperties().RangedDefense += this.Math.rand(4, 11);
		bro.getBaseProperties().Initiative += this.Math.rand(5, 15);
		bro.getBaseProperties().Bravery += this.Math.rand(5, 15);
		bro.m.Talents = [];
		bro.m.Attributes = [];
		local talents = bro.getTalents();
		talents.resize(this.Const.Attributes.COUNT, 0);
		if (this.Math.rand(0, 100) < 50) talents[this.Const.Attributes.Hitpoints] = this.Math.rand(0, 3);
		if (this.Math.rand(0, 100) < 50) talents[this.Const.Attributes.Fatigue] = this.Math.rand(0, 3);
		if (this.Math.rand(0, 100) < 50) talents[this.Const.Attributes.MeleeSkill] = this.Math.rand(0, 3);
		if (this.Math.rand(0, 100) < 50) talents[this.Const.Attributes.MeleeDefense] = this.Math.rand(0, 3);
		if (this.Math.rand(0, 100) < 50) talents[this.Const.Attributes.RangedSkill] = this.Math.rand(0, 3);
		if (this.Math.rand(0, 100) < 50) talents[this.Const.Attributes.RangedDefense] = this.Math.rand(0, 3);
		if (this.Math.rand(0, 100) < 50) talents[this.Const.Attributes.Initiative] = this.Math.rand(0, 3);
		if (this.Math.rand(0, 100) < 50) talents[this.Const.Attributes.Bravery] = this.Math.rand(0, 3);

		bro.getBaseProperties().Hitpoints += this.Math.rand(0, talents[this.Const.Attributes.Hitpoints] * 2);
		bro.getBaseProperties().Stamina += this.Math.rand(0, talents[this.Const.Attributes.Fatigue] * 2);
		bro.getBaseProperties().MeleeSkill += this.Math.rand(0, talents[this.Const.Attributes.MeleeSkill] * 2);
		bro.getBaseProperties().MeleeDefense += this.Math.rand(0, talents[this.Const.Attributes.MeleeDefense] * 1);
		bro.getBaseProperties().RangedSkill += this.Math.rand(0, talents[this.Const.Attributes.RangedSkill] * 2);
		bro.getBaseProperties().RangedDefense += this.Math.rand(0, talents[this.Const.Attributes.RangedDefense] * 1);
		bro.getBaseProperties().Initiative += this.Math.rand(0, talents[this.Const.Attributes.Initiative] * 2);
		bro.getBaseProperties().Bravery += this.Math.rand(0, talents[this.Const.Attributes.Bravery] * 1);

		bro.fillAttributeLevelUpValues(this.Const.XP.MaxLevelWithPerkpoints - 1);
		local items = bro.getItems();
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
		items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
		//items.equip(this.new("scripts/items/armor/sellsword_armor"));
		//items.equip(this.new("scripts/items/helmets/bascinet_with_mail"));
		//items.equip(this.new("scripts/items/weapons/longsword"));
		this.World.Assets.m.BusinessReputation = 10;
		this.World.Assets.getStash().resize(this.World.Assets.getStash().getCapacity() - 9);
		this.World.Assets.getStash().add(this.new("scripts/items/supplies/smoked_ham_item"));
		this.World.Assets.m.Money = this.World.Assets.m.Money * 2 - (this.World.Assets.getEconomicDifficulty() * 200); // actually translates to 1000 per difficulty for some reason
		//this.World.Assets.m.Money = this.World.Assets.m.Money / 2 - (this.World.Assets.getEconomicDifficulty() == 0 ? 0 : 100);
		//this.World.Assets.m.ArmorParts = this.World.Assets.m.ArmorParts / 2;
		//this.World.Assets.m.Medicine = this.World.Assets.m.Medicine / 3;
		//this.World.Assets.m.Ammo = this.World.Assets.m.Ammo / 3;
	}

	function onSpawnPlayer()
	{
		local randomVillage;

		for( local i = 0; i != this.World.EntityManager.getSettlements().len(); i = ++i )
		{
			randomVillage = this.World.EntityManager.getSettlements()[i];

			if (randomVillage.isMilitary() && !randomVillage.isIsolatedFromRoads() && randomVillage.getSize() >= 3 && !randomVillage.isSouthern())
			{
				break;
			}
		}

		local randomVillageTile = randomVillage.getTile();

		do
		{
			local x = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.X - 1), this.Math.min(this.Const.World.Settings.SizeX - 2, randomVillageTile.SquareCoords.X + 1));
			local y = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.Y - 1), this.Math.min(this.Const.World.Settings.SizeY - 2, randomVillageTile.SquareCoords.Y + 1));

			if (!this.World.isValidTileSquare(x, y))
			{
			}
			else
			{
				local tile = this.World.getTileSquare(x, y);

				if (tile.Type == this.Const.World.TerrainType.Ocean || tile.Type == this.Const.World.TerrainType.Shore)
				{
				}
				else if (tile.getDistanceTo(randomVillageTile) == 0)
				{
				}
				else if (!tile.HasRoad)
				{
				}
				else
				{
					randomVillageTile = tile;
					break;
				}
			}
		}
		while (1);

		this.World.State.m.Player = this.World.spawnEntity("scripts/entity/world/player_party", randomVillageTile.Coords.X, randomVillageTile.Coords.Y);
		this.World.Assets.updateLook(6);
		this.World.getCamera().setPos(this.World.State.m.Player.getPos());
		//this.Time.scheduleEvent(this.TimeUnit.Real, 1000, function ( _tag )
		//{
			//this.Music.setTrackList([
				//"music/noble_02.ogg"
			//], this.Const.Music.CrossFadeTime);
			//this.World.Events.fire("event.lone_wolf_scenario_intro");
		//}, null);
	}

	function onInit()
	{
		this.World.Assets.m.BrothersMax = 24;
	}

	function onCombatFinished()
	{
		local roster = this.World.getPlayerRoster().getAll();

		foreach( bro in roster )
		{
			if (bro.getFlags().get("IsPlayerCharacter"))
			{
				return true;
			}
		}

		return false;
	}

	function onUpdateLevel( _bro )
	{
		local skills = _bro.getSkills();
		local level = _bro.getLevel();

		if (skills.hasSkill("trait.divine_spark"))
		{
			local bonus = 0;

			if (level == 3) bonus = 1;
			if (level == 7) bonus = 1;
			if (level == 11) bonus = 2;

			if (bonus > 0)
				_bro.setPerkPoints(_bro.getPerkPoints() + bonus);
		}
	}

	function onActorKilled( _actor, _killer, _combatID )
	{
		// if has highlander trait, take perk
	}
});

