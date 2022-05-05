LinkLuaModifier("modifier_chornobaivka", "abilities/heroes/zelensky.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chornobaivka_immunity", "abilities/heroes/zelensky.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chornobaivka_debuff", "abilities/heroes/zelensky.lua", LUA_MODIFIER_MOTION_NONE)

chornobaivka = class({})

function chornobaivka:GetCooldown(level)
    return self.BaseClass.GetCooldown(self, level)
end

function chornobaivka:GetCastRange(location, target)
    return self:GetSpecialValueFor( "effect_radius" )
end

function chornobaivka:GetManaCost(level)
    return self.BaseClass.GetManaCost(self, level)
end

function chornobaivka:GetChannelAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_4
end

function chornobaivka:OnAbilityPhaseStart()
	if not IsServer() then return end
	self.channel_duration = self:GetChannelTime()
	local fImmuneDuration = self.channel_duration
	
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_chornobaivka_immunity", { duration = fImmuneDuration } )
	self.nPreviewFX = ParticleManager:CreateParticle( "particles/booom/1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	
	ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
	ParticleManager:SetParticleControl( self.nPreviewFX, 1, Vector( 250, 250, 250 ) )
	ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 176, 224, 230 ) )
	return true
end

function chornobaivka:OnSpellStart()
	if not IsServer() then return end	
	if self.nPreviewFX then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end
	self.effect_radius = self:GetSpecialValueFor("effect_radius")
	self.interval = self:GetSpecialValueFor("interval")
	self.mana = self:GetCaster():GetMana() * 0.8
	self.mana_damage = self.mana / 5
	self.flNextCast = 0.0
	if self:GetCaster():HasScepter() then
		self:GetCaster():SetMana(self:GetCaster():GetMana() - self.mana)
	end
	-- EmitSoundOn("", self:GetCaster())
end

function chornobaivka:OnChannelFinish(bInterrupted)
    if not IsServer() then return end
    if self.nPreviewFX then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end
	-- self:GetCaster():StopSound("")
	self:GetCaster():RemoveModifierByName("modifier_chornobaivka_immunity")
	if not self:GetCaster():HasShard() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_izothrow_stunned", { duration = 3 } )
	end 
end

function chornobaivka:OnChannelThink( flInterval )
	if not IsServer() then return end
	
	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,300,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
	if #targets >= 1 then	
		for _,unit in pairs(targets) do
				
			local distance = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
			local direction = (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
			local bump_point = self:GetCaster():GetAbsOrigin() - direction * (distance + 250)
			local knockbackProperties =
			{
				center_x = bump_point.x,
				center_y = bump_point.y,
				center_z = bump_point.z,
				duration = 0.5,
				knockback_duration = 0.5,
				knockback_distance = 300,
				knockback_height = 0
			}
				
			if not unit:HasModifier("modifier_knockback") then
				unit:AddNewModifier( unit, self, "modifier_knockback", knockbackProperties )
				unit:AddNewModifier( self:GetCaster(), self, "modifier_disarmed", { duration = 3 } )
				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_CUSTOMORIGIN, nil )
				ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
				ParticleManager:SetParticleControl( nFXIndex, 1, Vector ( 500, 500, 500 ) )
			end
		end
	end
	
	self.flNextCast = self.flNextCast + flInterval
	if self.flNextCast >= self.interval  then
		local nMaxAttempts = 7
		local nAttempts = 0
		
		local vPos = nil
		repeat
			vPos = self:GetCaster():GetOrigin() + RandomVector( RandomInt( 50, self.effect_radius ) )
			local hThinkersNearby = Entities:FindAllByClassnameWithin( "npc_dota_thinker", vPos, 600 )
			local hOverlappingWrathThinkers = {}

			for _, hThinker in pairs( hThinkersNearby ) do
				if ( hThinker:HasModifier( "modifier_chornobaivka" ) ) then
					table.insert( hOverlappingWrathThinkers, hThinker )
				end
			end
			nAttempts = nAttempts + 1
			if nAttempts >= nMaxAttempts then
				break
			end
		until ( #hOverlappingWrathThinkers == 0 )

		CreateModifierThinker( self:GetCaster(), self, "modifier_chornobaivka", {}, vPos, self:GetCaster():GetTeamNumber(), false )
		self.flNextCast = self.flNextCast - self.interval
	end
end

modifier_chornobaivka = class({})

function modifier_chornobaivka:IsPurgable()
	return false
end

function modifier_chornobaivka:IsHidden()
	return true
end

function modifier_chornobaivka:OnCreated(kv)
	if not IsServer() then return end
	self.delay = self:GetAbility():GetSpecialValueFor( "delay" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local ability = self:GetCaster():FindAbilityByName("chornobaivka")
	if self:GetCaster():HasScepter() then
		self.blast_damage = self:GetAbility():GetSpecialValueFor( "blast_damage" ) + ability.mana_damage
	else
		self.blast_damage = self:GetAbility():GetSpecialValueFor( "blast_damage" )
	end
	self:StartIntervalThink( self.delay )
	
	local nFXIndex = ParticleManager:CreateParticle( "particles/booom/1.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.delay, 1.0 ) )
	ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 175, 238, 238 ) )
	ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end

function modifier_chornobaivka:OnIntervalThink()
	if not IsServer() then return end
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil )
	
	ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector ( self.radius, self.radius, self.radius ) )
	ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 175, 238, 238 ) )
	ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	
	EmitSoundOn( "Hero_Techies.Suicide", self:GetParent() )
	
	local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false )
	for _,enemy in pairs( enemies ) do
		if enemy ~= nil and enemy:IsInvulnerable() == false then
			local damageInfo =
			{
				victim = enemy,
				attacker = self:GetCaster(),
				damage = self.blast_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility(),
			}
			ApplyDamage( damageInfo )
		end
	end
	UTIL_Remove( self:GetParent() )
end

modifier_chornobaivka_immunity = class({})

function modifier_chornobaivka_immunity:IsHidden()
	return true
end

function modifier_chornobaivka_immunity:IsPurgable()
	return false
end

function modifier_chornobaivka_immunity:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_chornobaivka_immunity:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
	return state
end