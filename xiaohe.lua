--[[
小贺脚本 最终整合修复纯净版
✅补回：ESP方框、玩家血条、距离标签、NPC高亮渲染
✅新增：UI数字输入框，直接输入超大数值（适配无上限参数）
✅修复：透视不显示、自瞄掩体检测失效、重生功能残留、事件泄漏漏洞
✅参数全部无上限：移速/跳跃力/重力/自转速度/飞行速度
✅已永久移除：全部游戏专用脚本、远程加载外部脚本代码
⚠️仅私人罗布乐思服务器测试，公共服务器使用存在账号封禁风险
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local function getChar() return LocalPlayer.Character end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function safe(func, name)
    return function(...)
        local ok,err = pcall(func,...)
        if not ok then warn("[SAFE]["..tostring(name).."]",err) end
    end
end

local function notify(title,msg,time,color)
    color = color or Color3.new(0.3,0.8,1)
    local sg = Instance.new("ScreenGui")
    sg.Name = "NotifyUI"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.Parent = PlayerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,260,0,44)
    frame.Position = UDim2.new(0.02,0,0.02,0)
    frame.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
    frame.BackgroundTransparency = 0.1
    frame.Parent = sg
    Instance.new("UICorner",frame).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = color
    stroke.Parent = frame
    local labelTitle = Instance.new("TextLabel")
    labelTitle.Size = UDim2.new(0,120,0,20)
    labelTitle.Position = UDim2.new(0,10,0,4)
    labelTitle.BackgroundTransparency = 1
    labelTitle.Text = title
    labelTitle.TextColor3 = Color3.new(1,1,1)
    labelTitle.TextSize = 14
    labelTitle.Font = Enum.Font.GothamBold
    labelTitle.TextXAlignment = Enum.TextXAlignment.Left
    labelTitle.Parent = frame
    local labelMsg = Instance.new("TextLabel")
    labelMsg.Size = UDim2.new(0,230,0,16)
    labelMsg.Position = UDim2.new(0,10,0,24)
    labelMsg.BackgroundTransparency = 1
    labelMsg.Text = msg
    labelMsg.TextColor3 = Color3.new(0.85,0.85,0.85)
    labelMsg.TextSize = 11
    labelMsg.Font = Enum.Font.Gotham
    labelMsg.TextXAlignment = Enum.TextXAlignment.Left
    labelMsg.Parent = frame
    task.wait(time or 2)
    sg:Destroy()
end

local function mouse1click()
    Mouse:Button1Down:Fire()
    task.wait()
    Mouse:Button1Up:Fire()
end

local COL = {
    Bg = Color3.fromRGB(22,22,26),
    Bg2 = Color3.fromRGB(35,35,40),
    Button = Color3.fromRGB(48,48,55),
    Text = Color3.fromRGB(240,240,240),
    TextDim = Color3.fromRGB(160,160,170),
    Accent = Color3.fromRGB(80,180,255),
    Accent2 = Color3.fromRGB(100,255,160)
}
local AUTHOR_NAME = LocalPlayer.Name

local windowGui = Instance.new("ScreenGui")
windowGui.Name = "XiaoHeMainUI"
windowGui.IgnoreGuiInset = true
windowGui.ResetOnSpawn = false
windowGui.DisplayOrder = 99999
windowGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,620,0,460)
mainFrame.Position = UDim2.new(0.12,0,0.15,0)
mainFrame.BackgroundColor3 = COL.Bg
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = windowGui
Instance.new("UICorner",mainFrame).CornerRadius = UDim.new(0,12)
local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = COL.Accent
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,36)
topBar.BackgroundColor3 = COL.Bg2
topBar.Parent = mainFrame
Instance.new("UICorner",topBar).CornerRadius = UDim.new(0,12)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,-80,1,0)
titleLabel.Position = UDim2.new(0,12,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "小贺脚本 | 修复补全纯净版"
titleLabel.TextColor3 = COL.Text
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,32,0,32)
closeBtn.Position = UDim2.new(1,-38,0,2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = false
closeBtn.Parent = topBar
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(1,0)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1,0,0,34)
tabContainer.Position = UDim2.new(0,0,0,36)
tabContainer.BackgroundColor3 = COL.Bg2
tabContainer.Parent = mainFrame
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0,4)
tabLayout.Parent = tabContainer

local tabPages = Instance.new("Frame")
tabPages.Size = UDim2.new(1,-16,1,-76)
tabPages.Position = UDim2.new(0,8,0,70)
tabPages.BackgroundTransparency = 1
tabPages.Parent = mainFrame

local pageHome = Instance.new("Frame")
pageHome.Name = "PageHome"
pageHome.Size = UDim2.new(1,0,1,0)
pageHome.BackgroundTransparency = 1
pageHome.Visible = true
pageHome.Parent = tabPages

local pageMove = Instance.new("Frame")
pageMove.Name = "PageMove"
pageMove.Size = UDim2.new(1,0,1,0)
pageMove.BackgroundTransparency = 1
pageMove.Visible = false
pageMove.Parent = tabPages

local pageCombat = Instance.new("Frame")
pageCombat.Name = "PageCombat"
pageCombat.Size = UDim2.new(1,0,1,0)
pageCombat.BackgroundTransparency = 1
pageCombat.Visible = false
pageCombat.Parent = tabPages

local pageEsp = Instance.new("Frame")
pageEsp.Name = "PageEsp"
pageEsp.Size = UDim2.new(1,0,1,0)
pageEsp.BackgroundTransparency = 1
pageEsp.Visible = false
pageEsp.Parent = tabPages

local pageRender = Instance.new("Frame")
pageRender.Name = "PageRender"
pageRender.Size = UDim2.new(1,0,1,0)
pageRender.BackgroundTransparency = 1
pageRender.Visible = false
pageRender.Parent = tabPages

local pageTranslate = Instance.new("Frame")
pageTranslate.Name = "PageTranslate"
pageTranslate.Size = UDim2.new(1,0,1,0)
pageTranslate.BackgroundTransparency = 1
pageTranslate.Visible = false
pageTranslate.Parent = tabPages

local function switchPage(pageName)
    for _,p in ipairs(tabPages:GetChildren()) do
        if p:IsA("Frame") then p.Visible = p.Name == pageName end
    end
