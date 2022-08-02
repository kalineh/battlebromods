::ScalingAvatar <- {
    ID = "mod_scaling_avatar",
    Name = "ScalingAvatar",
    Version = "0.0.2",
    StatBonusInitial = 0,
    StatRollSeperate = true,
    StatRollPercent = 100,
    PerkRollPercent = 100,
    VerboseLogging = true,

    VerboseLogDebug = function(str) {
        if (::ScalingAvatar.VerboseLogging == false)
            return;

        ::ScalingAvatar.Mod.Debug.printLog("ScalingAvatar: " + str, "debug");
    },

    VerboseLogRoll = function(str, roll, chance) {
        if (::ScalingAvatar.VerboseLogging == false)
            return;

        local result_str = "failure";
        if (roll < chance)
            result_str = "success";

        local text = "ScalingAvatar: " + str + " (rolled " + roll + " with chance " + chance + "% (" + result_str + ")";

        ::ScalingAvatar.Mod.Debug.printLog(text, "debug");
        this.Tactical.EventLog.log(text);
    },
}
::mods_registerMod(::ScalingAvatar.ID, ::ScalingAvatar.Version, ::ScalingAvatar.Name)

    ::mods_queue(::ScalingAvatar.ID, "mod_legends", function() {

        ::ScalingAvatar.Mod <- ::MSU.Class.Mod(::ScalingAvatar.ID, ::ScalingAvatar.Version, ::ScalingAvatar.Name);
        ::ScalingAvatar.Mod.Debug.setFlag("debug", true)

        local scaling_roll_all = MSU.Math.randf(0.0, 100.0);
        local scaling_roll_all_int = scaling_roll_all.tointeger();

        ::ScalingAvatar.VerboseLogDebug("RANDOM: " + scaling_roll_all_int);

        // MSU options setup

        local page = ::ScalingAvatar.Mod.ModSettings.addPage("General");

        local settingStat = page.addRangeSetting("StatRollPercent", 1, 1, 100, 1.0, "Stat Roll Percent", "Chance of gaining stats from killed enemy.");
        local settingPerk = page.addRangeSetting("PerkRollPercent", 1, 1, 100, 1.0, "Perk Roll Percent", "Chance of gaining perks from killed enemy.");
        local settingSeperate = page.addBooleanSetting("StatRollIndividual", false, "Seperate Stat Rolls", "Roll for stat gain per individual stat.");
        local settingVerbose = page.addBooleanSetting("VerboseLogging", false, "Verbose Logging", "Verbose logging for debugging.");
        local settingInitial = page.addRangeSetting("StatInitial", 1, 1, 100, 1.0, "Stat Initial Bonus", "Starting bonus stats value (must be set before campaign is started).");

        settingStat.addCallback(function(_value) { ::ScalingAvatar.StatRollPercent = _value; });
        settingPerk.addCallback(function(_value) { ::ScalingAvatar.PerkRollPercent = _value; });
        settingSeperate.addCallback(function(_value) { ::ScalingAvatar.StatRollSeperate = _value; });
        settingVerbose.addCallback(function(_value) { ::ScalingAvatar.VerboseLogging = _value; });
        settingInitial.addCallback(function(_value) { ::ScalingAvatar.StatBonusInitial = _value.tointeger(); });

        // actual scaling code

        ::mods_hookClass("skills/traits/player_character_trait", function(o) {
            while (!("getTooltip" in o)) o = o[o.SuperName];
            local getTooltip = o.getTooltip;
            o.getTooltip = function() {
                local ret = getTooltip();
                if (this.getContainer() != null) {
                    ret.extend(this.getAttributesTooltip());
                }
                return ret;
            }

            function getAttributesTooltip() {
                local stats = this.getTotalStats();
                local ret = [{
                        id = 10,
                        type = "text",
                        icon = "ui/icons/health.png",
                        text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + stats.HitpointsGained + "[/color] Hitpoints gained due to scaling effect."
                    },
                    {
                        id = 10,
                        type = "text",
                        icon = "ui/icons/bravery.png",
                        text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + stats.BraveryGained + "[/color] Resolve due gained to scaling effect."
                    },
                    {
                        id = 10,
                        type = "text",
                        icon = "ui/icons/fatigue.png",
                        text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + stats.StaminaGained + "[/color] Fatigue gained due to scaling effect."
                    },
                    {
                        id = 10,
                        type = "text",
                        icon = "ui/icons/initiative.png",
                        text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + stats.InitiativeGained + "[/color] Initiative gained due to scaling effect."
                    },
                    {
                        id = 10,
                        type = "text",
                        icon = "ui/icons/melee_skill.png",
                        text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + stats.MeleeSkillGained + "[/color] Melee Skill gained due to scaling effect."
                    },
                    {
                        id = 10,
                        type = "text",
                        icon = "ui/icons/ranged_skill.png",
                        text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + stats.RangedSkillGained + "[/color] Ranged Skill gained due to scaling effect."
                    },
                    {
                        id = 10,
                        type = "text",
                        icon = "ui/icons/melee_defense.png",
                        text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + stats.MeleeDefenseGained + "[/color] Melee Defense gained due to scaling effect."
                    },
                    {
                        id = 10,
                        type = "text",
                        icon = "ui/icons/ranged_defense.png",
                        text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + stats.RangedDefenseGained + "[/color] Ranged Defense gained due to scaling effect."
                    }
                ];
                return ret;
            }

            function getTotalStats() {
                return this.Const.ScalingMasterMod.GetEnemyKills(this.getContainer().getActor());
            }

        });

        ::mods_hookClass("skills/traits/player_character_trait", function(o) {

            function setTotalStats(_actor, _targetEntity) {
                this.Const.ScalingMasterMod.SetEnemyKills(_actor, _targetEntity);
            }

            function colorizeString(_string, _color) {
                local string = "[color=" + _color + "]" + _string + "[/color]";
                return string;
            }

            function updatePerks(actor, _targetEntity) {
                local scaling_roll_perk = MSU.Math.randf(0.0, 100.0).tointeger();
                local success_roll_perk = scaling_roll_perk < ::ScalingAvatar.PerkRollPercent;

                ::ScalingAvatar.VerboseLogDebug("rolling for perk increase...");
                ::ScalingAvatar.VerboseLogRoll("perk", scaling_roll_perk, ::ScalingAvatar.PerkRollPercent);

                if (success_roll_perk == false)
                    return;

                local target_skills = _targetEntity.getSkills().getSkillsByFunction(@(skill) skill.isType(::Const.SkillType.Perk));

                local potentialPerks = [];

                foreach(perk in target_skills) {
                    local id = perk.getID();
                    if (id == "perk.stalwart" || id == "perk.legend_composure" || id == "perk.battering_ram") {
                        continue;
                    } else if (!actor.getSkills().hasSkill(id)) {
                        potentialPerks.push(perk);
                    }
                }

                if (potentialPerks.len() == 0) {
                    return;
                }

                local random_Number = ::Math.rand(0, potentialPerks.len() - 1);

                local perk = potentialPerks[random_Number];

                foreach(i, v in this.Const.Perks.PerkDefObjects) {
                    if (perk.getID() == v.ID) {
                        if (v.Script != "") {
                            this.Tactical.EventLog.log(colorizeString(actor.getName(), "#3b3fe7") + " learned " + colorizeString(perk.getName(), "#3b3fe7") + " from his enemy!");
                            actor.m.PerkPointsSpent++;
                            actor.getSkills().add(this.new(v.Script));
                            local rowToAddPerk = 0;
                            local length = actor.getBackground().getPerkTree()[0].len();
                            foreach(i, row in actor.getBackground().getPerkTree()) {
                                if (row.len() < length) rowToAddPerk = i;
                            }
                            actor.getBackground().addPerk(i, rowToAddPerk);
                            break;
                        }
                    }
                }
            }

            function calculateScaling(_actor, _targetEntity) {
                updatePerks(_actor, _targetEntity);
                setTotalStats(_actor, _targetEntity);
            }

            while (!("onTargetKilled" in o)) o = o[o.SuperName];
            local onTargetKilled = o.onTargetKilled;
            o.onTargetKilled = function(_targetEntity, _skill) {
                local actor = this.getContainer().getActor();
                calculateScaling(actor, _targetEntity);
                onTargetKilled(_targetEntity, _skill);
            }

        });

    });