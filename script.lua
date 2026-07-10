-- OTIMIZAÇÃO SUPREMA + MODO ESCONDE-ESCONDE (MÁXIMO FPS / OCULTAR TAG)
if not game:IsLoaded() then game.Loaded:Wait() end

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES DE DESEMPENHO E JOGO
local VELOCIDADE_DISCRETA = 20
local DISTANCIA_RENDER_MAPA = 250 

-- 1. MODO ESCONDER: OCULTA O SEU NOME E VIDA PARA OS OUTROS NÃO TE ACHAREM
local function OcultarIdentidade(char)
    if not char then return end
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = VELOCIDADE_DISCRETA
        -- Deixa o nome e a barra de vida invisíveis para quem está procurando
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    end
end

if LocalPlayer.Character then OcultarIdentidade(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(OcultarIdentidade)

task.spawn(function()
    while task.wait(1.5) do
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if humanoid.WalkSpeed ~= VELOCIDADE_DISCRETA then
                    humanoid.WalkSpeed = VELOCIDADE_DISCRETA
                end
                if humanoid.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                end
            end
        end
    end
end)

-- 2. FORÇAR CONFIGURAÇÃO GRÁFICA INTERNA AO MÍNIMO
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
setfpscap(120)

-- 3. LIMPEZA TOTAL DE TEXTURAS (MAPA LISO PARA MELHOR CAMUFLAGEM)
local function OtimizarObjeto(obj)
    if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("Sky") then
        obj:Destroy()
    elseif obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("CornerWedgePart") or obj:IsA("WedgePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
        obj.Enabled = false
    elseif obj:IsA("Explosion") then
        obj.Visible = false
    elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
        obj:Destroy()
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do pcall(OtimizarObjeto) end
Workspace.DescendantAdded:Connect(function(obj) pcall(OtimizarObjeto) end)

-- 4. DESTRUTOR DE SOMBRAS E ILUMINAÇÃO (EVITA QUE SUA SOMBRA TE DENUNCIE)
local function LimparFiltrosEBugs()
    if Lighting then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        
        for _, efeito in ipairs(Lighting:GetChildren()) do
            if efeito:IsA("BlurEffect") or efeito:IsA("SunRaysEffect") or efeito:IsA("BloomEffect") or efeito:IsA("DepthOfFieldEffect") or efeito:IsA("ColorCorrectionEffect") then
                efeito:Destroy()
            end
        end
    end

    if Workspace.CurrentCamera then
        for _, v in ipairs(Workspace.CurrentCamera:GetChildren()) do
            if not v:IsA("Camera") then v:Destroy() end
        end
    end
end

LimparFiltrosEBugs()
task.spawn(function()
    while task.wait(0.5) do LimparFiltrosEBugs() end
end)

-- 5. RENDERIZADOR DINÂMICO DE MAPA
task.spawn(function()
    while task.wait(2) do
        local meuChar = LocalPlayer.Character
        local meuRoot = meuChar and meuChar:FindFirstChild("HumanoidRootPart")
        
        if meuRoot then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and obj.Name ~= LocalPlayer.Name then
                    local basePart = obj:FindFirstChildOfClass("BasePart") or obj:FindFirstChildWhichIsA("BasePart", true)
                    if basePart then
                        local distancia = (meuRoot.Position - basePart.Position).Magnitude
                        if distancia > DISTANCIA_RENDER_MAPA then
                            obj.Parent = nil
                            task.spawn(function()
                                while meuChar and meuChar.Parent and meuRoot and meuRoot.Parent and (meuRoot.Position - basePart.Position).Magnitude > DISTANCIA_RENDER_MAPA do
                                    task.wait(2)
                                end
                                obj.Parent = Workspace
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 6. REMOÇÃO DE EFEITOS DE ÁGUA E RASTROS
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 1
end

task.spawn(function()
    while task.wait(5) do
        if Workspace:FindFirstChild("Debris") then
            Workspace.Debris:ClearAllChildren()
        end
    end
end)

print("[Esconde-Esconde] Script ativado! Nome ocultado e FPS no máximo.")
