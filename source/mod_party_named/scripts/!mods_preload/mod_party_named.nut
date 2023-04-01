::ModPartyNamed <- {
    ID = "mod_party_named",
    Name = "PartyNamed",
    Version = "0.0.1",
}

::mods_registerMod(::ModPartyNamed.ID, ::ModPartyNamed.Version, ::ModPartyNamed.Name);
::mods_queue(::ModPartyNamed.ID, "mod_msu, >mod_reforged", function()
{
    ::ModPartyNamed.Mod <- ::MSU.Class.Mod(::ModPartyNamed.ID, ::ModPartyNamed.Version, ::ModPartyNamed.Name);

	::mods_hookNewObject("entity/world/party", function(o)
	{
		local onDropLootForPlayer = o.onDropLootForPlayer;
		o.onDropLootForPlayer = function(_loottable)
		{
			local defeated = this.World.Statistics.getFlags().getAsInt("LastEnemiesDefeatedCount");
			local buffer = 182; // TODO: MSU setting
			buffer = 1; // testing
			local roll = this.Math.rand(0, buffer);

		    this.logDebug("ModPartyNamed: rolled " + roll + " against " + buffer);

			//if (roll < defeated)
			//{
				local items = clone ::Const.Items.NamedWeapons;
				items.extend(clone ::Const.Items.NamedShields);
                items.extend(clone ::Const.Items.LegendNamedArmorLayers);
				items.extend(clone ::Const.Items.LegendNamedHelmetLayers);

				foreach (item in ::IO.enumerateFiles("scripts/items/misc")) 
				{
					items.push("misc/" + split(item, "/").pop());
				}

		    	local choice = items[this.Math.rand(0, items.len() - 1)];

			    this.logDebug("ModPartyNamed: rolled choice: " + choice);

				_loottable.push(this.new("scripts/items/" + choice));
			//}

			onDropLootForPlayer(_loottable);
		}
	})
})
