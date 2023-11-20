::ModSilenceEventRetinue <- {
    ID = "mod_silence_event_retinue",
    Name = "Silence Retinue Event",
    Version = "0.0.1",
}

::mods_registerMod(::ModSilenceEventRetinue.ID, ::ModSilenceEventRetinue.Version, ::ModSilenceEventRetinue.Name);
::mods_queue(::ModSilenceEventRetinue.ID, "mod_msu, >mod_reforged", function()
{
    ::ModSilenceEventRetinue.Mod <- ::MSU.Class.Mod(::ModSilenceEventRetinue.ID, ::ModSilenceEventRetinue.Version, ::ModSilenceEventRetinue.Name);

    this.logDebug("ModSilenceEventRetinue: registered mod, replacing retinue code...");

    ::mods_hookExactClass("events/events/special/retinue_slot_event", function(o)
    {
        local onUpdateScore = o.onUpdateScore;
        o.onUpdateScore = function()
        {
            // could check money here too
            this.m.Score = 0;
        }
    })
})
