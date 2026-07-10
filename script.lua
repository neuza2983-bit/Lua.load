-- ====================================================================
-- 👁️ SCRIPT INDEPENDENTE: RASTREADOR DE JOGADORES (NOME, DISTÂNCIA E TIME)
-- ====================================================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Função para criar a interface acima da cabeça do jogador
local function CriarInterfaceRastreador(player, character)
    if player == LocalPlayer then return end
    
    local head = character:WaitForChild("Head", 5)
    if not head then return end
    
    -- Remove interface antiga se já existir
    if head:FindFirstChild("TrackerGui") then
        head.TrackerGui:Destroy()
    end
    
    -- Criar BillboardGui (Interface 3D no mundo)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TrackerGui"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0) -- Altura acima da cabeça
    billboard.AlwaysOnTop = true -- Permite ver através das paredes
    billboard.Parent = head
    
    -- Criar o texto informativo
    local texto = Instance.new("TextLabel")
    texto.Size = UDim2.new(1, 0, 1, 0)
    texto.BackgroundTransparency = 1
    texto.TextSize = 14
    texto.Font = Enum.Font.SourceSansBold
    texto.TextStrokeTransparency = 0 -- Borda preta para legibilidade
    texto.Parent = billboard
    
    -- Definir a cor com base no time do jogador
    if player.Team then
        texto.TextColor3 = player.TeamColor.Color
    else
        texto.TextColor3 = Color3.fromRGB(255, 255, 255) -- Branco se não tiver time
    end
    
    -- Loop para atualizar a distância em tempo real
    local conexao
    conexao = RunService.Heartbeat:Connect(function()
        if not character:Parent() or not character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            conexao:Disconnect()
            billboard:Destroy()
            return
        end
        
        local minhaPos = LocalPlayer.Character.HumanoidRootPart.Position
        local posAlvo = character.HumanoidRootPart.Position
        local distancia = math.floor((minhaPos - posAlvo).Magnitude)
        
        local nomeTime = player.Team and player.Team.Name or "Sem Time"
        
        -- Atualiza o texto na tela
        texto.Text = string.format("%s\nDistância: %d studs\n[%s]", player.Name, distancia, nomeTime)
    end)
end

-- Monitorar jogadores que entram no jogo ou mudam de personagem
local function MonitorarJogador(player)
    player.CharacterAdded:Connect(function(char)
        CriarInterfaceRastreador(player, char)
    end)
    if player.Character then
        CriarInterfaceRastreador(player, player.Character)
    end
end

-- Ativar para quem já está no servidor
for _, p in ipairs(Players:GetPlayers()) do
    MonitorarJogador(p)
end

-- Ativar para novos jogadores que entrarem
Players.PlayerAdded:Connect(MonitorarJogador)

print("💀 [Dragon Stalo] RASTREADOR DE JOGADORES ATIVADO COM SUCESSO!")
