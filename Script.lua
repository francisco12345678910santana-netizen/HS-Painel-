-- [[ 🐰🕸️ Rabbit Menu - Universal FPS Master Edition ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CurrentCamera = workspace.CurrentCamera
local Stepped = RunService.Stepped

-- Reexecuta automaticamente o script ao mudar de servidor ou mapa em qualquer jogo
if queue_on_teleport then
   queue_on_teleport([[
      loadstring(game:HttpGet("https://raw.githubusercontent.com/francisco12345678910santana-netizen/HS-Painel-/main/Script.lua"))()
   ]])
end

-- Variáveis de Controlo Universal
local NoclipEnabled = false
local WalkSpeedValue = 16

local ESPBoxEnabled = true
local ESPSkeletonEnabled = true

local AimbotEnabled = false
local AutoShootEnabled = false
local FovVisible = true
local FovSize = 300
local Smoothness = 4
local TargetPartName = "Head"

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
local ESPSkeletons = {}

-- Janela Principal com a Key "Dono01" protegida e Salvamento Automático
local Window = Rayfield:CreateWindow({
   Name = "🐰 Rabbit Menu - Universal FPS 🎃",
   LoadingTitle = "A carregar painel universal...",
   LoadingSubtitle = "por Chiquinook9",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RabbitMenuConfigData",
      FileName = "UniversalSavedSettings"
   },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = true,
   KeySettings = {
      Title = "Painel Protegido 🐰",
      Subtitle = "Insira a sua chave de acesso",
      Note = "Insira a chave autorizada para continuar.",
      FileName = "RabbitKeyDono01Exclusive",
      SaveKey = true,
      Key = {"Dono01"}
   }
})

-- ==================== ABAS DO PAINEL ====================
local MovementTab = Window:CreateTab("⚡ Mouvement", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local CombatTab = Window:CreateTab("🎯 Combate", 4483362458)
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
   Range = {16, 500},
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

-- ==================== ABA 2: ESP UNIVERSAL ====================
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

ESPTab:CreateToggle({
   Name = "ESP Esqueleto (Skeleton)",
   CurrentValue = true,
   Flag = "ToggleESPSkeleton",
   Callback = function(Value) 
      ESPSkeletonEnabled = Value
      if not Value then
         for _, skel in pairs(ESPSkeletons) do
            for _, line in pairs(skel) do if line then line.Visible = false end end
         end
      end
   end,
})

-- ==================== ABA 3: COMBATE UNIVERSAL ====================
CombatTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "ToggleAimbot",
   Callback = function(Value) AimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Tiro Automático (Auto-Shoot)",
   CurrentValue = false,
   Flag = "ToggleAutoShoot",
   Callback = function(Value) AutoShootEnabled = Value end,
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

CombatTab:CreateDropdown({
   Name = "Partie visée",
   Options = {"Head", "UpperTorso", "Torso"},
   CurrentOption = "Head",
   Flag = "DropdownPart",
   Callback = function(Option) TargetPartName = Option[1] end,
})

CombatTab:CreateSection("🔧 Hitbox Universal")

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
ConfigTab:CreateLabel("🐰 Rabbit Menu - Universal FPS")
ConfigTab:CreateLabel("Criador: Chiquinook9")
ConfigTab:CreateButton({
   Name = "Guardar Configurações Manualmente",
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

-- Função universal para encontrar o jogador inimigo mais próximo no FOV (funciona em qualquer FPS)
local function GetClosestPlayerInFOV()
   local closestTarget = nil
   local shortestDistance = FovSize
   local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)

   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
         -- Validação universal: considera inimigo se for equipa diferente ou em jogos sem equipas (FFA)
         local isEnemy = (player.Team ~= LocalPlayer.Team) or (not LocalPlayer.Team) or (#Players:GetTeams() == 0)
         if isEnemy then
            local character = player.Character
            local targetPart = character:FindFirstChild(TargetPartName) or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Head")
            
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
   end
   return closestTarget
end

-- Noclip otimizado universal
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

-- Loop Principal Universal (Hitbox, Aimbot, Auto-Shoot e ESP)
RunService.RenderStepped:Connect(function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      if LocalPlayer.Character.Humanoid.WalkSpeed ~= WalkSpeedValue then
         LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
      end
   end

   -- 1. Hitbox Universal Adaptativa para qualquer FPS
   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character then
         local isEnemy = (player.Team ~= LocalPlayer.Team) or (not LocalPlayer.Team) or (#Players:GetTeams() == 0)
         local targetHitbox = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
         
         if targetHitbox then
            if HitboxEnabled and isEnemy then
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
   FOVDrawing.Visible = FovVisible and (AimbotEnabled or AutoShootEnabled)

   -- 3. Aimbot & Auto-Shoot Universal
   local target = GetClosestPlayerInFOV()
   
   if AimbotEnabled and target then
      local camPos = CurrentCamera.CFrame.Position
      local targetPos = target.Position
      local lookAtCFrame = CFrame.new(camPos, targetPos)
      
      if Smoothness <= 1 then
         CurrentCamera.CFrame = lookAtCFrame
      else
         CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(lookAtCFrame, 1 / Smoothness)
      end
   end

   if AutoShootEnabled and target then
      mouse1click()
      task.wait(0.05)
   end

   -- 4. ESP Box Universal
   if ESPBoxEnabled then
      for _, player in ipairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local char = player.Character
            local rootPart = char.HumanoidRootPart
            local dist = (CurrentCamera.CFrame.Position - rootPart.Position).Magnitude
            
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

   -- ESP Esqueleto Universal
   if ESPSkeletonEnabled then
      local function createLine()
         local line = Drawing.new("Line")
         line.Visible = false
         line.Color = Color3.fromRGB(100, 255, 100)
         line.Thickness = 1.5
         return line
      end

      for _, player in ipairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local char = player.Character
            
            if not ESPSkeletons[player] then
               ESPSkeletons[player] = { HeadToTorso = createLine() }
            end
            
            local skel = ESPSkeletons[player]
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            
            if head and torso then
               local headPos, hOn = CurrentCamera:WorldToViewportPoint(head.Position)
               local torsoPos, tOn = CurrentCamera:WorldToViewportPoint(torso.Position)
               
               if hOn and tOn then
                  skel.HeadToTorso.From = Vector2.new(headPos.X, headPos.Y)
                  skel.HeadToTorso.To = Vector2.new(torsoPos.X, torsoPos.Y)
                  skel.HeadToTorso.Visible = true
               else
                  skel.HeadToTorso.Visible = false
               end
            else
               if skel.HeadToTorso then skel.HeadToTorso.Visible = false end
            end
         else
            if ESPSkeletons[player] then
               for _, line in pairs(ESPSkeletons[player]) do line.Visible = false end
            end
         end
      end
   end
end)

Rayfield:Notify({
   Title = "Rabbit Menu Universal Ativo! 🐰🔥",
   Content = "Pronto para qualquer jogo FPS.",
   Duration = 5,
   Image = 4483362458,
})
