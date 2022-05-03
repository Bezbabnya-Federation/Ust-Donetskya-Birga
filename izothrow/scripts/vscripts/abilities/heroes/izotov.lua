LinkLuaModifier( "modifier_izothrow_stunned", "modifiers/modifier_dota_modifiers_custom.lua", LUA_MODIFIER_MOTION_NONE )
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
        
        if not self:GetCaster():HasTalent("izotov_bonus_1") then
            zombie:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
        end
    end

    if self:GetCaster():HasTalent("izotov_bonus_2") then
        if self.spawn_anarhist_talent then
            self:SpawnAnarchist(self:GetCaster():GetAbsOrigin() + (self:GetCaster():GetForwardVector() * 300))
        end
    end
    if self.spawn_anarhist_talent then
        self.spawn_anarhist_talent = false
    else 
        self.spawn_anarhist_talent = true
    end

    -- EmitSoundOn("", self:GetCaster())
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
    
    if not self:GetCaster():HasTalent("izotov_bonus_1") then
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
    end
    
    zombie:AddAbility("urod_ability")
    zombie:FindAbilityByName("urod_ability"):SetLevel(self:GetLevel())
    -- zombie:EmitSound("")
end

function zombie_spawn:SpawnAnarhOkay()
    if self:GetCaster():HasTalent("izotov_bonus_3") then
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