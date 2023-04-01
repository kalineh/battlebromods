::ModPartyNamed <- {
    ID = "mod_party_named",
    Name = "PartyNamed",
    Version = "0.0.1",
}

::mods_registerMod(::ModPartyNamed.ID, ::ModPartyNamed.Version, ::ModPartyNamed.Name);
::mods_queue(::ModPartyNamed.ID, "mod_msu, >mod_reforged", function()
{
    ::ModPartyNamed.Mod <- ::MSU.Class.Mod(::ModPartyNamed.ID, ::ModPartyNamed.Version, ::ModPartyNamed.Name);

    this.logDebug("ModPartyNamed: registered mod, hooking new object...");

	::mods_hookExactClass("entity/world/party", function(o)
	{
		local onDropLootForPlayer = o.onDropLootForPlayer;
		o.onDropLootForPlayer = function(_loottable)
		{
			// TODO: MSU settings

			local defeated = this.World.Statistics.getFlags().getAsInt("LastEnemiesDefeatedCount");
			local chance = 1 + (defeated / 4);
			local roll = this.Math.rand(0, 100);

		    this.logDebug("ModPartyNamed: roll " + roll + " vs chance " + chance + "%");

			if (roll < chance)
			{
				local weapons = clone this.Const.Items.NamedWeapons;
				local shields = clone this.Const.Items.NamedShields;
				local helmets = clone this.Const.Items.NamedHelmets;
				local armors = clone this.Const.Items.NamedArmors;
				local rollType = this.Math.rand(0, 100);

				local result = "";

				// 15% shields, 25% helmets, 25% armors, 35% weapons

				if (rollType <= 15)
					result = shields[this.Math.rand(0, shields.len() - 1)];
				else if (rollType <= 40)
					result = helmets[this.Math.rand(0, helmets.len() - 1)];
				else if (rollType <= 55)
					result = armors[this.Math.rand(0, armors.len() - 1)];
				else
					result = weapons[this.Math.rand(0, weapons.len() - 1)];

			    this.logDebug("ModPartyNamed: > chose " + result);

				// NOTE: why did original mod do this?
				//foreach (item in ::IO.enumerateFiles("scripts/items/misc")) 
				//{
				//	items.push("misc/" + split(item, "/").pop());
				//}


			    if (result != "")
					_loottable.push(this.new("scripts/items/" + result));
			}

			onDropLootForPlayer(_loottable);
		}
	})
})
