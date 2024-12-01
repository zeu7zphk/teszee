--[[
    Saitama Animations Module
    Para uso no Roblox - The Strongest Battlegrounds
    
    Este script deve ser carregado como um ModuleScript no Roblox Studio
    e só funcionará dentro do ambiente do Roblox.
]]

-- Tipos e constantes
local AnimationIDs = {
    BasicAttack = {
        "rbxassetid://13785155250", -- Soco normal (animação de soco rápido)
        "rbxassetid://13785156321"  -- Combo (combo de socos rápidos)
    },
    Dash = "rbxassetid://13785157432", -- movimento de dash lateral com rastro
    Skills = {
        Skill1 = "rbxassetid://13785158543", -- Serious Punch (soco poderoso com efeito de onda de choque)
        Skill2 = "rbxassetid://13785159654", -- Consecutive Punches (múltiplos socos rápidos com efeitos visuais)
        Skill3 = "rbxassetid://13785160765", -- Serious Side Steps (movimento lateral rápido com clones)
        Skill4 = "rbxassetid://13785161876"  -- Death Punch (soco final devastador)
    }
}

-- Funções auxiliares
local function createAnimation(id)
    local animation = Instance.new("Animation")
    animation.AnimationId = id
    return animation
end

local function playSkillAnimation(animator, skillAnim, effects)
    local animTrack = animator:LoadAnimation(skillAnim)
    animTrack:Play()
    animTrack.Priority = Enum.AnimationPriority.Action
    
    if effects then
        effects()
    end
end

-- Sistema de animação
local function setupAnimations(character)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    
    local animations = {
        BasicAttack = {},
        Dash = nil,
        Skills = {}
    }
    
    -- Carrega animações de ataque básico
    for i, id in ipairs(AnimationIDs.BasicAttack) do
        animations.BasicAttack[i] = createAnimation(id)
    end
    
    -- Carrega animação de dash
    animations.Dash = createAnimation(AnimationIDs.Dash)
    
    -- Carrega animações de skills
    for skillName, id in pairs(AnimationIDs.Skills) do
        animations.Skills[skillName] = createAnimation(id)
    end
    
    -- Carrega as animações no animator
    for _, anims in pairs(animations) do
        if type(anims) == "table" then
            for _, anim in pairs(anims) do
                animator:LoadAnimation(anim)
            end
        elseif anims then
            animator:LoadAnimation(anims)
        end
    end
    
    return animations
end

-- Configuração do ataque básico
local function setupBasicAttack(character, animations)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    
    character.SaitamaValues.BasicAttack.OnClientEvent:Connect(function()
        local randomAnim = animations.BasicAttack[
            math.random(1, #animations.BasicAttack)
        ]
        
        local animTrack = animator:LoadAnimation(randomAnim)
        animTrack:Play()
        animTrack.Speed = 1.2
        animTrack.Priority = Enum.AnimationPriority.Action
        
        -- Efeitos visuais do soco
        local trail = Instance.new("Trail")
        trail.Parent = character["Right Arm"]
        game:GetService("Debris"):AddItem(trail, 0.1)
    end)
end

-- Configuração do dash
local function setupDash(character, animations)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    
    character.SaitamaValues.Dash.OnClientEvent:Connect(function()
        local animTrack = animator:LoadAnimation(animations.Dash)
        
        animTrack:Play()
        animTrack.Speed = 1.5
        animTrack.Priority = Enum.AnimationPriority.Movement
        
        -- Efeito de movimento rápido
        local blur = Instance.new("MotionBlur")
        blur.Parent = workspace.CurrentCamera
        game:GetService("Debris"):AddItem(blur, 0.2)
    end)
end

-- Configuração das skills
local function setupSkills(character, animations)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    
    -- Skill 1: Serious Punch
    character.SaitamaValues.Skill1.OnClientEvent:Connect(function()
        playSkillAnimation(animator, animations.Skills.Skill1, function()
            local explosion = Instance.new("Explosion")
            explosion.Position = character.HumanoidRootPart.Position
            explosion.BlastPressure = 0
            explosion.Parent = workspace
            game:GetService("Debris"):AddItem(explosion, 1)
        end)
    end)
    
    -- Skill 2: Consecutive Punches
    character.SaitamaValues.Skill2.OnClientEvent:Connect(function()
        playSkillAnimation(animator, animations.Skills.Skill2, function()
            for i = 1, 10 do
                local trail = Instance.new("Trail")
                trail.Parent = character["Right Arm"]
                game:GetService("Debris"):AddItem(trail, 0.05)
                task.wait(0.05)
            end
        end)
    end)
    
    -- Skill 3: Serious Side Steps
    character.SaitamaValues.Skill3.OnClientEvent:Connect(function()
        playSkillAnimation(animator, animations.Skills.Skill3, function()
            local clone = character:Clone()
            clone.Parent = workspace
            game:GetService("Debris"):AddItem(clone, 0.2)
        end)
    end)
    
    -- Skill 4: Death Punch
    character.SaitamaValues.Skill4.OnClientEvent:Connect(function()
        playSkillAnimation(animator, animations.Skills.Skill4, function()
            local shockwave = Instance.new("Part")
            shockwave.Shape = Enum.PartType.Ball
            shockwave.Transparency = 0.5
            shockwave.Position = character.HumanoidRootPart.Position
            shockwave.Parent = workspace
            game:GetService("Debris"):AddItem(shockwave, 0.5)
        end)
    end)
end

-- Módulo principal
local SaitamaAnimations = {}

function SaitamaAnimations.init(character)
    if not character:FindFirstChild("SaitamaValues") then
        warn("SaitamaValues não encontrado no personagem")
        return
    end
    
    local animations = setupAnimations(character)
    setupBasicAttack(character, animations)
    setupDash(character, animations)
    setupSkills(character, animations)
end

return SaitamaAnimations
