if not game:IsLoaded() then game.Loaded:Wait() end

-- Garante execução única estável no Delta Executor
if getgenv().RealmeC3_Executado then return end
getgenv().RealmeC3_Executado = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- CONFIGURAÇÕES DE PERFORMANCE, VELOCIDADE E PULO
local VELOCIDADE_DISCRETA = 20 
local PULO_DISCRETO = 55 -- Aumenta o pulo levemente para alcançar esconderijos altos
local INTERVALO_LOOP = 1.5 
local DISTANCIA_MAXIMA_RENDERING = 220 

-- 1. SUPER OTIMIZAÇÃO GRÁFICA, CLARIDADE TOTAL (FULLBRIGHT) E NO-FOG
local function OtimizarEClarear()
    UserInputService.InputBegan:Connect(function()
        task.wait()
    end)

    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
    
    -- FullBright e NoFog: Deixa o mapa totalmente claro e sem névoa
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 999999
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    
    for _, efeito in ipairs(Lighting:GetChildren()) do
        if efeito:IsA("PostEffect") or efeito:IsA("BloomEffect") or efeito:IsA("BlurEffect") or efeito:IsA("DepthOfFieldEffect") then
            efeito.Enabled = false
        end
    end

    -- Remove texturas pesadas do mapa para o Realme C3 rodar liso
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then
            obj:Destroy()
        elseif obj:IsA("Part") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
        end
    end
end
task.spawn(OtimizarEClarear)

-- 2. SISTEMA ANTI-AFK (IMPELE QUE VOCÊ SEJA EXPULSO POR INATIVIDADE)
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Limpador de Memória RAM ativo (Roda a cada 5 segundos nos 3GB do celular)
task.spawn(function()
    while getgenv().RealmeC3_Executado do
        gcinfo()
        task.wait(5)
    end
end)

-- SISTEMA DE VELOCIDADE E PULO AUTOMÁTICO (ANTI-RESET)
local function AplicarAtributos(char)
    if not char then return end
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = VELOCIDADE_DISCRETA
        humanoid.JumpPower = PULO_DISCRETO
    end
end

if LocalPlayer.Character then AplicarAtributos(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(AplicarAtributos)

-- Mantém ativo ao trocar de equipe no Pinte ou Busque
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    if LocalPlayer.Character then
        AplicarAtributos(LocalPlayer.Character)
    end
end)

-- Filtro de equipes oficiais
local function ObterEquipe(player)
    if not player or not player.Parent then 
        return Color3.fromRGB(255, 255, 255), "JOGADOR" 
    end
    
    local team = player.Team
    if not team then 
        return Color3.fromRGB(255, 255, 255), "JOGADOR" 
    end

    local tName = string.lower(team.Name or "")
    local tColor = team.TeamColor and team.TeamColor.Color

    if string.find(tName, "seek") or string.find(tName, "busc") or string.find(tName, "caça") or string.find(tName, "pega") or string.find(tName, "red") or string.find(tName, "pegador") or string.find(tName, "paint") or (tColor and tColor.R > 0.6 and tColor.B < 0.4) then
        return Color3.fromRGB(255, 30, 30), "⚠️ CAÇADOR"
    end
    
    if string.find(tName, "hider") or string.find(tName, "escond") or string.find(tName, "blue") or string.find(tName, "pinte") or (tColor and tColor.B > 0.6 and tColor.R < 0.4) then
        return Color3.fromRGB(0, 160, 255), "🛡️ ESCONDIDO"
    end
    
    if tColor then return tColor, string.upper(team.Name or "JOGADOR") end
    return Color3.fromRGB(255, 255, 255), "JOGADOR"
end

-- 3. ESP, DISTÂNCIA EM METROS E RAIO-X ATIVO
local function MonitorarJogador(player)
    if player == LocalPlayer then return end

    local conexaoCharacter
    local conexaoTime

    local function IniciarLoopESP(char)
        if not char then return end
        
        local tagAntiga = char:FindFirstChild("C3_Tag")
        if tagAntiga then tagAntiga:Destroy() end
        local hlAntigo = char:FindFirstChild("C3_Highlight")
        if hlAntigo then hlAntigo:Destroy() end

        task.spawn(function()
            while getgenv().RealmeC3_Executado and player and player.Parent and char and char.Parent do
                local meuChar = LocalPlayer.Character
                if meuChar then
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local meuRoot = meuChar:FindFirstChild("HumanoidRootPart")

                    -- Trava de velocidade e pulo contra detecção do anti-cheat
                    local meuHumanoid = meuChar:FindFirstChildOfClass("Humanoid")
                    if meuHumanoid then
                        if meuHumanoid.WalkSpeed ~= VELOCIDADE_DISCRETA then
                            meuHumanoid.WalkSpeed = VELOCIDADE_DISCRETA
                        end
                        if meuHumanoid.JumpPower ~= PULO_DISCRETO then
                            meuHumanoid.JumpPower = PULO_DISCRETO
                        end
                    end

                    if head and root and meuRoot then
                        local dist = math.floor((meuRoot.Position - root.Position).Magnitude)
                        local tag = head:FindFirstChild("C3_Tag")
                        local hl = char:FindFirstChild("C3_Highlight")

                        if dist <= DISTANCIA_MAXIMA_RENDERING then
                            local corTime, tipo = ObterEquipe(player)
                            
                            local label
                            if not tag then
                                tag = Instance.new("BillboardGui")
                                label = Instance.new("TextLabel")

                                tag.Name = "C3_Tag"
                                tag.Parent = head
                                tag.AlwaysOnTop = true
                                tag.Size = UDim2.new(0, 110, 0, 25)
                                tag.StudsOffset = Vector3.new(0, 3, 0)

                                label.Name = "Texto"
                                label.Parent = tag
                                label.BackgroundTransparency = 1
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.TextSize = 10
                                label.TextStrokeTransparency = 0.3
                                label.Font = Enum.Font.SourceSansBold
                            else
                                label = tag:FindFirstChild("Texto")
                            end

                            if label then
                                label.Text = string.format("%s\n%s [%dm]", player.Name, tipo, dist)
                                label.TextColor3 = corTime
                            end

                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "C3_Highlight"
                                hl.Parent = char
                                hl.FillTransparency = 0.6
                                hl.OutlineTransparency = 0.3
                            end
                            if hl then
                                hl.FillColor = corTime
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            end
                        else
                            if tag then tag:Destroy() end
                            if hl then hl:Destroy() end
                        end
                    end
                end
                task.wait(INTERVALO_LOOP)
            end
        end)
    end

    if player.Character then IniciarLoopESP(player.Character) end
    conexaoCharacter = player.CharacterAdded:Connect(IniciarLoopESP)
    
    conexaoTime = player:GetPropertyChangedSignal("Team"):Connect(function()
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local tag = head and head:FindFirstChild("C3_Tag")
        local label = tag and tag:FindFirstChild("Texto")
        local hl = char and char:FindFirstChild("C3_Highlight")
        
        if label or hl then
            local corTime, tipo = ObterEquipe(player)
            if label then
                label.TextColor3 = corTime
                label.Text = string.format("%s\n%s", player.Name, tipo)
            end
            if hl then hl.FillColor = corTime end
        end
    end)
    
    player.AncestryChanged:Connect(function()
        if not player.Parent then
            if conexaoCharacter then conexaoCharacter:Disconnect() end
            if conexaoTime then conexaoTime:Disconnect() end
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do MonitorarJogador(p) end
Players.PlayerAdded:Connect(MonitorarJogador)
