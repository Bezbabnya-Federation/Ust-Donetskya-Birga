LinkLuaModifier( "modifier_mixalich_tank", "abilities/heroes/mixalich.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tank_damage_debuff", "abilities/heroes/mixalich.lua", LUA_MODIFIER_MOTION_NONE )

tank = class({})

function tank:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function tank:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function tank:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function tank:GetAOERadius()
    return 600
end

function tank:OnSpellStart()
    
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    
    -- caster:EmitSound("")
    
    GridNav:DestroyTreesAroundPoint(point, 600, false)
    
    self.tank = CreateUnitByName("npc_tank_"..self:GetLevel(), point, true, caster, nil, caster:GetTeamNumber())
    self.tank:SetOwner(caster)
    
    FindClearSpaceForUnit(self.tank, self.tank:GetAbsOrigin(), true)
    
    self.tank:AddNewModifier(self:GetCaster(), self, "modifier_kill", {duration = duration})
    self.tank:AddNewModifier(self:GetCaster(), self, "modifier_mixalich_tank", {})
    
    if self:GetCaster():HasShard() then
        self.tank:SetControllableByPlayer(self:GetCaster():GetPlayerID(), false)
    end
end

function tank:OnProjectileHit( target, location )
    if not target then return end
    self.split_shot_attack = true
    self.tank:PerformAttack( target, true, true, true, false, false, false, false )
    self.split_shot_attack = false
end

modifier_mixalich_tank = class({})

function modifier_mixalich_tank:IsHidden()
    return true
end

function modifier_mixalich_tank:IsPurgable()
    return false
end

function modifier_mixalich_tank:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_mixalich_tank:OnCreated( kv )
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end

function modifier_mixalich_tank:OnIntervalThink()
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

function modifier_mixalich_tank:CheckState()
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

function modifier_mixalich_tank:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    }
    return funcs
end

function modifier_mixalich_tank:GetModifierProcAttack_BonusDamage_Physical( params )
    if not IsServer() then return end
    local stack = 0
    local modifier = params.target:FindModifierByName( "modifier_tank_damage_debuff" )
    if modifier==nil then
        if params.target:IsBoss() then return end
        params.target:AddNewModifier(
            self:GetParent(),
            self:GetAbility(),
            "modifier_tank_damage_debuff",
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

modifier_tank_damage_debuff = class({})

function modifier_tank_damage_debuff:IsHidden()
    return true
end

function modifier_tank_damage_debuff:IsPurgable()
    return false
end

function Spawn( entityKeyValues )
    if not IsServer() then
        return
    end
    if thisEntity == nil then
        return
    end

    thisEntity:SetContextThink( "tankThink", tankThink, 0.5 )
end

function tankThink()
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

