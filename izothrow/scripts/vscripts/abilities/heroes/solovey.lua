
LinkLuaModifier("modifier_krik", "abilities/heroes/vernon.lua", LUA_MODIFIER_MOTION_NONE)

krik = class({})

function krik:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function krik:GetCastRange(location, target)
    return self.BaseClass.GetCastRange(self, location, target)
end

function krik:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function krik:OnSpellStart()

	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "duration" )

	-- caster:EmitSound("")

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),
		caster:GetOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_krik",
			{ duration = duration * (1 - enemy:GetStatusResistance()) }
		)

		if enemy:IsHero() then
			self:PlayEffects2( enemy )
		end
	end
	self:PlayEffects1()
end

function krik:PlayEffects1()
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_silencer/silencer_global_silence.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, self:GetCaster():GetForwardVector() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function krik:PlayEffects2( target )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_silencer/silencer_global_silence_hero.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_attack1",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_krik = class({})

function modifier_krik:IsPurgable() return true end

function modifier_krik:CheckState()
    local funcs = {
        [MODIFIER_STATE_SILENCED] = true,
    }
    if self:GetCaster():HasTalent("talent_krik") then
    	funcs = {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
    }
	end
    return funcs
end

function modifier_krik:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_krik:GetModifierMoveSpeedBonus_Percentage()
    if self:GetCaster():HasTalent("talent_krik") then
    	return -100
	end
end