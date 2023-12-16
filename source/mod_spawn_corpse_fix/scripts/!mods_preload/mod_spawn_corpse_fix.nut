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

            local tileCursor = _startTile;
            local tilesUnchecked = [];
            local tilesChecked = [];

            local maxIterations = 128;

            for (local i = 0; i < maxIterations; i = ++i)
            {
                if (tileCursor == null)
                {
                    if (tilesUnchecked.len() <= 0)
                        break;

                    // pop first element so we breadth-first search
                    tileCursor = tilesUnchecked[0];
                    tilesUnchecked.remove(0);
                }

                for (local direction = 0; direction < this.Const.Direction.COUNT; direction = ++direction)
                {
                    if (tileCursor.hasNextTile(direction) == false)
                        continue;

                    local next = tileCursor.getNextTile(direction);
                    if (next == null)
                        continue;
                    if (next.IsBadTerrain)
                        continue;

                    local existsUnchecked = false;
                    local existsChecked = false;

                    foreach (t in tilesUnchecked)
                    {
                        if (t == next)
                        {
                            existsUnchecked = true;
                            break;
                        }
                    }

                    foreach (t in tilesChecked)
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

                local alreadyInserted = false;

                foreach (t in tilesChecked)
                {
                    if (t == tileCursor)
                    {
                        alreadyInserted = true;
                        break;
                    }
                }

                if (alreadyInserted == false)
                    tilesChecked.push(tileCursor);
                
                tileCursor = null;
            }

            local tileDistanceCustom = function(a, b) {
                local dx = b.Pos.X - a.Pos.X;
                local dy = b.Pos.Y - a.Pos.Y;
                return (dx * dx + dy * dy);
            };

            // wrong for some reason
            /*
            tilesChecked.sort(function(a, b) {
                // getDistanceTo() seems to have some degenerate result sometimes
                //local da = _startTile.getDistanceTo(a);
                //local db = _startTile.getDistanceTo(b);
                local da = tileDistanceCustom(_startTile, a);
                local db = tileDistanceCustom(_startTile, b);

                if (db < da)
                    return -1;
                if (da > db)
                    return 1;
                return 0;
            });
            */

            local bubbleSortTiles = function(tiles, startTile) {
                local n = tiles.len();
                for (local i = 0; i < n - 1; i++) {
                    for (local j = 0; j < n - i - 1; j++) {
                        if (tileDistanceCustom(startTile, tiles[j]) > tileDistanceCustom(startTile, tiles[j + 1])) {
                            // Swap tiles[j] and tiles[j + 1]
                            local temp = tiles[j];
                            tiles[j] = tiles[j + 1];
                            tiles[j + 1] = temp;
                        }
                    }
                }
            };

            // Using the function
            bubbleSortTiles(tilesChecked, _startTile);

            for (local i = 0; i < tilesChecked.len(); i++) {
                local candidate = tilesChecked[i];
                this.logDebug("TILE: sort check " + candidate + ", distance " + _startTile.getDistanceTo(candidate) + ", " + candidate.Pos.X + ", " + candidate.Pos.Y);
            }

            foreach (candidate in tilesChecked)
            {
                this.logDebug("TILE: checking " + candidate + ", distance " + _startTile.getDistanceTo(candidate) + ", " + candidate.Pos.X + ", " + candidate.Pos.Y);
                //this.logDebug("TILE: check " + candidate + ", distance " + _startTile.getDistanceTo(candidate));
                if (candidate.IsEmpty == false)
                    continue;
                // note: is this even set anywhere?
                if (candidate.IsCorpseSpawned)
                    continue;
                if (candidate.Properties.has("Corpse"))
                    continue;
                if (candidate.IsBadTerrain)
                    continue;

                // maybe should do this, or +1/-1 check
                //if (candidate.Level > _startTile.Level)
                //  continue;

                this.logDebug("TILE: VALID FOUND");
                return candidate;
            }

            return null;
        };

        local baseFunction = ::mods_getMember(o, "findTileToSpawnCorpse");
        ::mods_override(o, "findTileToSpawnCorpse", function( _killer ) {
            local tile = baseFunction(_killer);
            local test = findUnoccupiedTile(this.getTile());
            this.logDebug("ModSpawnCorpseFix: test: " + test);
            if (tile == null)
            {
                local fallback = findUnoccupiedTile(this.getTile());
                if (fallback != null)
                {
                    this.logDebug("TILE: USING FALLBACK");
                    return fallback;
                }
            }
            return tile;
        });
    });
});
