local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Identifica o container seguro do executor
local parentTarget = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Remove versões antigas do painel se existirem
if parentTarget:FindFirstChild("Chiquinook9_UI") then
    parentTarget.Chiquinook9_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Chiquinook9_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentTarget

-- Botão de Abrir / Fechar
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 110, 0, 28)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.Text = "Chiquinook9"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 13
ToggleBtn.Parent = ScreenGui

-- Painel Principal Compacto
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 215)
MainFrame.Position = UDim2.new(0.02, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 24)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Chiquinook9 Painel"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = MainFrame

----------------------------------------------------
-- SISTEMA DE VELOCIDADE
----------------------------------------------------
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0.88, 0, 0, 28)
SpeedBox.Position = UDim2.new(0.06, 0, 0.15, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedBox.TextColor3 = Color3.fromRGB(0, 255, 150)
SpeedBox.PlaceholderText = "Velocidade (16 - 500)"
SpeedBox.Text = "Velocidade: 16"
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.TextSize = 12
SpeedBox.Parent = MainFrame

local targetSpeed = 16

SpeedBox.FocusLost:Connect(function()
    local num = tonumber(SpeedBox.Text:match("%d+"))
    if num then
        if num > 500 then num = 500 end
        if num < 0 then num = 16 end
        targetSpeed = num
        SpeedBox.Text = "Velocidade: " .. tostring(targetSpeed)
    else
        SpeedBox.Text = "Velocidade: " .. tostring(targetSpeed)
    end
end)

RunService.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.WalkSpeed ~= targetSpeed then
            LocalPlayer.Character.Humanoid.WalkSpeed = targetSpeed
        end
    end
end)

----------------------------------------------------
-- SISTEMA DE ESP
----------------------------------------------------
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.88, 0, 0, 28)
EspBtn.Position = UDim2.new(0.06, 0, 0.31, 0)
EspBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.Text = "ESP: Desativado"
EspBtn.Font = Enum.Font.SourceSansBold
EspBtn.TextSize = 12
EspBtn.Parent = MainFrame

local espActive = false

local function applyESP(character)
    if not character or character == LocalPlayer.Character then return end
    local existing = character:FindFirstChild("ChiquinookESP")
    if espActive then
        if not existing then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ChiquinookESP"
            highlight.FillColor = Color3.fromRGB(255, 30, 30)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.4
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = character
            highlight.Parent = character
        end
    else
        if existing then
            existing:Destroy()
        end
    end
end

EspBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    EspBtn.Text = espActive and "ESP: Ativado" or "ESP: Desativado"
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            applyESP(plr.Character)
        end
    end
end)

----------------------------------------------------
-- SISTEMA DE HITBOX UNIVERSAL (ARMAS, ESPADAS E ITENS)
----------------------------------------------------
local HitboxBtn = Instance.new("TextButton")
HitboxBtn.Size = UDim2.new(0.88, 0, 0, 28)
HitboxBtn.Position = UDim2.new(0.06, 0, 0.47, 0)
HitboxBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HitboxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxBtn.Text = "Hitbox Geral: Off"
HitboxBtn.Font = Enum.Font.SourceSansBold
HitboxBtn.TextSize = 12
HitboxBtn.Parent = MainFrame

local HitboxBox = Instance.new("TextBox")
HitboxBox.Size = UDim2.new(0.88, 0, 0, 28)
HitboxBox.Position = UDim2.new(0.06, 0, 0.63, 0)
HitboxBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HitboxBox.TextColor3 = Color3.fromRGB(0, 255, 150)
HitboxBox.PlaceholderText = "Tamanho (2-30)"
HitboxBox.Text = "Tamanho: 10"
HitboxBox.Font = Enum.Font.SourceSansBold
HitboxBox.TextSize = 12
HitboxBox.Parent = MainFrame

local hitboxActive = false
local hitboxSize = 10

local function resetHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            
            if head then
                head.Size = Vector3.new(2, 1, 1)
                head.Transparency = 0
                head.CanCollide = true
                head.CanTouch = true
                head.CanQuery = true
            end
            if hrp then
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.CanCollide = false
                hrp.CanTouch = true
                hrp.CanQuery = true
            end
        end
    end
end

HitboxBtn.MouseButton1Click:Connect(function()
    hitboxActive = not hitboxActive
    HitboxBtn.Text = hitboxActive and "Hitbox Geral: On" or "Hitbox Geral: Off"
    if not hitboxActive then
        resetHitboxes()
    end
end)

HitboxBox.FocusLost:Connect(function()
    local num = tonumber(HitboxBox.Text:match("%d+"))
    if num then
        if num > 30 then num = 30 end
        if num < 2 then num = 2 end
        hitboxSize = num
        HitboxBox.Text = "Tamanho: " .. tostring(hitboxSize)
    else
        HitboxBox.Text = "Tamanho: " .. tostring(hitboxSize)
    end
end)

-- Loop que atualiza Cabeça e Torso/HRP mantendo compatibilidade de tiros e toque
RunService.RenderStepped:Connect(function()
    if not hitboxActive then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            
            pcall(function()
                if head then
                    head.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    head.Transparency = 0.6
                    head.Color = Color3.fromRGB(255, 0, 0)
                    head.Material = Enum.Material.ForceField
                    head.CanCollide = false
                    head.CanTouch = true  -- Garante que armas/itens de toque (.Touched) funcionem
                    head.CanQuery = true  -- Garante que armas de tiro (Raycast) detectem a peça
                end
                if hrp then
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                    hrp.CanTouch = true
                    hrp.CanQuery = true
                end
            end)
        end
    end
end)

----------------------------------------------------
-- MONITORAMENTO DE JOGADORES
----------------------------------------------------
local function monitorPlayer(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if espActive then
            applyESP(char)
        end
    end)
end

Players.PlayerAdded:Connect(monitorPlayer)
for _, plr in pairs(Players:GetPlayers()) do
    monitorPlayer(plr)
end
