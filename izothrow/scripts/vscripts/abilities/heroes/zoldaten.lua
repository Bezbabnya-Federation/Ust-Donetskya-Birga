zoldaten_spawn = class({})

function zoldaten_spawn:GetCooldown(level)
    return self.BaseClass.GetCooldown( self, level )
end

function zoldaten_spawn:OnSpellStart()
    if not IsServer() then return end

    local image_count = self:GetSpecialValueFor("illusion_count")
    local image_out_dmg = self:GetSpecialValueFor("outgoing_damage") + self:GetCaster():FindTalentValue("zoldaten_bonus")
    local incoming_damage = self:GetSpecialValueFor("incoming_damage")
    local duration = self:GetSpecialValueFor("illusion_duration")

    local vRandomSpawnPos = {
        Vector(108, 0, 0),
        Vector(108, 108, 0),
        Vector(108, 0, 0),
        Vector(0, 108, 0),
        Vector(-108, 0, 0),
        Vector(-108, 108, 0),
        Vector(-108, -108, 0),
        Vector(0, -108, 0),
    }

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", PATTACH_ABSORIGIN, self:GetCaster())

    for i = 1, image_count do
        local illusions = CreateIllusions( self:GetCaster(), self:GetCaster(), {duration=duration,outgoing_damage=image_out_dmg,incoming_damage=incoming_damage}, 1, 1, true, true ) 
        for k, illusion in pairs(illusions) do
            local pos = self:GetCaster():GetAbsOrigin() + vRandomSpawnPos[i]
            FindClearSpaceForUnit(illusion, pos, true)
            local particle_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_riptide_foam.vpcf", PATTACH_ABSORIGIN, illusion)
            ParticleManager:ReleaseParticleIndex(particle_2)
        end
    end

    if particle then
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end

    self:GetCaster():Stop()
    self:GetCaster():EmitSound("zoldatenspawn")
end