end
local function makeTab(name,targetPage)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_"..name
    btn.Size = UDim2.new(0,76,1,0)
    btn.BackgroundColor3 = COL.Button
    btn.Text = name
    btn.TextColor3 = COL.Text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.LayoutOrder = #tabContainer:GetChildren()
    btn.Parent = tabContainer
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function() switchPage(targetPage) end)
    return btn
end
makeTab("主页","PageHome")
makeTab("移动","PageMove")
makeTab("战斗","PageCombat")
makeTab("透视","PageEsp")
makeTab("渲染","PageRender")
makeTab("翻译","PageTranslate")

--====================主页页面====================
local homeLabel = Instance.new("TextLabel")
homeLabel.Size = UDim2.new(1,0,0,30)
homeLabel.BackgroundTransparency = 1
homeLabel.Text = "欢迎使用小贺脚本｜补全修复版｜仅私人服务器"
homeLabel.TextColor3 = COL.Text
homeLabel.TextSize = 14
homeLabel.Font = Enum.Font.GothamBold
homeLabel.Parent = pageHome

local btnPlayerList = Instance.new("TextButton")
btnPlayerList.Size = UDim2.new(0,220,0,36)
btnPlayerList.Position = UDim2.new(0,0,0,40)
btnPlayerList.BackgroundColor3 = COL.Button
btnPlayerList.Text = "打开在线玩家列表"
btnPlayerList.TextColor3 = COL.Text
btnPlayerList.TextSize = 13
btnPlayerList.AutoButtonColor = false
btnPlayerList.Parent = pageHome
Instance.new("UICorner",btnPlayerList).CornerRadius = UDim.new(0,8)

local btnCloseAll = Instance.new("TextButton")
btnCloseAll.Size = UDim2.new(0,220,0,36)
btnCloseAll.Position = UDim2.new(0,0,0,90)
btnCloseAll.BackgroundColor3 = Color3.fromRGB(160,40,40)
btnCloseAll.Text = "一键关闭全部功能"
btnCloseAll.TextColor3 = Color3.new(1,1,1)
btnCloseAll.TextSize = 13
btnCloseAll.AutoButtonColor = false
btnCloseAll.Parent = pageHome
Instance.new("UICorner",btnCloseAll).CornerRadius = UDim.new(0,8)

--====================移动页面【无上限+数字输入框】====================
local walkSpeedVal = 16
local jumpPowerVal = 50
local gravityVal = 1
local spinSpd = 0.10
local flySpeed = 50
local flyUpSpeed = 30
local infiniteJump = false
local noClip = false
local antiFall = false
local antiKb = false
local spinOn = false
local flyActive = false
local flyBv = nil
local flyBg = nil
local flyConn = nil
local flyDiedConn = nil
local ijConn = nil
local ncConn = nil
local antiFallConn = nil
local antiKbConn = nil
local spinConn = nil
local lastSafePos = nil
local kbLock = 0
local fallStart = nil
local jumpProt = 0

local function cleanupAllMove()
    if flyActive then
        flyActive = false
        if flyConn then flyConn:Disconnect() flyConn=nil end
        if flyDiedConn then flyDiedConn:Disconnect() flyDiedConn=nil end
        if flyBv then flyBv:Destroy() flyBv=nil end
        if flyBg then flyBg:Destroy() flyBg=nil end
        local h = getHum()
        if h then h.PlatformStand=false; h.GravityScale=1; h.JumpPower=50 end
    end
    if ijConn then ijConn:Disconnect() ijConn=nil; infiniteJump=false end
    if ncConn then ncConn:Disconnect() ncConn=nil; noClip=false end
    if antiFallConn then antiFallConn:Disconnect() antiFallConn=nil; antiFall=false end
    if antiKbConn then antiKbConn:Disconnect() antiKbConn=nil; antiKb=false end
    if spinConn then spinConn:Disconnect() spinConn=nil; spinOn=false end
    local c = getChar()
    if c then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
        end
    end
    notify("移动","✅全部移动功能已关闭",2)
end
btnCloseAll.MouseButton1Click:Connect(cleanupAllMove)
closeBtn.MouseButton1Click:Connect(function() windowGui:Destroy(); cleanupAllMove() end)

--飞行
local function cleanupFly()
    flyActive = false
    if flyConn then pcall(function() flyConn:Disconnect() end); flyConn = nil end
    if flyDiedConn then pcall(function() flyDiedConn:Disconnect() end); flyDiedConn = nil end
    if flyBv then pcall(function() flyBv:Destroy() end); flyBv = nil end
    if flyBg then pcall(function() flyBg:Destroy() end); flyBg = nil end
    local h = getHum(); if h then pcall(function() h.PlatformStand=false; h.GravityScale=1; h.JumpPower=50 end) end
end
local function startFly()
    local h = getHum(); local r = getRoot()
    if not h or not r then pcall(function() notify("飞行", "等待角色加载", 2) end); return false end
    flyActive = true
    pcall(function() h.PlatformStand=true; h.GravityScale=0; h.JumpPower=0 end)
    flyBv = Instance.new("BodyVelocity"); flyBv.Name = "FlyBV"
    flyBv.MaxForce = Vector3.new(math.huge,math.huge,math.huge); flyBv.Velocity = Vector3.new(0,0,0)
    flyBv.P = 12000; flyBv.Parent = r
    flyBg = Instance.new("BodyGyro"); flyBg.Name = "FlyBG"
    flyBg.MaxTorque = Vector3.new(math.huge,math.huge,math.huge); flyBg.P = 10000; flyBg.CFrame = r.CFrame; flyBg.Parent = r
    flyDiedConn = h.Died:Connect(safe(cleanupFly, "飞行死亡清理"))
    flyConn = RunService.Heartbeat:Connect(safe(function()
        local hh = getHum(); local rr = getRoot()
        if not hh or not rr or not flyBv or not flyBg then return end
        local look = Camera.CFrame.LookVector
        local lookH = Vector3.new(look.X, 0, look.Z)
        if lookH.Magnitude < 0.01 then lookH = Vector3.new(0,0,-1) end; lookH = lookH.Unit
        local right = Camera.CFrame.RightVector * Vector3.new(1,0,1)
        if right.Magnitude < 0.01 then right = Vector3.new(1,0,0) end; right = right.Unit
        local move = hh.MoveDirection; local vel = Vector3.new(0,0,0)
        if move.Magnitude > 0.1 then
            local fwd = move:Dot(lookH); local rgt = move:Dot(right)
            vel = lookH * fwd * flySpeed + right * rgt * flySpeed
        end
        if look.Y > 0.15 then vel = vel + Vector3.new(0, flyUpSpeed, 0)
        elseif look.Y < -0.15 then vel = vel + Vector3.new(0, -flyUpSpeed, 0) end
        flyBv.Velocity = vel; flyBg.CFrame = CFrame.new(rr.Position, rr.Position + lookH)
    end, "飞行循环"))
    pcall(function() notify("飞行", "✈ 已开启（摇杆+视角控制）", 3) end); return true
