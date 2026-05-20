-- [[ klưn.z MASTER SYSTEM - 10% GRAPHICS & ANTI-TREE FIXED ]] --
local p = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local SG = game:GetService("StarterGui")
local TP = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

local playerGui = p:WaitForChild("PlayerGui", 10)
if not playerGui then return end

-- Tự động dọn bản cũ tránh lỗi đè GUI
local function clearOld(name) if playerGui:FindFirstChild(name) then playerGui[name]:Destroy() end end
clearOld("klunz_Status_Global"); clearOld("klunz_Melee_Mini"); clearOld("klunz_Master_V6"); clearOld("klunz_Aimbot_Killer")

-- [[ CONFIG TỔNG HỢP ]] --
local _S = (math.sqrt(10000)) 
local CONFIG1 = { EscapeHP = 100, SafeHP = 10, TargetHP = 30 }
local CONFIG2 = { SelectedTarget = nil }

-- KÍCH THƯỚC HITBOX
local _HITBOX_SIZE = 25 

-- Trạng thái mặc định
local activeESP = true 
local activeEscape1, systemLock1 = true, false
local activeCombat2 = false
local activeMelee = false 

-- ==========================================
-- ||      THANH STATUS                    ||
-- ==========================================
local statusGui = Instance.new("ScreenGui", playerGui); statusGui.Name = "klunz_Status_Global"; statusGui.ResetOnSpawn = false
local sFrame = Instance.new("Frame", statusGui); sFrame.Size, sFrame.Position = UDim2.new(0, 160, 0, 30), UDim2.new(0, 20, 0.25, 0)
sFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); sFrame.BackgroundTransparency = 0.5; Instance.new("UICorner", sFrame)
local sInfo = Instance.new("TextLabel", sFrame); sInfo.Size, sInfo.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
sInfo.Text, sInfo.TextColor3, sInfo.Font, sInfo.TextSize = "STATUS: IDLE", Color3.fromRGB(0, 255, 150), Enum.Font.Code, 11

-- ==========================================
-- ||      MENU 3 (MELEE RAGE)             ||
-- ==========================================
local gui3 = Instance.new("ScreenGui", playerGui); gui3.Name = "klunz_Melee_Mini"; gui3.ResetOnSpawn = false
local frame3 = Instance.new("Frame", gui3); frame3.Size, frame3.Position = UDim2.new(0, 130, 0, 55), UDim2.new(1, -140, 0.15, 0)
frame3.BackgroundColor3 = Color3.fromRGB(20, 10, 10); frame3.Active, frame3.Draggable = true, true; Instance.new("UICorner", frame3)
local title3 = Instance.new("TextLabel", frame3); title3.Size, title3.Text = UDim2.new(1, 0, 0, 18), "🔥 MELEE RAGE"
title3.TextColor3, title3.BackgroundTransparency, title3.Font, title3.TextSize = Color3.fromRGB(255, 50, 50), 1, Enum.Font.Code, 8
local meleeBtn = Instance.new("TextButton", frame3); meleeBtn.Size, meleeBtn.Position = UDim2.new(0.9, 0, 0, 28), UDim2.new(0.05, 0, 0.4, 0)
meleeBtn.Text = "RAGE: OFF"; meleeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); meleeBtn.TextColor3, meleeBtn.Font, meleeBtn.TextSize = Color3.new(1, 1, 1), Enum.Font.Code, 9; Instance.new("UICorner", meleeBtn)

meleeBtn.MouseButton1Click:Connect(function()
    if activeCombat2 then 
        SG:SetCore("SendNotification", {Title = "CẢNH BÁO", Text = "Tắt Target Lock trước khi bật Rage!", Duration = 2})
        return 
    end
    activeMelee = not activeMelee
    meleeBtn.Text = activeMelee and "RAGE: ON 🔥" or "RAGE: OFF"
    meleeBtn.BackgroundColor3 = activeMelee and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 40, 40)
    sInfo.TextColor3 = activeMelee and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 150)
end)

-- ==========================================
-- ||      MENU 1 (HỆ THỐNG CHÍNH)         ||
-- ==========================================
local gui1 = Instance.new("ScreenGui", playerGui); gui1.Name = "klunz_Master_V6"; gui1.ResetOnSpawn = false 
local frame1 = Instance.new("Frame", gui1); frame1.Size, frame1.Position = UDim2.new(0,210,0,400), UDim2.new(0.1,0,0.3,0)
frame1.BackgroundColor3 = Color3.fromRGB(10,10,10); frame1.Active, frame1.Draggable = true, true; Instance.new("UICorner", frame1)
local title1 = Instance.new("TextLabel", frame1); title1.Size, title1.Text = UDim2.new(1, 0, 0, 35), "★ klưn.z MASTER ★"
title1.TextColor3, title1.BackgroundTransparency, title1.Font, title1.TextSize = Color3.fromRGB(0, 255, 150), 1, Enum.Font.Code, 15

