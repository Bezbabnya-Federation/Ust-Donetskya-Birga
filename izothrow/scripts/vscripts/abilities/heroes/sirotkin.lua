LinkLuaModifier("modifier_sirotkin_teachers_life", "abilities/heroes/sirotkin.lua", LUA_MODIFIER_MOTION_NONE)

teachers_life = class({}) 

function teachers_life:GetCastRange(location, target)
    return self:GetSpecialValueFor("radius")
end

function teachers_life:GetIntrinsicModifierName()
    return "modifier_sirotkin_teachers_life"
end

modifier_sirotkin_teachers_life = class({})

function modifier_sirotkin_teachers_life:IsHidden()
    return true
end

function modifier_sirotkin_teachers_life:IsPurgable()
    return false
end

function modifier_sirotkin_teachers_life:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_sirotkin_teachers_life:OnTakeDamage (event)
    if event.unit == self:GetParent() then

        local caster = self:GetParent()
        local post_damage = event.damage
        local original_damage = event.original_damage
        local ability = self:GetAbility()
        local damage_reflect_pct = (ability:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("sirotkin_bonus")) * 0.01
        local radius = ability:GetSpecialValueFor("radius")
        
        if self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then return end
        if caster:IsAlive() then
            caster:SetHealth(caster:GetHealth() + (post_damage * damage_reflect_pct) )
        end

        local units = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            FIND_ANY_ORDER,
            false
        )
        if original_damage > 10000 then
            ApplyDamage({victim = event.attacker, attacker = caster, ability = self:GetAbility(), damage = damage, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })   
            return
        end
        for _,unit in pairs(units) do
            if bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
               
                local vCaster = caster:GetAbsOrigin()
                local vUnit = unit:GetAbsOrigin()
                local distance = (vUnit - vCaster):Length2D()
                local damage = original_damage * damage_reflect_pct
                local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf", PATTACH_POINT_FOLLOW, caster )

                ParticleManager:SetParticleControl(particle, 0, vCaster)
                ParticleManager:SetParticleControl(particle, 1, vUnit)
                ParticleManager:SetParticleControl(particle, 2, vCaster)

                ApplyDamage({victim = unit, attacker = caster, ability = self:GetAbility(), damage = damage, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = DAMAGE_TYPE_PURE })
            end
        end
    end
end