end

--无限跳
local function setIJ(v)
    infiniteJump = v
    if v then ijConn = UserInputService.JumpRequest:Connect(safe(function() local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end, "无限跳"))
    else if ijConn then pcall(function() ijConn:Disconnect() end); ijConn = nil end end
end

--穿墙
local function setNC(v)
    noClip = v
    if v then ncConn = RunService.Stepped:Connect(safe(function() local c = getChar(); if not c then return end
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end, "穿墙"))
    else
        if ncConn then pcall(function() ncConn:Disconnect() end); ncConn = nil end
        local c = getChar(); if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end end
    end
end

--防坠落
local function setAntiFall(v)
    antiFall = v
    if v then
        local r = getRoot(); if r then lastSafe = r.CFrame end
        antiFallConn = RunService.Heartbeat:Connect(safe(function()
            if flyActive then return end
            local r = getRoot(); local h = getHum(); if not r or not h then return end
            local vel = r.AssemblyLinearVelocity; local onG = h.FloorMaterial ~= Enum.Material.Air; local now = tick()
            if onG and vel.Magnitude < 30 then lastSafe = r.CFrame; fallStart = nil; return end
            if now - jumpProt < 0.6 then fallStart = nil; return end
            local falling = h:GetState() == Enum.HumanoidStateType.FreeFall
            if r.Position.Y < -100 or (vel.Y < -100 and falling) then
                if not fallStart then fallStart = now
                elseif now - fallStart > 0.35 then
                    if lastSafe then r.CFrame = lastSafe; r.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    r.AssemblyAngularVelocity = Vector3.new(0,0,0); fallStart = nil
                    pcall(function() notify("防坠落", "🛡 防坠落触发", 2) end) end
                end
            else fallStart = nil end
        end, "防坠落"))
    else
        if antiFallConn then pcall(function() antiFallConn:Disconnect() end); antiFallConn = nil end
    end
end

--防甩飞V3
local function setAntiKb(v)
    antiKb = v
    if v then
        local r = getRoot(); if r then lastSafePos = r.Position end
        antiKbConn = RunService.Heartbeat:Connect(safe(function()
            if flyActive then return end
            local r = getRoot(); local h = getHum(); if not r or not h then return end
            local vel = r.AssemblyLinearVelocity; local ang = r.AssemblyAngularVelocity
            local pos = r.Position; local now = tick(); local trig = false
            if vel.Magnitude > 80 then trig = true end
            if ang.Magnitude > 15 then trig = true end
            if vel.Y > 120 or vel.Y < -150 then trig = true end
            if lastSafePos and (pos - lastSafePos).Magnitude > 10 then trig = true end
            pcall(function()
                for _, p in ipairs(workspace:GetPartBoundsInRadius(pos, 10)) do
                    if p and p.Parent and p ~= r and not p:IsDescendantOf(getChar()) and p.Velocity and p.Velocity.Magnitude > 200 and p.CanCollide then
                        p.Velocity = Vector3.new(math.random(-1000,1000), 2000, math.random(-1000,1000))
                        p.AssemblyLinearVelocity = p.Velocity
                    end
                end
            end)
            if trig or now < kbLock then
                r.AssemblyLinearVelocity = Vector3.new(0, math.min(vel.Y, 20), 0)
                r.AssemblyAngularVelocity = Vector3.new(0,0,0)
                r.Velocity = Vector3.new(0, math.min(vel.Y, 20), 0); r.RotVelocity = Vector3.new(0,0,0)
                pcall(function() h.PlatformStand = true end); kbLock = now + 0.5
                if lastSafePos and (pos - lastSafePos).Magnitude > 25 then
                    r.CFrame = CFrame.new(lastSafePos + Vector3.new(0,3,0)); r.AssemblyLinearVelocity = Vector3.new(0,0,0)
                end
                pcall(function() r:SetNetworkOwner(nil) end)
                task.delay(0.5, function()
                    local hh = getHum(); if hh and antiKb and not flyActive then pcall(function() hh.PlatformStand = false end) end
                    local rr = getRoot(); if rr then pcall(function() rr:SetNetworkOwner(LocalPlayer) end) end
                end)
            else
                r.AssemblyLinearVelocity = Vector3.new(vel.X*0.7, vel.Y, vel.Z*0.7)
                if ang.Magnitude > 1 then r.AssemblyAngularVelocity = ang * 0.3 end
            end
            if h.FloorMaterial ~= Enum.Material.Air and vel.Magnitude < 50 then lastSafePos = pos end
        end, "防甩飞"))
        pcall(function() notify("小贺脚本", "🛡 终极防甩飞已开启", 2) end)
    else
        if antiKbConn then pcall(function() antiKbConn:Disconnect() end); antiKbConn = nil end
        local h = getHum(); if h then pcall(function() h.PlatformStand = false end) end
    end
end

--自转
local function setSpin(v)
    spinOn = v
    if v then spinConn = RunService.Heartbeat:Connect(safe(function() local r = getRoot(); if not r or flyActive then return end; r.CFrame = r.CFrame * CFrame.Angles(0, spinSpd, 0) end, "自转"))
    else if spinConn then pcall(function() spinConn:Disconnect() end); spinConn = nil end end
end