local toggleBtn1 = Instance.new("TextButton", frame1); toggleBtn1.Size, toggleBtn1.Position = UDim2.new(0, 25, 0, 25), UDim2.new(1, -30, 0, 5)
toggleBtn1.Text = "-"; toggleBtn1.BackgroundColor3 = Color3.fromRGB(40,40,40); toggleBtn1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", toggleBtn1)

local content1 = Instance.new("Frame", frame1); content1.Size, content1.Position, content1.BackgroundTransparency = UDim2.new(1,0,0.9,0), UDim2.new(0,0,0.1,0), 1
local layout1 = Instance.new("UIListLayout", content1); layout1.HorizontalAlignment, layout1.Padding = Enum.HorizontalAlignment.Center, UDim.new(0,6)

local function createBtn1(text, color, func)
    local b = Instance.new("TextButton", content1); b.Size = UDim2.new(0.9,0,0,32)
    b.Text, b.BackgroundColor3, b.TextColor3, b.Font, b.TextSize = text, color, Color3.new(1,1,1), Enum.Font.Code, 10
    Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() func(b) end); return b
end

local function createInput1(placeholder, defaultVal, callback)
    local t = Instance.new("TextBox", content1); t.Size = UDim2.new(0.9,0,0,32)
    t.PlaceholderText = placeholder; t.Text = placeholder .. ": " .. defaultVal
    t.BackgroundColor3 = Color3.fromRGB(30,30,30); t.TextColor3, t.Font, t.TextSize = Color3.new(1,1,1), Enum.Font.Code, 10
    Instance.new("UICorner", t); t.FocusLost:Connect(function()
        local val = tonumber(t.Text:match("%d+")) or tonumber(t.Text)
        if val then callback(val); t.Text = placeholder .. ": " .. val else t.Text = placeholder .. ": " .. defaultVal end
    end)
end

createBtn1("⭐ SUPER HOP", Color3.fromRGB(0, 120, 50), function()
    local success, res = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100") end)
    if success then
        local data = Http:JSONDecode(res)
        for _, s in pairs(data.data) do
            if s.id ~= game.JobId and s.playing <= (s.maxPlayers - 2) then TP:TeleportToPlaceInstance(game.PlaceId, s.id, p) return end
        end
    end
end)

-- NÚT GIẢM HIỆU ỨNG + DIỆT CÂY (SIÊU MƯỢT, ANTI-LAG)
createBtn1("⚡ 10% GRAPHICS + XOÁ CÂY", Color3.fromRGB(130, 50, 0), function()
    task.spawn(function()
        -- 1. Hạ cấu hình Lighting về mức thấp nhất
        local L = game:GetService("Lighting")
        L.GlobalShadows = false
        L.Brightness = 0
        L.FogEnd = 9e9
        for _, v in pairs(L:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then 
                v:Destroy() 
            end
        end
        
        -- 2. Quét Workspace để hạ cấu hình và DIỆT CÂY CỐI
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            -- Nhận diện và xóa cây cối (Tên có chứa Tree, Leaves, Leaf, Bush)
            local nameLower = string.lower(v.Name)
            if string.find(nameLower, "tree") or string.find(nameLower, "leaves") or string.find(nameLower, "leaf") or string.find(nameLower, "bush") then
                v:Destroy()
            -- Tối ưu các Part thông thường còn lại
            elseif v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v:Destroy()
            end
            
            count = count + 1
            -- Chia nhỏ chu kỳ quét để bảo vệ Engine di chuyển (không bị nghẽn phím)
            if count % 30 == 0 then 
                task.wait(0.01) 
            end
        end
        SG:SetCore("SendNotification", { Title = "klưn.z SYSTEM", Text = "Đã dọn sạch cây & tối ưu 10%!", Duration = 2 })
    end)
end)

local espBtn = createBtn1("ESP LOW HP: ON", Color3.fromRGB(200, 0, 0), function(b)
    activeESP = not activeESP
    b.Text = activeESP and "ESP LOW HP: ON" or "ESP LOW HP: OFF"
    b.BackgroundColor3 = activeESP and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80,80,80)
end)

createBtn1("AUTO ESCAPE: ON", Color3.fromRGB(0,150,255), function(b)
    activeEscape1 = not activeEscape1
    b.Text = activeEscape1 and "AUTO ESCAPE: ON" or "AUTO ESCAPE: OFF"
    b.BackgroundColor3 = activeEscape1 and Color3.fromRGB(0,150,255) or Color3.fromRGB(80,80,80)
end)

createInput1("SET TARGET HP (RAGE)", 30, function(v) CONFIG1.TargetHP = v end)
createInput1("SET ESCAPE HP", 25, function(v) CONFIG1.EscapeHP = v end)

