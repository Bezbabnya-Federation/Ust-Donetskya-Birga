modifier_izothrow_stunned = class({})

function modifier_izothrow_stunned:OnCreated()
	self.stun = false
	if IsServer() then
		if self:IsNull() then return end
		for _, mod in pairs(self:GetParent():FindAllModifiers()) do
			local ability = mod:GetAbility()
			if ability then
				if self:GetAbility() == ability and self ~= mod and mod:GetName() == self:GetName() then
					if not mod:IsNull() then
						mod:Destroy()
					end
				end
			end
		end
		self:SetDuration(self:GetDuration()*(1 - self:GetParent():GetStatusResistance()), true)
	end
	self.stun = true
end

function modifier_izothrow_stunned:IsDebuff()
	return true
end

function modifier_izothrow_stunned:IsStunDebuff()
	return true
end

function modifier_izothrow_stunned:IsPurgable()
	return false
end

function modifier_izothrow_stunned:IsPurgeException()
	return true
end

function modifier_izothrow_stunned:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_izothrow_stunned:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stun,
	}

	return state
end

function modifier_izothrow_stunned:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_izothrow_stunned:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_izothrow_stunned:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_izothrow_stunned:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_izothrow_bashed = class({})

function modifier_izothrow_bashed:OnCreated()
	if not IsServer() then return end
	self:SetDuration(self:GetDuration()*(1 - self:GetParent():GetStatusResistance()), true)
end

function modifier_izothrow_bashed:IsDebuff()
	return true
end

function modifier_izothrow_bashed:IsStunDebuff()
	return true
end

function modifier_izothrow_bashed:IsPurgable()
	return false
end

function modifier_izothrow_bashed:IsPurgeException()
	return true
end

function modifier_izothrow_bashed:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_izothrow_bashed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_izothrow_bashed:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_izothrow_bashed:GetEffectName()
	return "particles/generic_gameplay/generic_bashed.vpcf"
end

function modifier_izothrow_bashed:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_izothrow_stunned_purge = class({})

function modifier_izothrow_stunned_purge:OnCreated()
	self.stun = false
	if IsServer() then
		if self:IsNull() then return end
		for _, mod in pairs(self:GetParent():FindAllModifiers()) do
			local ability = mod:GetAbility()
			if ability then
				if self:GetAbility() == ability and self ~= mod and mod:GetName() == self:GetName() then
					if not mod:IsNull() then
						mod:Destroy()
					end
				end
			end
		end
		self:SetDuration(self:GetDuration()*(1 - self:GetParent():GetStatusResistance()), true)
	end
	self.stun = true
end

function modifier_izothrow_stunned_purge:IsDebuff()
	return true
end

function modifier_izothrow_stunned_purge:IsStunDebuff()
	return true
end

function modifier_izothrow_stunned_purge:IsPurgable()
	return false
end

function modifier_izothrow_stunned_purge:IsPurgeException()
	return true
end

function modifier_izothrow_stunned_purge:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_izothrow_stunned_purge:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stun,
	}

	return state
end

function modifier_izothrow_stunned_purge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_izothrow_stunned_purge:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_izothrow_stunned_purge:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_izothrow_stunned_purge:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_izothrow_silenced = class({})

function modifier_izothrow_silenced:IsDebuff()
	return true
end

function modifier_izothrow_silenced:IsStunDebuff()
	return false
end

function modifier_izothrow_silenced:IsPurgable()
	return true
end

function modifier_izothrow_silenced:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}

	return state
end

function modifier_izothrow_silenced:GetEffectName()
	return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_izothrow_silenced:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

 modifier_izothrow_orb_effect_lua = class({})

function modifier_izothrow_orb_effect_lua:IsHidden()
	return true
end

function modifier_izothrow_orb_effect_lua:IsDebuff()
	return false
end

function modifier_izothrow_orb_effect_lua:IsPurgable()
	return false
end

function modifier_izothrow_orb_effect_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_izothrow_orb_effect_lua:OnCreated( kv )
	self.ability = self:GetAbility()
	self.cast = false
	self.records = {}
	self:StartIntervalThink(FrameTime())
	self.piska = nil
end

