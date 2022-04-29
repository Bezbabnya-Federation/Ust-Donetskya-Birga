LinkLuaModifier( "modifier_movespeed_cap", "modifiers/modifier_limit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_zombie_spawn", "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_BOTH )

LinkLuaModifier( "modifier_Izotov_submarine_boat", "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Boat_damage_debuff", "abilities/heroes/izotov.lua", LUA_MODIFIER_MOTION_NONE )

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
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_zombie_spawn", {})
       
       --  if not self:GetCaster():HasTalent("izotov_bonus_1") then
        --    zombie:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
        --end
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
    zombie:AddNewModifier(self:GetCaster(), self, "modifier_zombie_spawn", {})

    if not self:GetCaster():HasTalent("izotov_bonus_1") then
        zombie:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
    end

    zombie:AddAbility("urod_ability")
    zombie:FindAbilityByName("urod_ability"):SetLevel(self:GetLevel())

end

function zombie_spawn:SpawnAnarhOkay()

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

submarine = class({})

function submarine:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function submarine:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function submarine:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function submarine:GetAOERadius()
    return 600
end

function submarine:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("PistoletovPirat")
    GridNav:DestroyTreesAroundPoint(point, 600, false)
    self.boat = CreateUnitByName("npc_boat_"..self:GetLevel(), point, true, caster, nil, caster:GetTeamNumber())
    self.boat:SetOwner(caster)
    FindClearSpaceForUnit(self.boat, self.boat:GetAbsOrigin(), true)
    self.boat:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    self.boat:AddNewModifier(self:GetCaster(), self, "modifier_Izotov_submarine_boat", {})
    if self:GetCaster():HasShard() then
        self.boat:SetControllableByPlayer(self:GetCaster():GetPlayerID(), false)
    end
end

function submarine:OnProjectileHit( target, location )
    if not target then return end
    self.split_shot_attack = true
    self.boat:PerformAttack( target, true, true, true, false, false, false, false )
    self.split_shot_attack = false
end

modifier_Izotov_submarine_boat = class({})

function modifier_Izotov_submarine_boat:IsHidden()
    return true
end

function modifier_Izotov_submarine_boat:IsPurgable()
    return false
end

function modifier_Izotov_submarine_boat:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_Izotov_submarine_boat:OnCreated( kv )
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_Izotov_submarine_boat:OnIntervalThink()
    if not IsServer() then return end
    local targets = FindUnitsInRadius(self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    for _,target in pairs(targets) do
        local projectile_info = 
        {
            EffectName = "particles/units/heroes/hero_morphling/morphling_base_attack.vpcf",
            Ability = self:GetAbility(),
            vSpawnOrigin = self:GetParent():GetAbsOrigin(),
            Target = target,
            Source = self:GetParent(),
            bHasFrontalCone = false,
            iMoveSpeed = 500,
            bReplaceExisting = false,
            bProvidesVision = false
        }
        ProjectileManager:CreateTrackingProjectile(projectile_info)
    end
end

function modifier_Izotov_submarine_boat:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
    return state
end

function modifier_Izotov_submarine_boat:DeclareFunctions()
    local funcs = 
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }
    return funcs
end

function modifier_Izotov_submarine_boat:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    local stack = 0
    local modifier = params.target:FindModifierByName( "modifier_Boat_damage_debuff" )
    if modifier==nil then
        if params.target:IsBoss() then return end
        params.target:AddNewModifier(
            self:GetParent(),
            self:GetAbility(),
            "modifier_Boat_damage_debuff",
            { duration = 30 }
        )
        stack = 1
    else
        modifier:IncrementStackCount()
        modifier:ForceRefresh()
        stack = modifier:GetStackCount()
    end
    return stack * self:GetParent():GetAttackDamage() / 100 * 25
end

modifier_Boat_damage_debuff = class({})

function modifier_Boat_damage_debuff:IsHidden()
    return true
end

function modifier_Boat_damage_debuff:IsPurgable()
    return false
end

function Spawn( entityKeyValues )
    if not IsServer() then
        return
    end
    if thisEntity == nil then
        return
    end

    thisEntity:SetContextThink( "BoatThink", BoatThink, 0.5 )
end

function BoatThink()
    if ( not thisEntity:IsAlive() ) then
        return -1 
    end
  
    if GameRules:IsGamePaused() == true then
        return 1 
    end

    if thisEntity:GetOwner():HasShard() then
        return 1
    end

    local OWNER = thisEntity:GetOwner()
    local Owner_location = OWNER:GetAbsOrigin()
    local order = 
    {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
        TargetIndex = OWNER:entindex()
    }   
    ExecuteOrderFromTable(order)
    return 1  
end



