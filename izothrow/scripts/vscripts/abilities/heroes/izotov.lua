LinkLuaModifier( "modifier__agressive", "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gressive_debuff", "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_NONE )

agressive = class({})

function agressive:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function agressive:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function agressive:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("talent_agressive_1")
end


function agressive:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    StopSoundOn( "Hero_Axe.BerserkersCall.Start", self:GetCaster() )
end
function agressive:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Hero_Axe.BerserkersCall.Start")
    return true
end

function agressive:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetOrigin()
    local radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("talent_agressive_1")
    local duration = self:GetSpecialValueFor("duration")
    local enemies = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )

    caster:AddNewModifier( caster, self, "modifier_agressive", { duration = duration } )

    for _,enemy in pairs(enemies) do
        if not enemy:IsDuel() then
            enemy:AddNewModifier( caster, self, "modifier_agressive_debuff", { duration = duration } )
        end
    end

    self:GetCaster():EmitSound("Hero_Axe.Berserkers_Call")
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( particle )

    if self:GetCaster():HasShard() then
        local illusions = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, 0, false )
        for _, illusion in pairs(illusions) do
            if illusion:IsIllusion() then
                self:IllusionCast(illusion)
            end
        end
    end
end

function agressive:IllusionCast(illusion)
    local duration = self:GetSpecialValueFor("duration")
    local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), illusion:GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    illusion:AddNewModifier( illusion, self, "modifier_agressive", { duration = duration } )
    for _,enemy in pairs(enemies) do
        if not enemy:IsDuel() then
            enemy:AddNewModifier( illusion, self, "modifier_agressive_debuff", { duration = duration } )
        end
    end  
    illusion:EmitSound("Hero_Axe.Berserkers_Call")
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, illusion )
    ParticleManager:SetParticleControlEnt( particle, 1, illusion, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true )
    ParticleManager:ReleaseParticleIndex( particle )
end

modifier_agressive = class({})

function modifier_agressive:IsHidden()
    return false
end

function modifier_agressive:IsPurgable()
    return true
end

function modifier_agressive:GetEffectName()
    return "particles/units/heroes/hero_axe/axe_beserkers_call.vpcf"
end

function modifier_agressive:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_agressive:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_agressive:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor( "bonus_armor" )
end

modifier_agressive_debuff = class({})

function modifier_agressive_debuff:IsHidden()
    return false
end

function modifier_agressive_debuff:IsPurgable()
    return false
end

function modifier_agressive_debuff:OnCreated( kv )
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( self:GetCaster() )
    self:GetParent():MoveToTargetToAttack( self:GetCaster() )
    self:StartIntervalThink(FrameTime())
end

function modifier_agressive_debuff:OnIntervalThink( kv )
    if not IsServer() then return end
    if self:GetCaster():HasModifier("modifier_fountain_passive_invul") or (not self:GetCaster():IsAlive()) then
        if not self:IsNull() then
            self:Destroy()
        end
    end
end

function modifier_agressive_debuff:OnRemoved()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget( nil )
end

function modifier_agressive_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_TAUNTED] = true,
    }

    return state
end

function modifier_agressive_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end



LinkLuaModifier( "modifier_izothrow_stunned", "modifiers/modifier_birzha_dota_modifiers.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zombie_spawn_zombie", "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_BOTH )

zombie_spawn = class({}) 

function zombie_spawn:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function zombie_spawn:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

zombie_spawn.spawn_anarhist_talent = false

function zombie_spawn:OnSpellStart()
    if not IsServer() then return end
    self.count = self:GetSpecialValueFor( "zombies_count" )
    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)) do
        if unit:GetUnitName() == "npc_izotov_urod" and unit:GetOwner() == self:GetCaster() then
            unit:ForceKill(false)               
        end
    end
    local zombie_name = "npc_izotov_urod"

    for i = 1, self.count do
        local zombie = CreateUnitByName(zombie_name, self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 300) + (self:GetCaster():GetRightVector() * 20 * i), true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
        zombie:SetOwner(self:GetCaster())
        zombie:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
        FindClearSpaceForUnit(zombie, zombie:GetAbsOrigin(), true)
        local zombie_blood_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, zombie)
        ParticleManager:SetParticleControl(zombie_blood_particle, 0, zombie:GetAbsOrigin())
        ParticleManager:SetParticleControl(zombie_blood_particle, 1, zombie:GetAbsOrigin())
        ParticleManager:SetParticleControl(zombie_blood_particle, 2, zombie:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(zombie_blood_particle)
        zombie:SetForwardVector(self:GetCaster():GetForwardVector())
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_zombie_spawn_zombie", {})
        if not self:GetCaster():HasTalent("talent_zombie_spawn_1") then
            zombie:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
        end
    end

    if self:GetCaster():HasTalent("talent_zombie_spawn_2") then
        if self.spawn_anarhist_talent then
            self:SpawnAnarchist(self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 300))
        end
    end
    if self.spawn_anarhist_talent then
        self.spawn_anarhist_talent = false
    else 
        self.spawn_anarhist_talent = true
    end
end

