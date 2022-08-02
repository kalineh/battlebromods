local gt = this.getroottable();

if (!("ScalingMasterMod" in gt.Const)) {
    gt.Const.ScalingMasterMod <- {};
}

gt.Const.ScalingMasterMod.OnTargetKillRolls <- function(actor, targetEntity) {
    local actorProps = actor.getBaseProperties();
    local targetProps = targetEntity.getBaseProperties();
    local background = actor.getBackground().getID();
    local background_beggar = false;

    if (background == "background.legend_commander_beggar_op")
        return;

    local learned_something = false;
    local learned_string = "";

    local scaling_roll_all = MSU.Math.randf(0.0, 100.0).tointeger();
    local scaling_roll_hitpoints = MSU.Math.randf(0.0, 100.0).tointeger();
    local scaling_roll_resolve = MSU.Math.randf(0.0, 100.0).tointeger();
    local scaling_roll_fatigue = MSU.Math.randf(0.0, 100.0).tointeger();
    local scaling_roll_melee_attack = MSU.Math.randf(0.0, 100.0).tointeger();
    local scaling_roll_ranged_attack = MSU.Math.randf(0.0, 100.0).tointeger();
    local scaling_roll_melee_defense = MSU.Math.randf(0.0, 100.0).tointeger();
    local scaling_roll_ranged_defense = MSU.Math.randf(0.0, 100.0).tointeger();
    local scaling_roll_initiative = MSU.Math.randf(0.0, 100.0).tointeger();

    if (::ScalingAvatar.StatRollSeperate == false)
    {
        scaling_roll_hitpoints = scaling_roll_all;
        scaling_roll_resolve = scaling_roll_all;
        scaling_roll_fatigue = scaling_roll_all;
        scaling_roll_melee_attack = scaling_roll_all;
        scaling_roll_ranged_attack = scaling_roll_all;
        scaling_roll_melee_defense = scaling_roll_all;
        scaling_roll_ranged_defense = scaling_roll_all;
        scaling_roll_initiative = scaling_roll_all;
    }

    local success_roll_hitpoints = scaling_roll_hitpoints < ::ScalingAvatar.StatRollPercent;
    local success_roll_resolve = scaling_roll_resolve < ::ScalingAvatar.StatRollPercent;
    local success_roll_fatigue = scaling_roll_fatigue < ::ScalingAvatar.StatRollPercent;
    local success_roll_melee_attack = scaling_roll_melee_attack < ::ScalingAvatar.StatRollPercent;
    local success_roll_ranged_attack = scaling_roll_ranged_attack < ::ScalingAvatar.StatRollPercent;
    local success_roll_melee_defense = scaling_roll_melee_defense < ::ScalingAvatar.StatRollPercent;
    local success_roll_ranged_defense = scaling_roll_ranged_defense < ::ScalingAvatar.StatRollPercent;
    local success_roll_initiative = scaling_roll_initiative < ::ScalingAvatar.StatRollPercent;

    ::ScalingAvatar.VerboseLogDebug("rolling for stat increase...");
    ::ScalingAvatar.VerboseLogRoll("hitpoints", scaling_roll_hitpoints, ::ScalingAvatar.StatRollPercent);
    ::ScalingAvatar.VerboseLogRoll("fatigue", scaling_roll_fatigue, ::ScalingAvatar.StatRollPercent);
    ::ScalingAvatar.VerboseLogRoll("resolve", scaling_roll_resolve, ::ScalingAvatar.StatRollPercent);
    ::ScalingAvatar.VerboseLogRoll("melee_attack", scaling_roll_melee_attack, ::ScalingAvatar.StatRollPercent);
    ::ScalingAvatar.VerboseLogRoll("ranged_attack", scaling_roll_ranged_attack, ::ScalingAvatar.StatRollPercent);
    ::ScalingAvatar.VerboseLogRoll("melee_defense", scaling_roll_melee_defense, ::ScalingAvatar.StatRollPercent);
    ::ScalingAvatar.VerboseLogRoll("ranged_defense", scaling_roll_ranged_defense, ::ScalingAvatar.StatRollPercent);
    ::ScalingAvatar.VerboseLogRoll("initiative", scaling_roll_initiative, ::ScalingAvatar.StatRollPercent);

    local plus_one_string = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + 1 + "[/color] ";

    if (actorProps.Hitpoints < targetProps.Hitpoints && success_roll_hitpoints) {
        actorProps.Hitpoints += 1;
        actor.getLifetimeStats().Tags.increment("HitpointsGained", 1);
        learned_something = true;
        learned_string += plus_one_string + "Hitpoints, ";
    }
    if (actorProps.Bravery < targetProps.Bravery && success_roll_resolve) {
        actorProps.Bravery += 1;
        actor.getLifetimeStats().Tags.increment("BraveryGained", 1);
        learned_something = true;
        learned_string += plus_one_string + "Resolve, ";
    }
    if (actorProps.Stamina < targetProps.Stamina && success_roll_fatigue) {
        actorProps.Stamina += 1;
        actor.getLifetimeStats().Tags.increment("StaminaGained", 1);
        learned_something = true;
        learned_string += plus_one_string + "Fatigue, ";
    }
    if (actorProps.MeleeSkill < targetProps.MeleeSkill && success_roll_melee_attack) {
        actorProps.MeleeSkill += 1;
        actor.getLifetimeStats().Tags.increment("MeleeSkillGained", 1);
        learned_something = true;
        learned_string += plus_one_string + "Melee Skill, ";
    }
    if (actorProps.RangedSkill < targetProps.RangedSkill && success_roll_ranged_attack) {
        actorProps.RangedSkill += 1;
        actor.getLifetimeStats().Tags.increment("RangedSkillGained", 1);
        learned_something = true;
        learned_string += plus_one_string + "Ranged Skill, ";
    }
    if (actorProps.MeleeDefense < targetProps.MeleeDefense && success_roll_melee_defense) {
        actorProps.MeleeDefense += 1;
        actor.getLifetimeStats().Tags.increment("MeleeDefenseGained", 1);
        learned_something = true;
        learned_string += plus_one_string + "Melee Defense, ";
    }
    if (actorProps.RangedDefense < targetProps.RangedDefense && success_roll_ranged_defense) {
        actorProps.RangedDefense += 1;
        actor.getLifetimeStats().Tags.increment("RangedDefenseGained", 1);
        learned_something = true;
        learned_string += plus_one_string + "Ranged Defense, ";
    }
    if (actorProps.Initiative < targetProps.Initiative && success_roll_initiative) {
        actorProps.Initiative += 1;
        actor.getLifetimeStats().Tags.increment("InitiativeGained", 1);
        learned_something = true;
        learned_string += plus_one_string + "Initiative, ";
    }

    // remove ", "  from end of string using slice function
    if (learned_string != "") {
        local length = learned_string.len();
        learned_string = learned_string.slice(0, length - 2);
    }

    learned_string += ".";

    if (learned_something) {
        this.Tactical.EventLog.log(actor.getName() + " has acquired new attributes: " + learned_string);
    }
};

