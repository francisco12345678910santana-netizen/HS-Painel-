-- [[ 🎃🔪 Rabbit Menu - Duelos Master Edition ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CurrentCamera = workspace.CurrentCamera
local Stepped = RunService.Stepped

-- Variáveis de Controlo
local NoclipEnabled = false
local WalkSpeedValue = 16

local ESPBoxEnabled = true
local AimbotEnabled = false
local FovVisible = true
local FovSize = 300
local Smoothness = 4

local HitboxEnabled = false
local HitboxSize = 4

-- Círculo visual de FOV
local FOVDrawing = Drawing.new("Circle")
FOVDrawing.Visible = true
FOVDrawing.Transparency = 0.7
FOVDrawing.Color = Color3.fromRGB(255, 0, 221)
FOVDrawing.Thickness = 1.5
FOVDrawing.NumSides = 60
FOVDrawing.Filled = false

local ESPBoxes = {}

-- Janela Principal com Salvamento de Configurações e Key "Dono01"
local Window = Rayfield:CreateWindow({
   Name = "🐰 Rabbit Menu - Duelos Edition 🔪🎃",
   LoadingTitle = "A carregar painel...",
   LoadingSubtitle = "por Chiquinook9",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RabbitMenuDuelos",
      FileName = "DuelosSettings"
   },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = true,
   KeySettings = {
      Title = "Painel Protegido 🐰",
      Subtitle = "Insira a sua chave de acesso",
      Note = "Insira a chave autorizada para continuar.",
      FileName = "RabbitKeyDono01Duelos",
      SaveKey = true,
      Key = {"Dono01"}
   }
})

-- ==================== ABAS DO PAINEL ====================
local MovementTab = Window:CreateTab("⚡ Mouvement", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local CombatTab = Window:CreateTab("🎯 Combate & Hitbox", 4483362458)
local ConfigTab = Window:CreateTab("⚙️ Configurações", 4483362458)

-- ==================== ABA 1: MOUVEMENT ====================
MovementTab:CreateToggle({
   Name = "Noclip (Atravessar paredes)",
   CurrentValue = false,
   Flag = "ToggleNoclip",
   Callback = function(Value) NoclipEnabled = Value end,
})

MovementTab:CreateSlider({
   Name = "Velocidade (WalkSpeed)",
   Range = {16, 300},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 16,
   Flag = "SliderSpeed",
   Callback = function(Value) 
      WalkSpeedValue = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

-- ==================== ABA 2: ESP ====================
ESPTab:CreateToggle({
   Name = "ESP Box (Caixas)",
   CurrentValue = true,
   Flag = "ToggleESPBox",
   Callback = function(Value) 
      ESPBoxEnabled = Value 
      if not Value then
         for _, box in pairs(ESPBoxes) do if box then box.Visible = false end end
      end
   end,
})

-- ==================== ABA 3: COMBATE & HITBOX ====================
CombatTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "ToggleAimbot",
   Callback = function(Value) AimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Cercle FOV visible",
   CurrentValue = true,
   Flag = "ToggleFovVisible",
   Callback = function(Value) 
      FovVisible = Value
      FOVDrawing.Visible = Value
   end,
})

CombatTab:CreateSlider({
   Name = "FOV",
   Range = {50, 600},
   Increment = 10,
   Suffix = " px",
   CurrentValue = 300,
   Flag = "SliderFOV",
   Callback = function(Value) FovSize = Value end,
})

CombatTab:CreateSlider({
   Name = "Fluidité (Suavização)",
   Range = {1, 20},
   Increment = 1,
   Suffix = "",
   CurrentValue = 4,
   Flag = "SliderSmooth",
   Callback = function(Value) Smoothness = Value end,
})

CombatTab:CreateSection("🔧 Hitbox Extender")

CombatTab:CreateToggle({
   Name = "Ativar Hitbox Expandida",
   CurrentValue = false,
   Flag = "ToggleHitbox",
   Callback = function(Value) HitboxEnabled = Value end,
})

CombatTab:CreateSlider({
   Name = "Tamanho da Hitbox",
   Range = {2, 12},
   Increment = 1,
   Suffix = " size",
   CurrentValue = 4,
   Flag = "SliderHitboxSize",
   Callback = function(Value) HitboxSize = Value end,
})

-- ==================== ABA 4: CONFIGURAÇÕES ====================
ConfigTab:CreateLabel("🐰 Rabbit Menu - Salvamento de Configurações")
ConfigTab:CreateLabel("Criador: Chiquinook9")
ConfigTab:CreateButton({
   Name = "Guardar Configurações Agora",
   Callback = function()
      Rayfield:SaveConfiguration()
      Rayfield:Notify({ Title = "Sucesso", Content = "As tuas preferências foram guardadas!", Duration = 3 })
   end,
})

ConfigTab:CreateButton({
   Name = "Recarregar Painel",
   Callback = function()
      Rayfield:Destroy()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/francisco12345678910santana-netizen/HS-Painel-/main/Script.lua"))()
   end,
})

-- Função para encontrar o alvo mais próximo no FOV
local function GetClosestPlayerInFOV()
   local closestTarget = nil
   local shortestDistance = FovSize
   local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)

   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
         -- Em jogos de duelo/arena, qualquer outro jogador é um alvo válido
         local character = player.Character
         local targetPart = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso")
         
         if targetPart then
            local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
               local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
               if distance < shortestDistance then
                  shortestDistance = distance
                  closestTarget = targetPart
               end
            end
         end
      end
   end
   return closestTarget
end

-- Noclip
Stepped:Connect(function()
   if LocalPlayer.Character and NoclipEnabled then
      local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
      if rootPart and rootPart.Position.Y < -50 then
         rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 10, 0)
      end
   end
end)