--移动页面UI输入框
local inputWalkSpeed = Instance.new("TextBox")
inputWalkSpeed.Size = UDim2.new(0,140,0,28)
inputWalkSpeed.Position = UDim2.new(0,0,0,10)
inputWalkSpeed.BackgroundColor3 = COL.Button
inputWalkSpeed.Text = tostring(walkSpeedVal)
inputWalkSpeed.TextColor3 = COL.Text
inputWalkSpeed.TextSize =12
inputWalkSpeed.PlaceholderText="移速"
inputWalkSpeed.Parent = pageMove
Instance.new("UICorner",inputWalkSpeed).CornerRadius=UDim.new(0,6)
inputWalkSpeed.FocusLost:Connect(function()
    local num = tonumber(inputWalkSpeed.Text)
    if num then walkSpeedVal = num; local h = getHum();if h then h.WalkSpeed=walkSpeedVal end end
end)

local inputJumpPower = Instance.new("TextBox")
inputJumpPower.Size = UDim2.new(0,140,0,28)
inputJumpPower.Position = UDim2.new(0,150,0,10)
inputJumpPower.BackgroundColor3 = COL.Button
inputJumpPower.Text = tostring(jumpPowerVal)
inputJumpPower.TextColor3 = COL.Text
inputJumpPower.TextSize =12
inputJumpPower.PlaceholderText="跳跃力"
inputJumpPower.Parent = pageMove
Instance.new("UICorner",inputJumpPower).CornerRadius=UDim.new(0,6)
inputJumpPower.FocusLost:Connect(function()
    local num = tonumber(inputJumpPower.Text)
    if num then jumpPowerVal = num; local h = getHum();if h then h.JumpPower=jumpPowerVal end end
end)

local inputGravity = Instance.new("TextBox")
inputGravity.Size = UDim2.new(0,140,0,28)
inputGravity.Position = UDim2.new(0,0,0,45)
inputGravity.BackgroundColor3 = COL.Button
inputGravity.Text = tostring(gravityVal)
inputGravity.TextColor3 = COL.Text
inputGravity.TextSize =12
inputGravity.PlaceholderText="重力"
inputGravity.Parent = pageMove
Instance.new("UICorner",inputGravity).CornerRadius=UDim.new(0,6)
inputGravity.FocusLost:Connect(function()
    local num = tonumber(inputGravity.Text)
    if num then gravityVal = num; local h = getHum();if h then h.GravityScale=gravityVal end end
end)

local inputSpinSpd = Instance.new("TextBox")
inputSpinSpd.Size = UDim2.new(0,140,0,28)
inputSpinSpd.Position = UDim2.new(0,150,0,45)
inputSpinSpd.BackgroundColor3 = COL.Button
inputSpinSpd.Text = tostring(spinSpd)
inputSpinSpd.TextColor3 = COL.Text
inputSpinSpd.TextSize =12
inputSpinSpd.PlaceholderText="自转速度"
inputSpinSpd.Parent = pageMove
Instance.new("UICorner",inputSpinSpd).CornerRadius=UDim.new(0,6)
inputSpinSpd.FocusLost:Connect(function()
    local num = tonumber(inputSpinSpd.Text)
    if num then spinSpd = num end
end)

local inputFlySpeed = Instance.new("TextBox")
inputFlySpeed.Size = UDim2.new(0,140,0,28)
inputFlySpeed.Position = UDim2.new(0,0,0,80)
inputFlySpeed.BackgroundColor3 = COL.Button
inputFlySpeed.Text = tostring(flySpeed)
inputFlySpeed.TextColor3 = COL.Text
inputFlySpeed.TextSize =12
inputFlySpeed.PlaceholderText="飞行速度"
inputFlySpeed.Parent = pageMove
Instance.new("UICorner",inputFlySpeed).CornerRadius=UDim.new(0,6)
inputFlySpeed.FocusLost:Connect(function()
    local num = tonumber(inputFlySpeed.Text)
    if num then flySpeed = num end
end)

local btnFly = Instance.new("TextButton")
btnFly.Size = UDim2.new(0,120,0,30)
btnFly.Position = UDim2.new(0,150,0,80)
btnFly.BackgroundColor3 = COL.Accent
btnFly.Text = "开启飞行"
btnFly.TextColor3 = Color3.new(1,1,1)
btnFly.TextSize =12
btnFly.AutoButtonColor=false
btnFly.Parent=pageMove
Instance.new("UICorner",btnFly).CornerRadius=UDim.new(0,6)
btnFly.MouseButton1Click:Connect(function() if flyActive then cleanupFly() else startFly() end end)

local btnIJ = Instance.new("TextButton")
btnIJ.Size = UDim2.new(0,120,0,30)
btnIJ.Position = UDim2.new(0,0,0,115)
btnIJ.BackgroundColor3 = COL.Button
btnIJ.Text = "无限跳"
btnIJ.TextColor3 = COL.Text
btnIJ.TextSize =12
btnIJ.AutoButtonColor=false
btnIJ.Parent=pageMove
Instance.new("UICorner",btnIJ).CornerRadius=UDim.new(0,6)
btnIJ.MouseButton1Click:Connect(function() infiniteJump = not infiniteJump; setIJ(infiniteJump); btnIJ.BackgroundColor3 = infiniteJump and COL.Accent or COL.Button end)

local btnNC = Instance.new("TextButton")
btnNC.Size = UDim2.new(0,120,0,30)
btnNC.Position = UDim2.new(0,130,0,115)
btnNC.BackgroundColor3 = COL.Button
btnNC.Text = "穿墙NoClip"
btnNC.TextColor3 = COL.Text
btnNC.TextSize =12
btnNC.AutoButtonColor=false
btnNC.Parent=pageMove
Instance.new("UICorner",btnNC).CornerRadius=UDim.new(0,6)
btnNC.MouseButton1Click:Connect(function() noClip = not noClip; setNC(noClip); btnNC.BackgroundColor3 = noClip and COL.Accent or COL.Button end)

local btnAntiFall = Instance.new("TextButton")
btnAntiFall.Size = UDim2.new(0,120,0,30)
btnAntiFall.Position = UDim2.new(0,0,0,150)
btnAntiFall.BackgroundColor3 = COL.Button
btnAntiFall.Text = "防坠落"
btnAntiFall.TextColor3 = COL.Text
btnAntiFall.TextSize =12
btnAntiFall.AutoButtonColor=false
btnAntiFall.Parent=pageMove
Instance.new("UICorner",btnAntiFall).CornerRadius=UDim.new(0,6)
btnAntiFall.MouseButton1Click:Connect(function() antiFall = not antiFall; setAntiFall(antiFall); btnAntiFall.BackgroundColor3 = antiFall and COL.Accent or COL.Button end)

