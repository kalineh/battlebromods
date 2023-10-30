::ModSharedXPTweak <- {
    ID = "mod_shared_xp_tweak",
    Name = "Shared XP Tweak",
    Version = "0.0.1",
}

::mods_registerMod(::ModSharedXPTweak.ID, ::ModSharedXPTweak.Version, ::ModSharedXPTweak.Name);
::mods_queue(::ModSharedXPTweak.ID, "mod_msu, >mod_reforged", function()
{
    ::ModSharedXPTweak.Mod <- ::MSU.Class.Mod(::ModSharedXPTweak.ID, ::ModSharedXPTweak.Version, ::ModSharedXPTweak.Name);

    this.logDebug("ModSharedXPTweak: registered mod, overriding XP share...");

    // from player.nut
    // function onActorKilled( _actor, _tile, _skill )

    ::mods_hookExactClass("entity/tactical/player", function(o) {
        local base_onActorKilled = ::mods_getMember(o, "onActorKilled");
        ::mods_override(o, "onActorKilled", function(_actor, _tile, _skill) {
            this.Const.XP.XPForKillerPct <- 0.0;
            base_onActorKilled(_actor, _tile, _skill);
        });
    });
});
