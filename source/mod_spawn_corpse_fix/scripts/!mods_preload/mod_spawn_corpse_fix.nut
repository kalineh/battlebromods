::ModSpawnCorpseFix <- {
    ID = "mod_spawn_corpse_fix",
    Name = "Spawn Corpse Fix",
    Version = "0.0.1",
}

::mods_registerMod(::ModSpawnCorpseFix.ID, ::ModSpawnCorpseFix.Version, ::ModSpawnCorpseFix.Name);
::mods_queue(::ModSpawnCorpseFix.ID, "mod_msu, >mod_reforged", function()
{
    ::ModSpawnCorpseFix.Mod <- ::MSU.Class.Mod(::ModSpawnCorpseFix.ID, ::ModSpawnCorpseFix.Version, ::ModSpawnCorpseFix.Name);

    this.logDebug("ModSpawnCorpseFix: registered mod...");

    ::mods_hookExactClass("entity/tactical/actor", function(o) {
        local findUnoccupiedTile = function( _tile )
        {
            if (_tile == null)
                return null;
            if (_tile.isPlacedOnMap() == false)
                return null;

            local directions = [
                this.Const.Direction.N,
                this.Const.Direction.S,
                this.Const.Direction.NW,
                this.Const.Direction.SW,
                this.Const.Direction.NE,
                this.Const.Direction.SE
            ];
            local currentTile = _tile;
            local maxLayers = 4;

            for (local layer = 1; layer < maxLayers; ++layer)
            {
                for (local side = 0; side < this.Const.Direction.COUNT; ++side)
                {
                    local stepsToTake = side == 0 ? layer - 1 : layer;

                    for (local steps = 0; steps < stepsToTake; ++steps)
                    {
                        currentTile = currentTile.getNextTile(side);

                        if (currentTile == null)
                            continue;
                        if (currentTile.isPlacedOnMap() == false)
                            return null;
                        if (currenTile.IsBadTerrain)
                            continue;
                        if (currentTile.IsCorpseSpawned)
                            continue;

                        // maybe should do this, or +1/-1 check
                        //if (currentTile.Level != this.GetTile().Level)
                        //  continue;

                        // probably should do this too, not sure how
                        //if (currentTile.traversable == false)
                        //  continue;

                        return currentTile;
                    }
                }
            }

            return null;
        }

        local baseFunction = ::mods_getMember(o, "findTileToSpawnCorpse");
        ::mods_override(o, "findTileToSpawnCorpse", function( _killer ) {
            local tile = baseFunction(_killer);
            if (tile == null)
            {
                local selfTile = this.getTile();
                local fallback = findUnoccupiedTile(selfTile);
                if (fallback != null)
                    return fallback;
            }
            return tile;
        });
    });
});