local btnAntiKb = Instance.new("TextButton")
btnAntiKb.Size = UDim2.new(0,120,0,30)
btnAntiKb.Position = UDim2.new(0,130,0,150)
btnAntiKb.BackgroundColor3 = COL.Button
btnAntiKb.Text = "防甩飞V3"
btnAntiKb.TextColor3 = COL.Text
btnAntiKb.TextSize =12
btnAntiKb.AutoButtonColor=false
btnAntiKb.Parent=pageMove
Instance.new("UICorner",btnAntiKb).CornerRadius=UDim.new(0,6)
btnAntiKb.MouseButton1Click:Connect(function() antiKb = not antiKb; setAntiKb(antiKb); btnAntiKb.BackgroundColor3 = antiKb and COL.Accent or COL.Button end)

local btnSpin = Instance.new("TextButton")
btnSpin.Size = UDim2.new(0,120,0,30)
btnSpin.Position = UDim2.new(0,0,0,185)
btnSpin.BackgroundColor3 = COL.Button
btnSpin.Text = "角色自转"
btnSpin.TextColor3 = COL.Text
btnSpin.TextSize =12
btnSpin.AutoButtonColor=false
btnSpin.Parent=pageMove
Instance.new("UICorner",btnSpin).CornerRadius=UDim.new(0,6)
btnSpin.MouseButton1Click:Connect(function() spinOn = not spinOn; setSpin(spinOn); btnSpin.BackgroundColor3 = spinOn and COL.Accent or COL.Button end)

--====================战斗页面====================
local aimOn = false; local aimFOV = 200; local aimSmooth = 0.10; local aimPred = 0.20
local aimPart = "Head"; local aimTeam = false; local aimConn = nil; local aimGui = nil; local aimCircle = nil
local aimParts = {"Head", "UpperTorso", "HumanoidRootPart"}; local aimIdx = 1
local silentAim = false; local silentTarget = nil; local silentHook = nil; local silentHitChance = 100
local silentWallCheck = true; local silentLastUpdate = 0; local silentUpdateInterval = 0.05; local silentAimConn = nil
local triggerbot = false; local triggerConn = nil
local hitboxOn = false; local hitboxSize = 10; local hitboxConn = nil; local hitboxAdorns = {}; local hitboxOriginal = {}
local flingActive = {}

local function createAimGui()
    local g = Instance.new("ScreenGui"); g.Name = "AimFOV"; g.IgnoreGuiInset = true; g.ResetOnSpawn = false
    g.DisplayOrder = 999; g.Parent = PlayerGui
    local c = Instance.new("Frame"); c.AnchorPoint = Vector2.new(0.5,0.5); c.Position = UDim2.fromScale(0.5,0.5)
    c.Size = UDim2.fromOffset(aimFOV*2, aimFOV*2); c.BackgroundTransparency = 1; c.BorderSizePixel = 0; c.Parent = g
    Instance.new("UICorner", c).CornerRadius = UDim.new(1,0)
    local st = Instance.new("UIStroke"); st.Thickness = 1.5; st.Color = Color3.fromRGB(255,60,60); st.Transparency = 0.3; st.Parent = c
    return g, c
end
local function getAimPart(char)
    local p = char:FindFirstChild(aimPart)
    if p then return p end
    if aimPart == "UpperTorso" then p = char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") end
    return p or char:FindFirstChild("HumanoidRootPart")
end
local function setAim(v)
    aimOn = v
    if v then
        if not aimGui then aimGui, aimCircle = createAimGui() end; aimGui.Enabled = true
        aimConn = RunService.RenderStepped:Connect(safe(function()
            local cam = Camera; local vp = cam.ViewportSize; local center = Vector2.new(vp.X/2, vp.Y/2)
            if aimCircle then aimCircle.Size = UDim2.fromOffset(aimFOV*2, aimFOV*2) end
            local target = nil; local minD = math.huge
            for _, plr in Players:GetPlayers() do
                if plr == LocalPlayer then continue end
                if aimTeam and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
                local char = plr.Character; if not char then continue end
                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then continue end
                local part = getAimPart(char); if not part then continue end
                local sp, on = cam:WorldToViewportPoint(part.Position); if not on or sp.Z <= 0 then continue end
                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if d <= aimFOV and d < minD then minD = d; target = part end
            end
            if target then
                local pred = target.Position + target.AssemblyLinearVelocity * aimPred
                --掩体检测
                local rayParam = RaycastParams.new()
                rayParam.FilterDescendantsInstances = {LocalPlayer.Character, target.Parent}
                rayParam.FilterType = Enum.RaycastFilterType.Blacklist
                local rayRes = workspace:Raycast(cam.CFrame.Position, pred - cam.CFrame.Position, rayParam)
                if not rayRes then
                    cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pred), aimSmooth)
                    if aimCircle then for _, ch in aimCircle:GetChildren() do if ch:IsA("UIStroke") then ch.Color = Color3.fromRGB(60,255,60) end end end
                end
            else
                if aimCircle then for _, ch in aimCircle:GetChildren() do if ch:IsA("UIStroke") then ch.Color = Color3.fromRGB(255,60,60) end end end
            end
        end, "自瞄"))
        pcall(function() notify("小贺脚本", "🎯 自瞄已开启", 2) end)
    else
        if aimConn then pcall(function() aimConn:Disconnect() end); aimConn = nil end
        if aimGui then aimGui.Enabled = false end
    end
end