gt.Const.ScalingMasterMod.GetEnemyKills <- function(_actor) {
    if (_actor == null) {
        this.HitpointsGained = 0;
        this.BraveryGained = 0;
        this.StaminaGained = 0;
        this.MeleeSkillGained = 0;
        this.RangedSkillGained = 0;
        this.MeleeDefenseGained = 0;
        this.RangedDefenseGained = 0;
        this.InitiativeGained = 0;
    }

    local hitpointsGained = 0;
    hitpointsGained = _actor.getLifetimeStats().Tags.get("HitpointsGained");
    if (hitpointsGained && hitpointsGained > 0) {
        hitpointsGained = hitpointsGained;
    } else {
        hitpointsGained = 0;
    }

    local braveryGained = 0;
    braveryGained = _actor.getLifetimeStats().Tags.get("BraveryGained");
    if (braveryGained && braveryGained > 0) {
        braveryGained = braveryGained;
    } else {
        braveryGained = 0;
    }

    local staminaGained = 0;
    staminaGained = _actor.getLifetimeStats().Tags.get("StaminaGained");
    if (staminaGained && staminaGained > 0) {
        staminaGained = staminaGained;
    } else {
        staminaGained = 0;
    }

    local meleeSkillGained = 0;
    meleeSkillGained = _actor.getLifetimeStats().Tags.get("MeleeSkillGained");
    if (meleeSkillGained && meleeSkillGained > 0) {
        meleeSkillGained = meleeSkillGained;
    } else {
        meleeSkillGained = 0;
    }

    local rangedSkillGained = 0;
    rangedSkillGained = _actor.getLifetimeStats().Tags.get("RangedSkillGained");
    if (rangedSkillGained && rangedSkillGained > 0) {
        rangedSkillGained = rangedSkillGained;
    } else {
        rangedSkillGained = 0;
    }

    local meleeDefenseGained = 0;
    meleeDefenseGained = _actor.getLifetimeStats().Tags.get("MeleeDefenseGained");
    if (meleeDefenseGained && meleeDefenseGained > 0) {
        meleeDefenseGained = meleeDefenseGained;
    } else {
        meleeDefenseGained = 0;
    }

    local rangedDefenseGained = 0;
    rangedDefenseGained = _actor.getLifetimeStats().Tags.get("RangedDefenseGained");
    if (rangedDefenseGained && rangedDefenseGained > 0) {
        rangedDefenseGained = rangedDefenseGained;
    } else {
        rangedDefenseGained = 0;
    }

    local initiativeGained = 0;
    initiativeGained = _actor.getLifetimeStats().Tags.get("InitiativeGained");
    if (initiativeGained && initiativeGained > 0) {
        initiativeGained = initiativeGained;
    } else {
        initiativeGained = 0;
    }

    return {
        HitpointsGained = hitpointsGained + ::ScalingAvatar.StatBonusFlat,
        BraveryGained = braveryGained + ::ScalingAvatar.StatBonusFlat,
        StaminaGained = staminaGained + ::ScalingAvatar.StatBonusFlat,
        MeleeSkillGained = meleeSkillGained + ::ScalingAvatar.StatBonusFlat,
        RangedSkillGained = rangedSkillGained + ::ScalingAvatar.StatBonusFlat,
        MeleeDefenseGained = meleeDefenseGained + ::ScalingAvatar.StatBonusFlat,
        RangedDefenseGained = rangedDefenseGained + ::ScalingAvatar.StatBonusFlat,
        InitiativeGained = initiativeGained + ::ScalingAvatar.StatBonusFlat
    };
};