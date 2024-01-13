::ModNoHireEquipment <- {
    ID = "mod_no_hire_equipment",
    Name = "No Hire Equipment",
    Version = "0.0.1",
}

::mods_registerMod(::ModNoHireEquipment.ID, ::ModNoHireEquipment.Version, ::ModNoHireEquipment.Name);
::mods_queue(::ModNoHireEquipment.ID, "mod_msu, >mod_reforged, >mod_dynamic_perk_trees", function()
{
    ::ModNoHireEquipment.Mod <- ::MSU.Class.Mod(::ModNoHireEquipment.ID, ::ModNoHireEquipment.Version, ::ModNoHireEquipment.Name);

    this.logDebug("ModNoHireEquipment: registered mod...");

    ::mods_hookExactClass("skills/backgrounds/character_background", function(o) {
        //function addEquipment()
        //{
        //    this.onAddEquipment();
        //    this.adjustHiringCostBasedOnEquipment();
        //}

        local baseFunction = ::mods_getMember(o, "addEquipment");

        ::mods_override(o, "addEquipment", function() {
            // naked mode
            //this.onAddEquipment();
            this.adjustHiringCostBasedOnEquipment();
        });
    });
});