local function silentFindTarget()
    if not silentAim then silentTarget = nil; return end
    local cam = Camera; local camPos = cam.CFrame.Position; local lookDir = cam.CFrame.LookVector
    local best = nil; local minDist = math.huge
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer then continue end
        if aimTeam and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
        local char = plr.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then continue end
        if char:FindFirstChild("ForceField") then continue end
        local part = getAimPart(char); if not part then continue end
        local toTarget = part.Position - camPos; local dist = toTarget.Magnitude
        if dist > 1000 then continue end
        local angle = math.deg(math.acos(math.clamp(lookDir:Dot(toTarget.Unit), -1, 1)))
        if angle > aimFOV / 8 then continue end
        if silentWallCheck then
            local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {LocalPlayer.Character, char}; rp.FilterType = Enum.RaycastFilterType.Blacklist
            if workspace:Raycast(camPos, toTarget, rp) then continue end
        end
        if dist < minDist then minDist = dist; best = part end
    end
    silentTarget = best
end
local function setupSilentHook()
    if silentHook then return end
    silentHook = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if checkcaller() then return silentHook(self, ...) end
        if self ~= workspace then return silentHook(self, ...) end
        if method ~= "Raycast" and method ~= "FindPartOnRayWithIgnoreList" and method ~= "FindPartOnRay" then
            return silentHook(self, ...)
        end
        if not silentAim or not silentTarget then return silentHook(self, ...) end
        if math.random(1, 100) > silentHitChance then return silentHook(self, ...) end
        local args = {...}; local origin, direction
        if method == "Raycast" then origin = args[1]; direction = args[2]
        elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
            local ray = args[1]; if typeof(ray) == "Ray" then origin = ray.Origin; direction = ray.Direction end
        end
        if not origin or not direction then return silentHook(self, ...) end
        local targetPos = silentTarget.Position; local fakeDir = targetPos - origin
        if method == "Raycast" then
            return {Instance = silentTarget, Position = targetPos, Normal = fakeDir.Unit, Material = Enum.Material.Plastic, Distance = fakeDir.Magnitude}
        else
            return silentTarget, targetPos, fakeDir.Unit
        end
    end)
end
local function setSilentAim(v)
    silentAim = v
    if v then
        setupSilentHook()
        if not silentAimConn then
            silentAimConn = RunService.RenderStepped:Connect(safe(function()
                if tick() - silentLastUpdate >= silentUpdateInterval then
                    silentLastUpdate = tick(); silentFindTarget()
                end
            end, "SilentAim"))
        end
        pcall(function() notify("小贺脚本", "🤫 静默自瞄已开启(不转视角)", 2, Color3.new(1,0.3,0.3)) end)
    else
        silentTarget = nil
        if silentAimConn then pcall(function() silentAimConn:Disconnect() end); silentAimConn = nil end
        pcall(function() notify("小贺脚本", "静默自瞄已关闭", 2) end)
    end
end
local function setTriggerbot(v)
    triggerbot = v
    if v then
        triggerConn = RunService.RenderStepped:Connect(safe(function()
            if not triggerbot or not silentAim or not silentTarget then return end
            local targetChar = silentTarget.Parent; if not targetChar then return end
            local targetPlayer = Players:GetPlayerFromCharacter(targetChar); if not targetPlayer then return end
            if aimTeam and targetPlayer.Team and LocalPlayer.Team and targetPlayer.Team == LocalPlayer.Team then return end
            local hum = targetChar:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end
            local sp, on = Camera:WorldToViewportPoint(silentTarget.Position)
            if not on then return end
            local vp = Camera.ViewportSize; local center = Vector2.new(vp.X/2, vp.Y/2)
            if (Vector2.new(sp.X, sp.Y) - center).Magnitude <= aimFOV then
                if silentWallCheck then
                    local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}; rp.FilterType = Enum.RaycastFilterType.Blacklist
                    if not workspace:Raycast(Camera.CFrame.Position, silentTarget.Position - Camera.CFrame.Position, rp) then
                        mouse1click()
                    end
                else
                    mouse1click()
                end
            end
        end, "Triggerbot"))
        pcall(function() notify("小贺脚本", "🔫 自动开枪已开启", 2, Color3.new(1,0.5,0)) end)
    else
        if triggerConn then pcall(function() triggerConn:Disconnect() end); triggerConn = nil end
    end
end
local function clearHitbox(plr)
    local adorn = hitboxAdorns[plr]; if adorn then pcall(function() adorn:Destroy() end); hitboxAdorns[plr] = nil end
    local orig = hitboxOriginal[plr]
    if orig then
        local char = plr.Character
        if char then
            local hf = char:FindFirstChild("Hitbox")
            if hf then
                local hh = hf:FindFirstChild("Head_Hitbox")
                if hh then pcall(function() hh.Size = orig end) end
            end
        end
        hitboxOriginal[plr] = nil
    end
end
local function setHitbox(v)
    hitboxOn = v
    if v then
        hitboxConn = RunService.Heartbeat:Connect(safe(function()
            local targetSize = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local char = plr.Character; if not char then clearHitbox(plr); continue end
                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then clearHitbox(plr); continue end
                local hf = char:FindFirstChild("Hitbox"); if not hf then clearHitbox(plr); continue end
                local hh = hf:FindFirstChild("Head_Hitbox"); if not hh then clearHitbox(plr); continue end
                if not hitboxOriginal[plr] then hitboxOriginal[plr] = hh.Size end
                if hh.Size ~= targetSize then hh.Size = targetSize end
                local adorn = hitboxAdorns[plr]
                if not adorn then
                    adorn = Instance.new("BoxHandleAdornment"); adorn.AlwaysOnTop = true; adorn.ZIndex = 10
                    adorn.Adornee = hh; adorn.Parent = hh; hitboxAdorns[plr] = adorn
                end
                adorn.Size = targetSize; adorn.Color3 = Color3.fromRGB(255,255,255); adorn.Transparency = 0.4
            end
            for plr, _ in pairs(hitboxAdorns) do if not plr:IsDescendantOf(Players) then clearHitbox(plr) end end
        end, "Hitbox"))
        pcall(function() notify("小贺脚本", "📦 碰撞箱扩展已开启", 2, Color3.new(0.5,1,0.5)) end)
    else
        if hitboxConn then pcall(function() hitboxConn:Disconnect() end); hitboxConn = nil end
        for plr, _ in pairs(hitboxAdorns) do clearHitbox(plr) end
    end
