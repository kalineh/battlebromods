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
        local findUnoccupiedTile = function( _startTile ) {
            if (_startTile == null)
                return null;

            local directions = [
                this.Const.Direction.N,
                this.Const.Direction.S,
                this.Const.Direction.NW,
                this.Const.Direction.SW,
                this.Const.Direction.NE,
                this.Const.Direction.SE
            ];
        
            local tileCursor = _startTile;
            local tilesUnchecked = [];
            local tilesChecked = [];

            local maxIterations = 1024;

            for (local i = 0; i < maxIterations; ++i)
            {
                if (tileCursor == null)
                {
                    if (tilesUnchecked.Length <= 0)
                        break;

                    tileCursor = tilesUnchecked.pop();
                }

                foreach (direction in directions)
                {
                    local next = tileCursor.getNextTile(direction);
                    if (next == null)
                        continue;

                    local existsUnchecked = false;
                    local existsChecked = false;

                    foreach (var t in tilesUnchecked)
                    {
                        if (t == next)
                        {
                            existsUnchecked = true;
                            break;
                        }
                    }

                    foreach (var t in tilesChecked)
                    {
                        if (t == next)
                        {
                            existsChecked = true;
                            break;
                        }
                    }

                    if (existsChecked == false && existsUnchecked == false)
                        tilesUnchecked.push(next);
                }

                tilesChecked.push(tileCursor);
                tileCursor = null;
            }

            foreach (var candidate in tilesChecked)
            {
                if (candidate.IsEmpty == false)
                    continue;
                if (candidate.IsCorpseSpawned)
                    continue;
                if (candidate.IsBadTerrain)
                    continue;

                // maybe should do this, or +1/-1 check
                //if (candidate.Level > _startTile.Level)
                //  continue;

                return candidate;
            }

            return null;
        };

        local baseFunction = ::mods_getMember(o, "findTileToSpawnCorpse");
        ::mods_override(o, "findTileToSpawnCorpse", function( _killer ) {
            local tile = baseFunction(_killer);
            local test = findUnoccupiedTile(this.getTile());
            if (tile == null)
            {
                local fallback = findUnoccupiedTile(this.getTile());
                if (fallback != null)
                    return fallback;
            }
            return tile;
        });
    });
});