toggleBtn1.MouseButton1Click:Connect(function()
    local isCol = (toggleBtn1.Text == "-")
    frame1:TweenSize(isCol and UDim2.new(0,210,0,35) or UDim2.new(0,210,0,400), "Out", "Quart", 0.3, true)
    content1.Visible = not isCol; toggleBtn1.Text = isCol and "+" or "-"
end)

-- ==========================================
-- ||      MENU 2 (TARGET LOCK)            ||
-- ==========================================
local gui2 = Instance.new("ScreenGui", playerGui); gui2.Name = "klunz_Aimbot_Killer"; gui2.ResetOnSpawn = false
local main2 = Instance.new("Frame", gui2); main2.Size, main2.Position = UDim2.new(0, 180, 0, 110), UDim2.new(1, -190, 0.3, 0)
main2.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main2.Active, main2.Draggable = true, true; Instance.new("UICorner", main2)

local topBar2 = Instance.new("Frame", main2); topBar2.Size, topBar2.BackgroundColor3 = UDim2.new(1, 0, 0, 30), Color3.fromRGB(25, 25, 25); Instance.new("UICorner", topBar2)
local title2 = Instance.new("TextLabel", topBar2); title2.Size, title2.Position = UDim2.new(1, -70, 1, 0), UDim2.new(0, 5, 0, 0)
title2.Text = "★ TARGET LOCK ★"; title2.TextColor3 = Color3.fromRGB(255, 60, 60); title2.Font, title2.TextSize, title2.BackgroundTransparency = Enum.Font.Code, 9, 1

local toggleBtn2 = Instance.new("TextButton", topBar2); toggleBtn2.Size, toggleBtn2.Position = UDim2.new(0, 22, 0, 22), UDim2.new(1, -52, 0, 4)
toggleBtn2.Text, toggleBtn2.BackgroundColor3 = "-", Color3.fromRGB(45, 45, 45); toggleBtn2.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", toggleBtn2)

local listToggle2 = Instance.new("TextButton", topBar2); listToggle2.Size, listToggle2.Position = UDim2.new(0, 22, 0, 22), UDim2.new(1, -26, 0, 4)
listToggle2.Text, listToggle2.BackgroundColor3 = ">", Color3.fromRGB(45, 45, 45); listToggle2.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", listToggle2)

local content2 = Instance.new("Frame", main2); content2.Size, content2.Position, content2.BackgroundTransparency = UDim2.new(1, 0, 1, -30), UDim2.new(0, 0, 0, 30), 1
local combatBtn2 = Instance.new("TextButton", content2); combatBtn2.Size, combatBtn2.Position = UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0.3, 0)
combatBtn2.Text = "AIM & KILL: OFF"; combatBtn2.BackgroundColor3 = Color3.fromRGB(35, 35, 35); combatBtn2.TextColor3, combatBtn2.Font, combatBtn2.TextSize = Color3.new(1, 1, 1), Enum.Font.Code, 10; Instance.new("UICorner", combatBtn2)

local listFrame2 = Instance.new("Frame", main2); listFrame2.Size, listFrame2.Position = UDim2.new(0, 150, 0, 200), UDim2.new(0, -155, 0, 0); listFrame2.BackgroundColor3 = Color3.fromRGB(10, 10, 10); listFrame2.Visible = false; Instance.new("UICorner", listFrame2)
local scroll2 = Instance.new("ScrollingFrame", listFrame2); scroll2.Size, scroll2.Position = UDim2.new(0.9, 0, 0.9, 0), UDim2.new(0.05, 0, 0.05, 0); scroll2.BackgroundColor3, scroll2.ScrollBarThickness = Color3.fromRGB(15, 15, 15), 1; Instance.new("UIListLayout", scroll2).Padding = UDim.new(0, 2)

local function updateList2()
    for _, v in pairs(scroll2:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, pl in pairs(game.Players:GetPlayers()) do
        if pl ~= p then
            local b = Instance.new("TextButton", scroll2); b.Size = UDim2.new(1, -5, 0, 22)
            b.Text = " " .. pl.Name; b.BackgroundColor3 = (CONFIG2.SelectedTarget == pl) and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30); b.TextColor3, b.Font, b.TextSize = Color3.new(1,1,1), Enum.Font.Code, 8; b.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function() CONFIG2.SelectedTarget = (CONFIG2.SelectedTarget == pl) and nil or pl; updateList2() end)
        end
    end
end

listToggle2.MouseButton1Click:Connect(function() listFrame2.Visible = not listFrame2.Visible; if listFrame2.Visible then updateList2() end end)
toggleBtn2.MouseButton1Click:Connect(function()
    local isCol = (toggleBtn2.Text == "-")
    main2:TweenSize(isCol and UDim2.new(0,180,0,30) or UDim2.new(0,180,0,110), "Out", "Quart", 0.3, true)
    content2.Visible = not isCol; toggleBtn2.Text = isCol and "+" or "-"
end)

