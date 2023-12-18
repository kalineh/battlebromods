::ModRandomSolo <- {
    ID = "mod_random_solo",
    Name = "RandomSolo",
    Version = "0.0.9",
}

::mods_registerMod(::ModRandomSolo.ID, ::ModRandomSolo.Version, ::ModRandomSolo.Name);
::mods_queue(::ModRandomSolo.ID, "mod_msu, >mod_reforged", function()
{
    ::ModRandomSolo.Mod <- ::MSU.Class.Mod(::ModRandomSolo.ID, ::ModRandomSolo.Version, ::ModRandomSolo.Name);
});
