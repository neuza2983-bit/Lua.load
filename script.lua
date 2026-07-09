-- ESP PREMIUM TOTALMENTE OTIMIZADO PARA REALME C3 (SEM TRAVAMENTO DE MOVIMENTO)
if not game:IsLoaded() then game.Loaded:Wait() end
if _G.RealmeC3_ESP then return end
_G.RealmeC3_ESP = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES DE PERFORMANCE PERFEITAS
local VELOCIDADE_DISCRETA = 20
local INTERVALO_LOOP = 0.5 -- Atualiza mais rápido sem dar lag
local DISTANCIA_MAXIMA_RENDERING = 250 -- Esconde tags longe para dar FPS

-- Aplica velocidade de forma leve e segura
local function AplicarVelocidade(char)
    if not char then return end
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = VELOCIDADE_DISCRETA
    end
end

if LocalPlayer.Character then AplicarVelocidade(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(AplicarVelocidade)

-- Detecta as equipes do Pinte ou Busque com precisão
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
    
    if tColor then
        return tColor, string.upper(team.Name or "JOGADOR")
    end
    
    return Color3.fromRGB(255, 255, 255), "JOGADOR"
end

-- Rastreamento ativo e leve de jogadores
local function MonitorarJogador(player)
    if player == LocalPlayer then return end

    local conexaoCharacter
    local conexaoTime

    local function IniciarLoopESP(char)
        if not char then return end
        
        local tagAntiga = char:FindFirstChild("C3_Tag")
        if tagAntiga then tagAntiga:Destroy() end

        task.spawn(function()
            while _G.RealmeC3_ESP and player and player.Parent and char and char.Parent do
                local meuChar = LocalPlayer.Character
                if meuChar then
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local meuRoot = meuChar:FindFirstChild("HumanoidRootPart")

                    local meuHumanoid = meuChar:FindFirstChildOfClass("Humanoid")
                    if meuHumanoid and meuHumanoid.WalkSpeed ~= VELOCIDADE_DISCRETA then
                        meuHumanoid.WalkSpeed = VELOCIDADE_DISCRETA
                    end

                    if head and root and meuRoot then
                        local dist = math.floor((meuRoot.Position - root.Position).Magnitude)
                        local tag = head:FindFirstChild("C3_Tag")

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
                        else
                            if tag then tag:Destroy() end
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
        
        if label then
            local corTime, tipo = ObterEquipe(player)
            label.TextColor3 = corTime
            label.Text = string.format("%s\n%s", player.Name, tipo)
        end
    end)
    
    player.AncestryChanged:Connect(function()
        if not player.Parent then
            if conexaoCharacter then conexaoCharacter:Disconnect() end
            if conexaoTime then conexaoTime:Disconnect() end
        end
    end)
end

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    if LocalPlayer.Character then AplicarVelocidade(LocalPlayer.Character) end
end)

for _, p in ipairs(Players:GetPlayers()) do MonitorarJogador(p) end
Players.PlayerAdded:Connect(MonitorarJogador)

print("[Sucesso] ESP Otimizado Atualizado!")
