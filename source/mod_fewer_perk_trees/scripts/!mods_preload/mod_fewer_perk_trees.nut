::ModFewerPerkTrees <- {
    ID = "mod_fewer_perk_trees",
    Name = "Fewer Perk Trees",
    Version = "0.0.3",
}

::mods_registerMod(::ModFewerPerkTrees.ID, ::ModFewerPerkTrees.Version, ::ModFewerPerkTrees.Name);
::mods_queue(::ModFewerPerkTrees.ID, "mod_msu, >mod_reforged, >mod_dynamic_perk_trees", function()
{
    ::ModFewerPerkTrees.Mod <- ::MSU.Class.Mod(::ModFewerPerkTrees.ID, ::ModFewerPerkTrees.Version, ::ModFewerPerkTrees.Name);

    this.logDebug("ModFewerPerkTrees: registered mod...");

    ::mods_hookExactClass("mods/mod_dynamic_perks/classes/perk_tree", function(o) {
        local baseFunction = ::mods_getMember(o, "addFromDynamicMap");
        ::mods_override(o, "addFromDynamicMap", function() {

            // no way to hook the middle of the function how we want, so we have to 
            // duplicate most of the code

            // original code verbatim
            foreach (collection in ::DynamicPerks.PerkGroupCategories.getOrdered())
            {
                if (collection.getID() in this.m.DynamicMap)
                {
                    foreach (perkGroupContainer in this.m.DynamicMap[collection.getID()])
                    {
                        local id;

                        switch (typeof perkGroupContainer)
                        {
                            case "string":
                                id = perkGroupContainer;
                                break;

                            case "instance":
                                this.__applyMultipliers(perkGroupContainer);
                                id = perkGroupContainer.roll();
                                break;

                            default:
                                ::logError("perkGroupContainer must either be a valid perk group id or an instance of the MSU WeightedContainer class");
                                throw ::MSU.Exception.InvalidType("perkGroupContainer");
                        }

                        if (id == "DynamicPerks_RandomPerkGroup")
                            id = this.__getWeightedRandomGroupFromCollection(collection.getID(), this.m.Exclude);

                        if (id == "DynamicPerks_NoPerkGroup")
                            continue;

                        local perkGroup = ::DynamicPerks.PerkGroups.findById(id);
                        if (perkGroup == null)
                        {
                            ::logError("No perk group with id \'" + id + "\'");
                            continue;
                        }

                        this.m.Exclude.push(id);
                        this.addPerkGroup(id);
                    }
                }

                local min = this.getActor().getBackground().getCollectionMin(collection.getID());
                if (min == null) min = collection.getMin();

                // start custom code
                local rangeLow = min - 2;
                local rangeHigh = min - 1;
                if (min >= 5)
                {
                    rangeLow = 2;
                    rangeHigh = 3;
                }
                else if (min >= 4)
                {
                    rangeLow = 2;
                    rangeHigh = 3;
                }
                else if (min >= 3)
                {
                    rangeLow = 1;
                    rangeHigh = 2;
                }
                else if (min >= 2)
                {
                    rangeLow = 1;
                    rangeHigh = 2;
                }
                else
                {
                    rangeLow = 0;
                    rangeHigh = 0;
                }
                local actual = ::Math.rand(rangeLow, rangeHigh);

                // for min=1 or min=2 trees, give a bit extra chance to get some tree
                if (rangeHigh > 0 && actual == 0)
                {
                	if (::Math.rand(0, 100) < 50)
                		actual = 1;
                }

                // just in case its supposed to not have this tree at all
                if (min <= 0)
                    actual = 0;

                min = actual;
                // end custom code

                for (local i = (collection.getID() in this.m.DynamicMap) ? this.m.DynamicMap[collection.getID()].len() : 0; i < min; i++)
                {
                    local perkGroupID = this.__getWeightedRandomGroupFromCollection(collection.getID(), this.m.Exclude);
                    if (perkGroupID != "DynamicPerks_NoPerkGroup")
                    {
                        this.m.Exclude.push(perkGroupID);
                        this.addPerkGroup(perkGroupID);
                    }
                }
            }
            // end original code
        });
    });
});