-- Loop Principal
RunService.RenderStepped:Connect(function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      if LocalPlayer.Character.Humanoid.WalkSpeed ~= WalkSpeedValue then
         LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
      end
   end

   -- 1. Hitbox Extender Funcional
   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character then
         local targetHitbox = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
         if targetHitbox then
            if HitboxEnabled then
               targetHitbox.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
               targetHitbox.Transparency = 0.7
               targetHitbox.CanCollide = false
            else
               targetHitbox.Size = Vector3.new(2, 1, 1)
               targetHitbox.Transparency = 1
            end
         end
      end
   end

   -- 2. FOV Visual
   local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
   FOVDrawing.Position = screenCenter
   FOVDrawing.Radius = FovSize
   FOVDrawing.Visible = FovVisible and AimbotEnabled

   -- 3. Aimbot
   if AimbotEnabled then
      local target = GetClosestPlayerInFOV()
      if target then
         local camPos = CurrentCamera.CFrame.Position
         local targetPos = target.Position
         local lookAtCFrame = CFrame.new(camPos, targetPos)
         
         if Smoothness <= 1 then
             CurrentCamera.CFrame = lookAtCFrame
         else
             CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(lookAtCFrame, 1 / Smoothness)
         end
      end
   end

   -- 4. ESP Box
   if ESPBoxEnabled then
      for _, player in ipairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local char = player.Character
            local rootPart = char.HumanoidRootPart
            
            if not ESPBoxes[player] then
               local box = Drawing.new("Square")
               box.Visible = false
               box.Color = Color3.fromRGB(255, 100, 100)
               box.Thickness = 1.5
               box.Filled = false
               ESPBoxes[player] = box
            end
            
            local box = ESPBoxes[player]
            local vector, onScreen = CurrentCamera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
               box.Size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
               box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
               box.Visible = true
            else
               box.Visible = false
            end
         else
            if ESPBoxes[player] then ESPBoxes[player].Visible = false end
         end
      end
   end
end)

Rayfield:Notify({
   Title = "Rabbit Menu Ativo! 🐰🔥",
   Content = "Hitbox e painel configurados com sucesso.",
   Duration = 5,
   Image = 4483362458,
})