function zombie_spawn:SpawnAnarchist(abs)
    if not self:SpawnAnarhOkay() then return end
    local zombie = CreateUnitByName("npc_izotov_mega_urod", abs, true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
    zombie:SetOwner(self:GetCaster())
    zombie:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
    FindClearSpaceForUnit(zombie, zombie:GetAbsOrigin(), true)
    local zombie_blood_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW, zombie)
    ParticleManager:SetParticleControl(zombie_blood_particle, 0, zombie:GetAbsOrigin())
    ParticleManager:SetParticleControl(zombie_blood_particle, 1, zombie:GetAbsOrigin())
    ParticleManager:SetParticleControl(zombie_blood_particle, 2, zombie:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(zombie_blood_particle)
    zombie:SetForwardVector(self:GetCaster():GetForwardVector())
    zombie:AddNewModifier(self:GetCaster(), self, "modifier_zombie_spawn_zombie", {})
    if not self:GetCaster():HasTalent("talent_zombie_spawn_1") then
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
    end
    zombie:AddAbility("urod_ability")
    zombie:FindAbilityByName("urod_ability"):SetLevel(self:GetLevel())
end

function zombie_spawn:SpawnAnarhOkay()
    if self:GetCaster():HasTalent("talent_zombie_spawn_3") then
        return true
    end
    local count_max = self:GetSpecialValueFor( "anarh_count" )
    local count = 0
    for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)) do
        if unit:GetUnitName() == "npc_izotov_mega_urod" and unit:GetOwner() == self:GetCaster() then
            count = count + 1             
        end
    end
    if count < count_max then
        return true
    else
        return false
    end
end


modifier_zombie_spawn_zombie = class({})

function modifier_zombie_spawn_zombie:IsPurgable()
    return false
end

function modifier_zombie_spawn_zombie:IsHidden()
    return true
end

function modifier_zombie_spawn_zombie:OnCreated()
    if not IsServer() then return end
    local health = self:GetAbility():GetSpecialValueFor( "zombie_health" )
    local damage = self:GetAbility():GetSpecialValueFor( "zombie_damage" )
    local mult = self:GetAbility():GetSpecialValueFor( "zombie_multiplier" )
    if self:GetParent():GetUnitName() == "npc_izotov_mega_urod" then
        health = health * mult
        damage = damage * mult
    end
    self:GetParent():SetBaseDamageMin(damage)
    self:GetParent():SetBaseDamageMax(damage)
    self:GetParent():SetBaseMaxHealth(health)
    self:GetParent():SetHealth(health)
end 

function modifier_zombie_spawn_zombie:DeclareFunctions()
    local decFuncs =
    {
        MODIFIER_EVENT_ON_DEATH,
    }

    return decFuncs
end

function modifier_zombie_spawn_zombie:OnDeath( params )
    if not IsServer() then return end
    local parent = self:GetParent()
    local target = params.target
    if params.unit:IsRealHero() and params.attacker == self:GetParent() then
        self:GetAbility():SpawnAnarchist(params.unit:GetAbsOrigin())
    end
end

death_passive = class({})

LinkLuaModifier("modifier_death_passive",  "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_NONE)

function death_passive:GetIntrinsicModifierName()
    return "modifier_death_passive"
end

modifier_death_passive = class({})

function modifier_death_passive:IsHidden()
    return true
end

function modifier_death_passive:IsPurgable()
    return false
end

function modifier_death_passive:DeclareFunctions()
    local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE}

    return decFuncs
end

function modifier_death_passive:OnTakeDamage(keys)
    if not IsServer() then return end
    local attacker = keys.attacker
    local target = keys.unit 
    local damage = keys.damage
    local chance = self:GetAbility():GetSpecialValueFor( "chance" )
    if self:GetParent() == target then
        if self:GetParent():PassivesDisabled() then return end
        if self:GetParent():IsIllusion() then return end
        if self:GetParent():GetHealth() <= 0 then
            if chance >= RandomInt(1, 100) then
                self:GetParent():SetHealth(1)
                local damageTable = {
                    victim = self:GetCaster(),
                    attacker = self:GetCaster(),
                    damage = 100000000,
                    damage_type = DAMAGE_TYPE_PURE,
                    ability = self:GetAbility(),
                    damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
                }
                ApplyDamage(damageTable)
            end             
        end
    end
end

urod_ability = class({})

LinkLuaModifier( "modifier_urod_ability_aura", "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_urod_ability", "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_NONE)

function urod_ability:GetIntrinsicModifierName()    
    return "modifier_urod_ability_aura"
end

modifier_urod_ability_aura = class({})

function modifier_urod_ability_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_urod_ability_aura:GetAuraRadius()   
    return 1200
end

function modifier_urod_ability_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED
end

function modifier_urod_ability_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_urod_ability_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_urod_ability_aura:GetModifierAura()
    return "modifier_urod_ability"
end

function modifier_urod_ability_aura:IsAura()
    if IsServer() then
       return true
    end
end

function modifier_urod_ability_aura:IsAuraActiveOnDeath()
    return false
end

function modifier_urod_ability_aura:IsDebuff()
    return false
end

function modifier_urod_ability_aura:IsHidden()
    return true
end

function modifier_urod_ability_aura:RemoveOnDeath()
    return false
end

function  modifier_urod_ability_aura:IsPurgable()
    return false
end

modifier_urod_ability = class({})

function modifier_urod_ability:DeclareFunctions() 
    local decFuncs = {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
                      MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
                  MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    
    return decFuncs 
end

function modifier_urod_ability:GetModifierBaseDamageOutgoing_Percentage() 
    if self:GetAbility() then        
        return self:GetAbility():GetSpecialValueFor( "bonus_damage" )   
    end  
end

function modifier_urod_ability:GetModifierConstantHealthRegen()  
    if self:GetAbility() then    
        return self:GetAbility():GetSpecialValueFor( "bonus_hp_regen" ) 
    end 
end

function modifier_urod_ability:GetModifierAttackSpeedBonus_Constant() 
    if self:GetAbility() then     
        return self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )  
    end
end