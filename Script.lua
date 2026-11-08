-- Carrega a biblioteca do Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variáveis de Controlo
local NoclipEnabled = false
local AntiCoinEnabled = false
local WalkSpeedValue = 16
local MaxDistance = 1000

local ESPBoxEnabled = true
local ESPSkeletonEnabled = true

local AimbotEnabled = false
local AimOnClick = true
local FovVisible = true
local FovSize = 140
local Smoothness = 4
local TargetPartName = "Head"

local HitboxEnabled = false
local HitboxSize = 5

local CurrentCamera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stepped = RunService.Stepped

-- Círculo visual de FOV
local FOVDrawing = Drawing.new("Circle")
FOVDrawing.Visible = true
FOVDrawing.Transparency = 0.7
FOVDrawing.Color = Color3.fromRGB(255, 100, 100)
FOVDrawing.Thickness = 1.5
FOVDrawing.NumSides = 60
FOVDrawing.Filled = false

local ESPBoxes = {}
local ESPSkeletons = {}

-- Cria a Janela Principal com Temática Halloween 🎃🕸️
local Window = Rayfield:CreateWindow({
   Name = "🎃🕸️ Halloween Hub - Pro Edition",
   LoadingTitle = "A carregar módulos...",
   LoadingSubtitle = "por Chiquinook9",
   ConfigurationSaving = { Enabled = false, FolderName = "HalloweenHub", FileName = "Config" },
   Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
   KeySystem = true,
   KeySettings = {
      Title = "Painel Protegido 🎃",
      Subtitle = "Insira a chave de acesso",
      Note = "Chave padrão: KEY001",
      FileName = "HalloweenKey",
      SaveKey = true,
      Key = {"KEY001"}
   }
})

-- ==================== ABAS DO PAINEL ====================
local MovementTab = Window:CreateTab("⚡ Movimento", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP & Visual", 4483362458)
local CombatTab = Window:CreateTab("🎯 Combate & Hitbox", 4483362458)

-- ==================== ABA 1: MOVIMENTO ====================
MovementTab:CreateToggle({
   Name = "Noclip (Atravessar lados sem cair no void)",
   CurrentValue = false,
   Flag = "ToggleNoclip",
   Callback = function(Value) NoclipEnabled = Value end,
})

MovementTab:CreateToggle({
   Name = "Anti-Moeda (Não apanhar moedas)",
   CurrentValue = false,
   Flag = "ToggleAntiCoin",
   Callback = function(Value) AntiCoinEnabled = Value end,
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

-- ==================== ABA 2: ESP (VISUAL COM LIMITE DE DISTÂNCIA) ====================
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

ESPTab:CreateSlider({
   Name = "Limite de Distância do ESP",
   Range = {100, 5000},
   Increment = 100,
   Suffix = " studs",
   CurrentValue = 1000,
   Flag = "SliderDist",
   Callback = function(Value) MaxDistance = Value end,
})

-- ==================== ABA 3: COMBATE (AIMBOT & HITBOX) ====================
CombatTab:CreateToggle({
   Name = "Aimbot (Mover câmara)",
   CurrentValue = false,
   Flag = "ToggleAimbot",
   Callback = function(Value) AimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Aimbot apenas Botão Direito",
   CurrentValue = true,
   Flag = "ToggleAimOnClick",
   Callback = function(Value) AimOnClick = Value end,
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
   Name = "FOV (Tamanho)",
   Range = {50, 300},
   Increment = 5,
   Suffix = "px",
   CurrentValue = 140,
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
   Name = "Parte visada (Alvo)",
   Options = {"Head", "UpperTorso", "Torso"},
   CurrentOption = "Head",
   Flag = "DropdownPart",
   Callback = function(Option) TargetPartName = Option[1] end,
})

CombatTab:CreateSection("🔧 Hitbox Extender (Longo Alcance)")

CombatTab:CreateToggle({
   Name = "Ativar Hitbox Expandida",
   CurrentValue = false,
   Flag = "ToggleHitbox",
   Callback = function(Value) HitboxEnabled = Value end,
})

CombatTab:CreateSlider({
   Name = "Tamanho da Hitbox",
   Range = {2, 25},
   Increment = 1,
   Suffix = " size",
   CurrentValue = 5,
   Flag = "SliderHitboxSize",
   Callback = function(Value) HitboxSize = Value end,
})

-- Função para encontrar o alvo no FOV
local function GetClosestPlayerInFOV()
   local closestTarget = nil
   local shortestDistance = FovSize
   local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)

   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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
   return closestTarget
end

-- Noclip otimizado: atravessa lados/frente sem cair no void
Stepped:Connect(function()
   if LocalPlayer.Character then
      local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      
      if NoclipEnabled then
         for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = false
            end
         end
         
         -- Evita queda no void mantendo a plataforma estável se estiver a descer demasiado
         if rootPart and rootPart.Position.Y < -50 then
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 10, 0)
         end
      end

      -- Lógica Anti-Moeda (ignora toques em itens de moeda/gold)
      if AntiCoinEnabled then
         for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("moeda") or obj.Name:lower():find("gold") or obj.Name:lower():find("cash")) then
               obj.CanTouch = false
            end
         end
      end
   end
end)

-- Loop Principal de Processamento
RunService.RenderStepped:Connect(function()
   -- 1. Velocidade (WalkSpeed)
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      if LocalPlayer.Character.Humanoid.WalkSpeed ~= WalkSpeedValue then
         LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
      end
   end

   -- 2. Hitbox Extender
   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character then
         local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
         if rootPart then
            if HitboxEnabled then
               rootPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
               rootPart.Transparency = 0.7
               rootPart.CanCollide = false
            else
               rootPart.Size = Vector3.new(2, 2, 1)
               rootPart.Transparency = 1
            end
         end
      end
   end

   -- 3. FOV e Aimbot
   local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
   FOVDrawing.Position = screenCenter
   FOVDrawing.Radius = FovSize
   FOVDrawing.Visible = FovVisible and AimbotEnabled

   if AimbotEnabled then
      local isMouseDown = not AimOnClick or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
      if isMouseDown then
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
   end

   -- 4. ESP com Limite de Distância
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
            
            if onScreen and dist <= MaxDistance then
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

   -- ESP Esqueleto com Limite
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
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local dist = rootPart and (CurrentCamera.CFrame.Position - rootPart.Position).Magnitude or 9999
            
            if not ESPSkeletons[player] then
               ESPSkeletons[player] = { HeadToTorso = createLine() }
            end
            
            local skel = ESPSkeletons[player]
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            
            if head and torso and dist <= MaxDistance then
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
   Title = "Halloween Hub Carregado! 🎃🕸️",
   Content = "Noclip lateral ajustado sem queda no void.",
   Duration = 5,
   Image = 4483362458,
})
