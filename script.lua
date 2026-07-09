-- COMBO SUPREMO V2: ESP COMPLETO + SEGUIDOR DE LINHA + FPS MÁXIMO
if not game:IsLoaded() then game.Loaded:Wait() end

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIGURAÇÕES DE PERFORMANCE E JOGABILIDADE
local VELOCIDADE_DISCRETA = 20
local INTERVALO_LOOP = 0.5 -- Reação mais rápida para o ESP acompanhar o movimento real
local DISTANCIA_MAXIMA_RENDERING = 300 

_G.RealmeC3_ESP = true

-- Função para aplicar a velocidade de forma leve
local function AplicarVelocidade(char)
    if not char then return end
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = VELOCIDADE_DISCRETA
    end
end

if LocalPlayer.Character then AplicarVelocidade(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(AplicarVelocidade)

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    if LocalPlayer.Character then AplicarVelocidade(LocalPlayer.Character) end
end)

-- 1. GRÁFICOS MÍNIMOS (MODO LISO)
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
setfpscap(120)

local function OtimizarObjeto(obj)
    if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("Sky") then
        obj:Destroy()
    elseif obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("CornerWedgePart") or obj:IsA("WedgePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
        obj.Enabled = false
    elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
        obj:Destroy()
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do pcall(OtimizarObjeto) end
Workspace.DescendantAdded:Connect(function(obj) pcall(OtimizarObjeto) end)

-- 2. LIMPADOR DE EFEITOS DA TELA
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
end
LimparFiltrosEBugs()
task.spawn(function()
    while task.wait(1) do LimparFiltrosEBugs() end
end)

-- 3. REAÇÃO DE TOQUE ULTRA RÁPIDA
local processandoClique = false
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not processandoClique then
        processandoClique = true
        VirtualInputManager:SendMouseButtonEvent(input.Position.X, input.Position.Y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(input.Position.X, input.Position.Y, 0, false, game, 0)
        task.wait()
        processandoClique = false
    end
end)

if Terrain then Terrain.WaterTransparency = 1 end

-- 4. SISTEMA DE ESP MELHORADO (NOME + DISTÂNCIA + LINHA ATÉ O JOGADOR)
local function ObterEquipe(player)
    if not player or not player.Parent then return Color3.fromRGB(255, 255, 255), "JOGADOR" end
    local team = player.Team
    if not team then return Color3.fromRGB(255, 255, 255), "JOGADOR" end

    local tName = string.lower(team.Name or "")
    local tColor = team.TeamColor and team.TeamColor.Color

    if string.find(tName, "seek") or string.find(tName, "busc") or string.find(tName, "caça") or string.find(tName, "pega") or string.find(tName, "red") or string.find(tName, "pegador") or string.find(tName, "paint") or (tColor and tColor.R > 0.6 and tColor.B < 0.4) then
        return Color3.fromRGB(255, 0, 0), "⚠️ CAÇADOR"
    end
    if string.find(tName, "hider") or string.find(tName, "escond") or string.find(tName, "blue") or string.find(tName, "pinte") or (tColor and tColor.B > 0.6 and tColor.R < 0.4) then
        return Color3.fromRGB(0, 170, 255), "🛡️ ESCONDIDO"
    end
    return Color3.fromRGB(0, 255, 100), "JOGADOR"
end

local function MonitorarJogador(player)
    if player == LocalPlayer then return end

    local function IniciarLoopESP(char)
        if not char then return end
        
        -- Cria a linha usando LineHandleAdornment (Super leve para celular)
        local linha = Instance.new("LineHandleAdornment")
        linha.Name = "C3_Linha"
        linha.Length = 0
        linha.Thickness = 3
        linha.AlwaysOnTop = true
        linha.ZIndex = 10
        linha.Parent = Workspace.CurrentCamera

        task.spawn(function()
            while _G.RealmeC3_ESP and player and player.Parent and char and char.Parent do
                local meuChar = LocalPlayer.Character
                if meuChar then
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local meuRoot = meuChar:FindFirstChild("HumanoidRootPart")

                    if head and root and meuRoot then
                        local dist = math.floor((meuRoot.Position - root.Position).Magnitude)
                        local tag = head:FindFirstChild("C3_Tag")

                        if dist <= DISTANCIA_MAXIMA_RENDERING then
                            local corTime, tipo = ObterEquipe(player)
                            
                            -- Configura a Linha Guia
                            linha.Color3 = corTime
                            linha.Adornee = meuRoot
                            linha.Target = root

                            -- Configura a Tag de Nome
                            local label
                            if not tag then
                                tag = Instance.new("BillboardGui")
                                label = Instance.new("TextLabel")
                                tag.Name = "C3_Tag"
                                tag.Parent = head
                                tag.AlwaysOnTop = true
                                tag.Size = UDim2.new(0, 120, 0, 30)
                                tag.StudsOffset = Vector3.new(0, 3, 0)
                                label.Name = "Texto"
                                label.Parent = tag
                                label.BackgroundTransparency = 1
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.TextSize = 11
                                label.TextStrokeTransparency = 0
                                label.Font = Enum.Font.SourceSansBold
                            else
                                label = tag:FindFirstChild("Texto")
                            end

                            if label then
                                label.Text = string.format("%s\n%s\n[%dm]", player.Name, tipo, dist)
                                label.TextColor3 = corTime
                            end
                        else
                            if tag then tag:Destroy() end
                            linha.Adornee = nil
                            linha.Target = nil
                        end
                    end
                end
                task.wait(INTERVALO_LOOP)
            end
            if linha then linha:Destroy() end
        end)
    end

    if player.Character then IniciarLoopESP(player.Character) end
    player.CharacterAdded:Connect(IniciarLoopESP)
end

for _, p in ipairs(Players:GetPlayers()) do MonitorarJogador(p) end
Players.PlayerAdded:Connect(MonitorarJogador)

print("[Sucesso] Versão Otimizada com Linhas de Rastreamento Ativada!")
