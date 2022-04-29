LinkLuaModifier( "modifier_nekit_suicide_debuff", "abilities/heroes/homunculus.lua", LUA_MODIFIER_MOTION_NONE)

nekit_suicide = class({})

function nekit_suicide:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function nekit_suicide:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function nekit_suicide:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function nekit_suicide:OnSpellStart()
    if not IsServer() then return end
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    local damage = self:GetSpecialValueFor("damage")

    -- self:GetCaster():EmitSound("")

    local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    0,
    FIND_ANY_ORDER,
    false)

    for _,unit in pairs(targets) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_nekit_suicide_debuff", { duration = duration * (1 - unit:GetStatusResistance()) } )
        ApplyDamage({victim = unit, attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, (radius - 255) / 1500, 1500))

    local damageTable = {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = 100000000,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self,
        damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    }

    local talent_damage = self:GetCaster():GetHealth() / 100 * self:GetCaster():FindTalentValue("nekit_bonus")
    local new_health = self:GetCaster():GetHealth() - talent_damage
    if self:GetCaster():HasTalent("nekit_bonus") then
        self:GetCaster():ModifyHealth(new_health, self, false, 0)
    else
        ApplyDamage(damageTable)
    end
end

modifier_nekit_suicide_debuff = class({})

function modifier_nekit_suicide_debuff:IsPurgable()
    return false
end

function modifier_nekit_suicide_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.25)
    self:OnIntervalThink()
end

function modifier_nekit_suicide_debuff:OnIntervalThink()
    if not IsServer() then return end
    local damage = self:GetAbility():GetSpecialValueFor("per_damage")
    ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_nekit_suicide_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_nekit_suicide_debuff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor( "magical_resistance" )
end

function modifier_nekit_suicide_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor( "movement_speed" )
end

function modifier_nekit_suicide_debuff:GetEffectName()
    return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_nekit_suicide_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

function modifier_nekit_suicide_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end

function modifier_nekit_suicide_debuff:StatusEffectPriority()
    return 10
end