function modifier_izothrow_orb_effect_lua:OnIntervalThink()
	if not IsServer() then return end
	if self:GetParent():GetUnitName() == "npc_dota_hero_void_spirit" then
		local ability = self:GetParent():FindAbilityByName("van_takeitboy")
		if ability and ability:IsFullyCastable() then
			if self.piska == nil then
				self.particle = ParticleManager:CreateParticle("particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_whip_ambient.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    			ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_whip_end", self:GetParent():GetAbsOrigin(), true)
    			self.particle_2 = ParticleManager:CreateParticle("particles/van/van_effe.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    			ParticleManager:SetParticleControlEnt(self.particle_2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
    			self.piska = true
    		end
		else
			if self.particle then
				ParticleManager:DestroyParticle(self.particle, false)
    			ParticleManager:ReleaseParticleIndex(self.particle)
    			ParticleManager:DestroyParticle(self.particle_2, true)
    			ParticleManager:ReleaseParticleIndex(self.particle_2)
    			self.piska = nil
			end
		end
	end
end

function modifier_izothrow_orb_effect_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_EVENT_ON_ORDER,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}

	return funcs
end

function modifier_izothrow_orb_effect_lua:OnAttack( params )
	if params.attacker~=self:GetParent() then return end
	if self:ShouldLaunch( params.target ) then
		self.ability:UseResources( true, false, true )
		self.records[params.record] = true
		if self.ability.OnOrbFire then self.ability:OnOrbFire( params ) end
	end
	self.cast = false
end

function modifier_izothrow_orb_effect_lua:GetModifierProcAttack_Feedback( params )
	if self.records[params.record] then
		if self.ability.OnOrbImpact then self.ability:OnOrbImpact( params ) end
	end
end

function modifier_izothrow_orb_effect_lua:OnAttackFail( params )
	if self.records[params.record] then
		if self.ability.OnOrbFail then self.ability:OnOrbFail( params ) end
	end
end

function modifier_izothrow_orb_effect_lua:OnAttackRecordDestroy( params )
	self.records[params.record] = nil
end

function modifier_izothrow_orb_effect_lua:OnOrder( params )
	if params.unit~=self:GetParent() then return end

	if params.ability then
		if params.ability==self:GetAbility() then
			self.cast = true
			return
		end

		-- if casting other ability that cancel channel while casting this ability, turn off
		local pass = false
		local behavior = params.ability:GetBehaviorInt()
		if self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL ) or 
			self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT ) or
			self:FlagExist( behavior, DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL )
		then
			local pass = true -- do nothing
		end

		if self.cast and (not pass) then
			self.cast = false
		end
	else
		-- if ordering something which cancel channel, turn off
		if self.cast then
			if self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_POSITION ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_MOVE_TO_TARGET )	or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_MOVE ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_ATTACK_TARGET ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_STOP ) or
				self:FlagExist( params.order_type, DOTA_UNIT_ORDER_HOLD_POSITION )
			then
				self.cast = false
			end
		end
	end
end

function modifier_izothrow_orb_effect_lua:GetModifierProjectileName()
	if not self.ability.GetProjectileName then return end
	if self:ShouldLaunch( self:GetCaster():GetAggroTarget() ) then
		return self.ability:GetProjectileName()
	end
end

function modifier_izothrow_orb_effect_lua:ShouldLaunch( target )
	if self.ability:GetAutoCastState() then
		if self.ability.CastFilterResultTarget~=CDOTA_Ability_Lua.CastFilterResultTarget then
			if self.ability:CastFilterResultTarget( target )==UF_SUCCESS then
				self.cast = true
			end
		else
			local nResult = UnitFilter(
				target,
				self.ability:GetAbilityTargetTeam(),
				self.ability:GetAbilityTargetType(),
				self.ability:GetAbilityTargetFlags(),
				self:GetCaster():GetTeamNumber()
			)
			if nResult == UF_SUCCESS then
				self.cast = true
			end
		end
	end

	if self.cast and self.ability:IsFullyCastable() and (not self:GetParent():IsSilenced()) then
		return true
	end

	return false
end

function modifier_izothrow_orb_effect_lua:FlagExist(a,b)
	local p,c,d=1,0,b
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c==d
end