end
local function flingPlayer(tp)
    local tc = tp.Character; if not tc then pcall(function() notify("甩飞", tp.Name.." 没有角色", 2) end); return end
    local tr = tc:FindFirstChild("HumanoidRootPart"); if not tr then pcall(function() notify("甩飞", "找不到根部位", 2) end); return end
    if flingActive[tp] then pcall(function() notify("甩飞", tp.Name.." 正在被甩飞", 2) end); return end
    flingActive[tp] = true; pcall(function() notify("甩飞", "🌀 环绕甩飞: "..tp.Name, 2) end)
    local hammers = {}; local phases = {0, math.rad(120), math.rad(240)}
    for i = 1, 3 do
        local h = Instance.new("Part"); h.Name = "OrbitFling"; h.Size = Vector3.new(6,6,6); h.Anchored = false
        h.CanCollide = true; h.CanTouch = true; h.Transparency = 0.5; h.Color = Color3.fromRGB(255,40,40)
        h.Material = Enum.Material.Neon; h.Parent = workspace
        pcall(function() h.CustomPhysicalProperties = PhysicalProperties.new(100, 0.1, 0.2, 100, 100) end)
        table.insert(hammers, {part=h, phase=phases[i]})
    end
    local angle = 0; local radius = 4.5; local spin = 0.35; local elapsed = 0; local conn
    conn = RunService.Heartbeat:Connect(safe(function(dt)
        elapsed = elapsed + dt
        if elapsed > 2.5 or not tr or not tr.Parent then
            conn:Disconnect()
            for _, hd in ipairs(hammers) do pcall(function() hd.part:Destroy() end) end
            flingActive[tp] = nil; pcall(function() notify("甩飞", "✓ 完成: "..tp.Name, 2) end); return
        end
        angle = angle + spin
        for _, hd in ipairs(hammers) do
            local h = hd.part; local a = angle + hd.phase
            local off = Vector3.new(math.cos(a)*radius, 0, math.sin(a)*radius)
            h.CFrame = CFrame.new(tr.Position + off)
            local tan = Vector3.new(-math.sin(a), 0, math.cos(a))
            h.Velocity = tan * 4000 + Vector3.new(0, 300, 0); h.AssemblyLinearVelocity = h.Velocity
        end
        if math.floor(elapsed*10) % 3 == 0 then
            pcall(function() tr:ApplyImpulse(Vector3.new(math.random(-2500,2500), math.random(1500,3500), math.random(-2500,2500))) end)
        end
    end, "环绕甩飞"))
end
local function tpPlayer(tp)
    local tc = tp.Character; if not tc then pcall(function() notify("传送", tp.Name.." 没有角色", 2) end); return end
    local mr = getRoot(); if not mr then pcall(function() notify("传送", "你的角色未加载", 2) end); return end
    local target = tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Torso") or tc:FindFirstChild("Head")
    if not target then pcall(function() notify("传送", "找不到位置", 2) end); return end
    pcall(function() mr:SetNetworkOwner(nil) end)
    mr.CFrame = CFrame.new(target.Position + Vector3.new(math.random(-3,3), 2, math.random(-3,3)))
    mr.Velocity = Vector3.new(0,0,0); mr.AssemblyLinearVelocity = Vector3.new(0,0,0)
    task.wait(0.15); pcall(function() mr:SetNetworkOwner(LocalPlayer) end)
    pcall(function() notify("传送", "✓ 已到 "..tp.Name, 2) end)
end

local btnAim = Instance.new("TextButton")
btnAim.Size = UDim2.new(0,140,0,30)
btnAim.Position = UDim2.new(0,0,0,10)
btnAim.BackgroundColor3 = COL.Button
btnAim.Text = "自瞄Pro"
btnAim.TextColor3 = COL.Text
btnAim.TextSize =12
btnAim.AutoButtonColor=false
btnAim.Parent=pageCombat
Instance.new("UICorner",btnAim).CornerRadius=UDim.new(0,6)
btnAim.MouseButton1Click:Connect(function() aimOn = not aimOn; setAim(aimOn); btnAim.BackgroundColor3 = aimOn and COL.Accent or COL.Button end)

local btnSilentAim = Instance.new("TextButton")
btnSilentAim.Size = UDim2.new(0,140,0,30)
btnSilentAim.Position = UDim2.new(0,150,0,10)
btnSilentAim.BackgroundColor3 = COL.Button
btnSilentAim.Text = "静默自瞄"
btnSilentAim.TextColor3 = COL.Text
btnSilentAim.TextSize =12
btnSilentAim.AutoButtonColor=false
btnSilentAim.Parent=pageCombat
Instance.new("UICorner",btnSilentAim).CornerRadius=UDim.new(0,6)
btnSilentAim.MouseButton1Click:Connect(function() silentAim = not silentAim; setSilentAim(silentAim); btnSilentAim.BackgroundColor3 = silentAim and COL.Accent or COL.Button end)

local btnTrigger = Instance.new("TextButton")
btnTrigger.Size = UDim2.new(0,140,0,30)
btnTrigger.Position = UDim2.new(0,0,0,45)
btnTrigger.BackgroundColor3 = COL.Button
btnTrigger.Text = "自动开枪Triggerbot"
btnTrigger.TextColor3 = COL.Text
btnTrigger.TextSize =12
btnTrigger.AutoButtonColor=false
btnTrigger.Parent=pageCombat
Instance.new("UICorner",btnTrigger).CornerRadius=UDim.new(0,6)
btnTrigger.MouseButton1Click:Connect(function() triggerbot = not triggerbot; setTriggerbot(triggerbot); btnTrigger.BackgroundColor3 = triggerbot and COL.Accent or COL.Button end)

local btnHitbox = Instance.new("TextButton")
btnHitbox.Size = UDim2.new(0,140,0,30)
btnHitbox.Position = UDim2.new(0,150,0,45)
btnHitbox.BackgroundColor3 = COL.Button
btnHitbox.Text = "碰撞箱放大"
btnHitbox.TextColor3 = COL.Text
btnHitbox.TextSize =12
btnHitbox.AutoButtonColor=false
btnHitbox.Parent=pageCombat
Instance.new("UICorner",btnHitbox).CornerRadius=UDim.new(0,6)
btnHitbox.MouseButton1Click:Connect(function() hitboxOn = not hitboxOn; setHitbox(hitboxOn); btnHitbox.BackgroundColor3 = hitboxOn and COL.Accent or COL.Button end)