combatBtn2.MouseButton1Click:Connect(function()
    activeCombat2 = not activeCombat2
    if activeCombat2 then activeMelee = false; meleeBtn.Text = "RAGE: OFF"; meleeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
    combatBtn2.Text = activeCombat2 and "AIM & KILL: ON" or "AIM & KILL: OFF"
    combatBtn2.BackgroundColor3 = activeCombat2 and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(35, 35, 35)
end)

-- ==========================================
-- || CORE LOGIC (ESP, COMBAT & HITBOX)    ||
-- ==========================================
RS.Heartbeat:Connect(function(dt)
    local char = p.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not (root and hum) then return end

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= p and v.Character then
            if v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                local eHum = v.Character:FindFirstChild("Humanoid")
                local bill = head:FindFirstChild("klunz_ESP")
                
                if activeESP and eHum then
                    local hpP = (eHum.Health / eHum.MaxHealth) * 100
                    if hpP <= 30 and hpP > 0 then
                        if not bill then
                            bill = Instance.new("BillboardGui", head); bill.Name = "klunz_ESP"; bill.Size = UDim2.new(0, 80, 0, 40); bill.AlwaysOnTop = true; bill.ExtentsOffset = Vector3.new(0, 3, 0)
                            local t = Instance.new("TextLabel", bill); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.TextColor3 = Color3.fromRGB(255, 50, 50); t.Font = Enum.Font.Code; t.TextSize = 10; t.TextStrokeTransparency = 0
                        end
                        bill.TextLabel.Text = v.Name .. "\n[" .. math.floor(hpP) .. "%]"
                    elseif bill then bill:Destroy() end
                elseif bill then bill:Destroy() end
            end

            if v.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = v.Character.HumanoidRootPart
                if activeCombat2 or activeMelee then
                    targetRoot.Size = Vector3.new(_HITBOX_SIZE, _HITBOX_SIZE, _HITBOX_SIZE)
                    targetRoot.Transparency = 0.8
                    targetRoot.BrickColor = BrickColor.new("Bright red")
                    targetRoot.Material = Enum.Material.ForceField
                    targetRoot.CanCollide = false
                else
                    targetRoot.Size = Vector3.new(2, 2, 1)
                    targetRoot.Transparency = 1
                end
            end
        end
    end

    local myHP = (hum.Health / hum.MaxHealth) * 100
    if activeEscape1 and not activeMelee and myHP <= CONFIG1.EscapeHP then systemLock1 = true 
    elseif myHP >= CONFIG1.SafeHP then systemLock1 = false end
    
    if systemLock1 then root.CFrame = CFrame.new(root.Position.X, 1200, root.Position.Z); root.Velocity = Vector3.zero; return end

    local target = nil
    if activeCombat2 and CONFIG2.SelectedTarget and CONFIG2.SelectedTarget.Character then
        local tHum = CONFIG2.SelectedTarget.Character:FindFirstChild("Humanoid")
        if tHum and tHum.Health > 0 then target = CONFIG2.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") end
    elseif activeMelee then
        local low = 101
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= p and v.Character and v.Character:FindFirstChild("Humanoid") then
                local eh = v.Character.Humanoid; local ep = (eh.Health/eh.MaxHealth)*100
                if ep > 0 and ep <= CONFIG1.TargetHP and ep < low then low = ep; target = v.Character:FindFirstChild("HumanoidRootPart") end
            end
        end
    end

    if target then
        root.CFrame = target.CFrame * CFrame.new(0, 0, activeMelee and 1.6 or 2.5)
        local lookPos = target.Position
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(lookPos.X, root.Position.Y, lookPos.Z))
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, lookPos)
        sInfo.Text = "TARGET: " .. target.Parent.Name
    else
        if hum.MoveDirection.Magnitude > 0 then 
            root.CFrame = root.CFrame + (hum.MoveDirection * (_S * dt)) 
        end
        sInfo.Text = activeMelee and "RAGE: SCANNING..." or "STATUS: IDLE"
    end
end)

-- Vòng lặp tự động đánh
task.spawn(function()
    while true do
        if (activeCombat2 or activeMelee) and not systemLock1 then
            local ev = p.Character and p.Character:FindFirstChild("Communicate")
            if ev then for i = 1, 3 do ev:FireServer({[1] = i}) end end
        end
        task.wait(activeMelee and 0.08 or 0.12)
    end
end)

SG:SetCore("SendNotification", { Title = "klưn.z SYSTEM", Text = "ANTI-TREE ACTIVE!", Duration = 3 })
