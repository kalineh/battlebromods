::ModContractNamedFix <- {
    ID = "mod_contract_named_fix",
    Name = "ContractNamedFix",
    Version = "0.0.1",
}

::mods_registerMod(::ModContractNamedFix.ID, ::ModContractNamedFix.Version, ::ModContractNamedFix.Name);
::mods_queue(::ModContractNamedFix.ID, "mod_msu, >mod_reforged", function()
{
    ::ModContractNamedFix.Mod <- ::MSU.Class.Mod(::ModContractNamedFix.ID, ::ModContractNamedFix.Version, ::ModContractNamedFix.Name);

    this.logDebug("ModPartyNamed: registered mod, hooking new object...");
    
	::mods_hookExactClass("entity/world/location", function(o)
	{
		local onSpawned = o.onSpawned;
		o.onSpawned = function()
		{
		    onSpawned();

		    this.m.cached_named_items <- [];

		    // testing:
			//local weapons = clone this.Const.Items.NamedWeapons;
			//if (this.m.NamedWeaponsList != null && this.m.NamedWeaponsList.len() != 0)
			//{
				//weapons.extend(this.m.NamedWeaponsList);
				//weapons.extend(this.m.NamedWeaponsList);
			//}
			//this.m.Loot.add(this.new("scripts/items/" + weapons[this.Math.rand(0, weapons.len() - 1)]));

		   	foreach (item in this.m.Loot.getItems())
		   	{
			    this.logDebug("ModContractNamedFix: > item " + item.getName());

			    if (item.isItemType(this.Const.Items.ItemType.Named) || item.isItemType(this.Const.Items.ItemType.Legendary))
			    {
				    this.logDebug("ModContractNamedFix: > found named item " + item.getName());
				    this.m.cached_named_items.append(item);
			    }
			}
		}

		local onDropLootForPlayer = o.onDropLootForPlayer;
		o.onDropLootForPlayer = function(_lootTable)
		{
			local cached_named_items_unique <- [];

			// if it was not removed by a contract it will still be there
			foreach (item in this.m.Loot.getItems())
			{
				local exists = false;

				foreach (var item_cached in cached_named_items)
				{
					if (item == item_cached)
						exists = true;
				}

				if (exists == false)
					cached_named_items_unique.append(item);
			}

			onDropLootForPlayer(_lootTable);

			foreach (item in cached_named_items_unique)
			{
			    this.logDebug("ModContractNamedFix: adding named item back into table: " + item.getName());
			   	_lootTable.push(item); 
			}
		}
	})
})
