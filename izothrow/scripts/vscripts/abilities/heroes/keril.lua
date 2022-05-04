LinkLuaModifier("modifier_keril_umn", "abilities/heroes/ns", LUA_MODIFIER_MOTION_NONE)

keril_umn = class({}) 

function keril_umn:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level ) / ( self:GetCaster():GetCooldownReduction())
end

function keril_umn:GetIntrinsicModifierName()
    return "modifier_keril_umn"
end

modifier_keril_umn = class({})

function modifier_keril_umn:IsPurchasable()
    return false
end

function modifier_keril_umn:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
    self:SetStackCount(1)
end

function modifier_keril_umn:OnIntervalThink()
    if not IsServer() then return end
    if self:GetParent():IsIllusion() then return end
    if self:GetAbility():IsFullyCastable() then
        self:GetAbility():UseResources(false, false, true)
        local bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect") + self:GetCaster():FindTalentValue("keril_bonus")
        self:SetStackCount(self:GetStackCount() + bonus_intellect)
    end
end

function modifier_keril_umn:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }

    return funcs
end

function modifier_keril_umn:GetModifierBonusStats_Intellect( params )
    return self:GetStackCount()
end