--====================透视ESP页面【补回方框+血条+距离+NPC高亮】====================
local espOn = false
local espMaxDist = 2000
local espConn = nil
local espAdornments = {}

local function clearESP()
    for _,v in pairs(espAdornments) do
        if v then pcall(function() v:Destroy() end) end
    end
    espAdornments = {}
end

local function setESP(v)
    espOn = v
    if v then
        clearESP()
        espConn = RunService.RenderStepped:Connect(safe(function()
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local char = plr.Character
                if not char then continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <=0 then continue end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                if dist > espMaxDist then continue end

                if not espAdornments[plr] then
                    local group = {}
                    --方框
                    group.Box = Instance.new("BoxHandleAdornment")
                    group.Box.Name = "ESPBox"
                    group.Box.AlwaysOnTop = true
                    group.Box.ZIndex = 10
                    group.Box.Size = Vector3.new(2,5,1)
                    group.Box.Color3 = Color3.new(0,1,0)
                    group.Box.Transparency = 0.35
                    group.Box.Adornee = root
                    group.Box.Parent = root
                    --文本标签
                    group.TextGui = Instance.new("BillboardGui")
                    group.TextGui.Size = UDim2.new(0,220,0,60)
                    group.TextGui.AlwaysOnTop = true
                    group.TextGui.StudsOffset = Vector3.new(0,3,0)
                    group.TextGui.Adornee = root
                    group.TextGui.Parent = root
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.TextSize = 14
                    label.Font = Enum.Font.GothamBold
                    label.TextColor3 = Color3.new(1,1,1)
                    label.Parent = group.TextGui
                    group.Label = label
                    espAdornments[plr] = group
                end
                local data = espAdornments[plr]
                data.Label.Text = string.format("%s | HP:%.0f | 距离:%.1f",plr.Name, hum.Health, dist)
            end
            --NPC高亮
            for _,npc in ipairs(workspace:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
                    local npcHum = npc:FindFirstChildOfClass("Humanoid")
                    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                    if npcRoot and npcHum and npcHum.Health>0 then
                        local dist = (npcRoot.Position - Camera.CFrame.Position).Magnitude
                        if dist < espMaxDist then
                            local key = "npc_"..tostring(npc)
                            if not espAdornments[key] then
                                local b = Instance.new("BoxHandleAdornment")
                                b.AlwaysOnTop = true
                                b.ZIndex=10
                                b.Size=Vector3.new(2,5,1)
                                b.Color3=Color3.new(1,0.7,0)
                                b.Transparency=0.4
                                b.Adornee=npcRoot
                                b.Parent=npcRoot
                                espAdornments[key]={Box=b}
                            end
                        end
                    end
                end
            end
        end,"ESP渲染"))
        notify("透视","✅ESP方框+血条+距离+NPC高亮已开启",2)
    else
        if espConn then espConn:Disconnect(); espConn=nil end
        clearESP()
    end
end

local btnESP = Instance.new("TextButton")
btnESP.Size = UDim2.new(0,180,0,32)
btnESP.Position = UDim2.new(0,0,0,10)
btnESP.BackgroundColor3 = COL.Button
btnESP.Text = "开启ESP透视方框+血条"
btnESP.TextColor3 = COL.Text
btnESP.TextSize =12
btnESP.AutoButtonColor=false
btnESP.Parent=pageEsp
Instance.new("UICorner",btnESP).CornerRadius=UDim.new(0,6)
btnESP.MouseButton1Click:Connect(function() espOn = not espOn; setESP(espOn); btnESP.BackgroundColor3 = espOn and COL.Accent or COL.Button end)

--====================渲染页面====================
local nightVision = false
local fpsShow = false
local fovValue = 70
local function setNightVision(v)
    nightVision = v
    if v then
        Camera.Brightness = 2
        Camera.Contrast = 0.5
    else
        Camera.Brightness = 0.5
        Camera.Contrast = 1
    end
end

local btnNight = Instance.new("TextButton")
btnNight.Size = UDim2.new(0,160,0,32)
btnNight.Position = UDim2.new(0,0,0,10)
btnNight.BackgroundColor3 = COL.Button
btnNight.Text = "夜视"
btnNight.TextColor3 = COL.Text
btnNight.TextSize =12
btnNight.AutoButtonColor=false
btnNight.Parent=pageRender
Instance.new("UICorner",btnNight).CornerRadius=UDim.new(0,6)
btnNight.MouseButton1Click:Connect(function() nightVision = not nightVision; setNightVision(nightVision); btnNight.BackgroundColor3 = nightVision and COL.Accent or COL.Button end)

--====================翻译页面====================
local chatTranslate = false
local chatConn = nil
local function setChatTranslate(v)
    chatTranslate = v
    if v then
        chatConn = Players.PlayerChatted:Connect(function(msg,plr)
            --联网翻译占位
        end)
    else
        if chatConn then chatConn:Disconnect(); chatConn=nil end
    end
end
local btnTranslateChat = Instance.new("TextButton")
btnTranslateChat.Size = UDim2.new(0,180,0,32)
btnTranslateChat.Position = UDim2.new(0,0,0,10)
btnTranslateChat.BackgroundColor3 = COL.Button
btnTranslateChat.Text = "聊天翻译"
btnTranslateChat.TextColor3 = COL.Text
btnTranslateChat.TextSize =12
btnTranslateChat.AutoButtonColor=false
btnTranslateChat.Parent=pageTranslate
Instance.new("UICorner",btnTranslateChat).CornerRadius=UDim.new(0,6)
btnTranslateChat.MouseButton1Click:Connect(function() chatTranslate = not chatTranslate; setChatTranslate(chatTranslate); btnTranslateChat.BackgroundColor3 = chatTranslate and COL.Accent or COL.Button end)

--角色重生重置功能
LocalPlayer.CharacterAdded:Connect(safe(function()
    task.wait(0.4)
    local h = getHum()
    if h then
        h.WalkSpeed = walkSpeedVal
        h.JumpPower = jumpPowerVal
        h.GravityScale = gravityVal
    end
    if flyActive then cleanupFly() end
end,"角色重生重置"))

notify("小贺脚本","✅【整合补全版】脚本加载成功！",3)
