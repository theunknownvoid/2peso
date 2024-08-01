local Macro = false
local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local UniversalDeltaTime
local Character = LocalPlayer.Character
local Mouse = LocalPlayer:GetMouse()


getgenv().settings = { -- simplified settings cause i dont like the way getgenv() looks lol
    name = randomsilentaim.Custom,
    Target = nil,

	Prediction = randomsilentaim.SilentAim.Prediction,
	HitPart = randomsilentaim.SilentAim.HitPart,
	ClosestPart = randomsilentaim.SilentAim.HitClosestBodyPart,
    HitClosestPoint = randomsilentaim.SilentAim.HitClosestPoint,
    JumpOffset = randomsilentaim.SilentAim.JumpOffset,

	FOV = randomsilentaim.FOV.Enabled,
	FOVSize = randomsilentaim.FOV.Size,
	FOVColor = randomsilentaim.FOV.Color,
	FOVStayInMiddle = randomsilentaim.FOV.StayInMiddle,
    BALIW = randomsilentaim.FOV.BALIW,
	Tracer = randomsilentaim.FOV.Tracer,

	WallCheck = randomsilentaim.Legit.WallCheck,
	Resolver = randomsilentaim.Legit.Resolver,
	ResolveMode = randomsilentaim.Legit.ResolveMode,
	AntiGroundValue = randomsilentaim.Legit.AntiGroundValue,
	AutoResolver = randomsilentaim.Legit.AutoResolver,
	AutoResolverLimit = randomsilentaim.Legit.AutoResolverLimit,

    AntiLock = randomsilentaim.AntiLock,
    
    Executed = nil
}

if settings.Executed == true then
    return
else
    getgenv().FOVCircle = Drawing.new("Circle")
	getgenv().TracerLine = Drawing.new("Line")
end

function Calculate(before, after, deltatime)
    local displacement = (after - before)
    local velocity = displacement / deltatime

    return velocity
end

function Notify(tet, cum)
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = settings.name,
        Text = tet,
        Duration = cum,
        Icon = getcustomasset('senko.jpg')
    })
end

function updateFOV()
	FOVCircle.Radius = settings.FOVSize
	FOVCircle.Visible = settings.FOV
	FOVCircle.Color = settings.FOVColor
    if settings.FOVStayInMiddle == true then
	    FOVCircle.Position =  Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	elseif settings.FOVStayInMiddle == false then
        if settings.BALIW == true then 
            FOVCircle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X + math.random(-25,25), game:GetService("UserInputService"):GetMouseLocation().Y + math.random(-25,25))
        else
	        FOVCircle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
        end
	end
end

function updateTracer()
    if settings.Target ~= nil then
	    TracerLine.Visible = settings.Tracer
	    TracerLine.Color = settings.FOVColor
	    TracerLine.Thickness = 2
	    local Pos, OnScreen = Camera:WorldToViewportPoint(settings.Target.Position + (settings.Target.Velocity * settings.Prediction))
        TracerLine.From = game:GetService("UserInputService"):GetMouseLocation()
	    TracerLine.To = Vector2.new(Pos.X, Pos.Y)
    elseif settings.Target == nil then
        TracerLine.Visible = false
    end
end

function closestpoint(part)
    if settings.HitClosestPoint == true then
        local Transform = part.CFrame:PointToObjectSpace(Mouse.Hit.Position)
        return part.CFrame * Vector3.new(
            math.clamp(Transform.X, -part.Size.X / 2, part.Size.X / 2), 
            math.clamp(Transform.Y, -part.Size.Y / 2, part.Size.Y / 2), 
            math.clamp(Transform.Z, -part.Size.Z / 2, part.Size.Z / 2)
        )
    elseif settings.HitClosestPoint == false then
        return part.Position
    end
end

function wallCheck(destination, ignore)
	if settings.WallCheck == true then
		local Origin = Camera.CFrame.p
        --print(game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Origin, destination - Origin), ignore) == nil)
		return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Origin, destination - Origin), ignore) == nil
    else
		return true
	end
end

Mouse.KeyDown:Connect(function(key)
    if key == "t" then
        Macro = not Macro
        if Macro == true then
            repeat 
                game:GetService("VirtualInputManager"):SendMouseWheelEvent("0", "0", true, game)
                game:GetService('RunService').RenderStepped:Wait()
                game:GetService("VirtualInputManager"):SendMouseWheelEvent("0", "0", false, game)
                game:GetService('RunService').RenderStepped:Wait()
            until Macro == false
        end
    end
    if key == "n" then
		settings.FOV = not settings.FOV
	end
	if key == "b" then
		settings.Resolver = not settings.Resolver
		Notify('Resolver : '..tostring(settings.Resolver), 0.65)
	end
	if key == "h" then
		settings.Tracer = not settings.Tracer
	end
    if key == "v" then
		settings.AntiLock = not settings.AntiLock
        Notify('AntiLock : '..tostring(settings.AntiLock), 0.65)
	end
	if key == "[" then
		settings.Prediction = settings.Prediction - 0.01
		Notify('Prediction : '..settings.Prediction, 0.65)
	end
	if key == "]" then
		settings.Prediction = settings.Prediction + 0.01
		Notify('Prediction : '..settings.Prediction, 0.65)
	end
	if key == ";" then
		settings.FOVSize = settings.FOVSize - 1
	end
	if key == "'" then
		settings.FOVSize = settings.FOVSize + 1
	end
end)

function ClosestPlr(Part, Choice)
    local Distance = settings.FOVSize
    local Closest = nil
    local Distance2 = math.huge
    local Visibility = false

    for _, plr in pairs(Players:GetPlayers()) do
        local notKO = plr.Character:FindFirstChild("BodyEffects") and plr.Character.BodyEffects["K.O"].Value ~= true
        local notGrabbed = plr.Character:FindFirstChild("GRABBING_COINSTRAINT") == nil
        
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 and notKO and notGrabbed then
            local partInstance = plr.Character:FindFirstChild(Part)
            if partInstance then
                local Pos, Visible = Camera:WorldToViewportPoint(partInstance.Position)
                local MousePos = game:GetService("UserInputService"):GetMouseLocation()
                local Magnitude = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude

                if wallCheck(plr.Character.Head.Position, {LocalPlayer, plr.Character}) and Visible == true then
                    if settings.ClosestPart == true then
                        for _, v in pairs(plr.Character:GetChildren()) do
                            if v:IsA("BasePart") then
                                local Pos = Camera:WorldToViewportPoint(v.Position)
                                local Magnitude = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                                if Magnitude < Distance and Magnitude < settings.FOVSize + 5 then
                                    Closest = v
                                    Distance = Magnitude
                                    Visibility = Visible
                                end
                            end
                        end
                    elseif settings.ClosestPart == false then
                        if Magnitude < Distance and Magnitude < settings.FOVSize + 5 then
                            Closest = partInstance
                            Distance = Magnitude
                            Distance2 = (LocalPlayer.Character.HumanoidRootPart.Position - partInstance.Position).Magnitude
                            Visibility = Visible
                        end
                    end
                end
            end
        end
    end
    
    if Closest and Choice then
        if Choice == "dst" then
            return Distance2
        elseif Choice == "cls" then
            return Closest
        elseif Choice == "vis" then
            return Visibility
        end
    end
end

function CompareVector3(Comparison, ComparisonTwo)
    if Comparison.Y < ComparisonTwo.Y then
        return true
    end
    if Comparison.X < ComparisonTwo.X then
        return true
    end
    if Comparison.Z < ComparisonTwo.Z then
        return true
    end
    return false
end
local OldVelocity = Vector3.new(24,3,2)
game:GetService('RunService').Heartbeat:Connect(function()
    if settings.AntiLock == true then
        OldVelocity = game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity
        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = OldVelocity * 0
        game:GetService('RunService').RenderStepped:Wait()
        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = OldVelocity
    end
end)
game:GetService("RunService").RenderStepped:connect(function(deltatime)
    if settings.Executed == true then
	    UniversalDeltaTime = deltatime
	    settings.Target = ClosestPlr(settings.HitPart, 'cls')
	    updateFOV()
	    updateTracer()
    end
end)
local OldTargetPos = Vector3.new(2,2,2)
function LoadSilent()
    LocalPlayer.Character.ChildAdded:Connect(function(tool)
        if tool:IsA('Tool') then print('found da tool')
            tool.Activated:Connect(function() print('PEW')
    			if settings.Target ~= nil then print('thers a target!')
    				if settings.Resolver == true then
    					if settings.ResolveMode == "MoveDirection" then
    						if settings.Target.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
    							TargetLock = (closestpoint(settings.Target) + (settings.Target.Parent.Humanoid.MoveDirection * settings.Target.Parent.Humanoid.WalkSpeed) * settings.Prediction + Vector3.new(0, settings.JumpOffset, 0))
    						else 
    							TargetLock = (closestpoint(settings.Target) + (settings.Target.Parent.Humanoid.MoveDirection * settings.Target.Parent.Humanoid.WalkSpeed) * settings.Prediction)
    						end
    					elseif settings.ResolveMode == "Calculate" then
    						local CalculatedVelocity = Calculate(OldTargetPos, closestpoint(settings.Target), UniversalDeltaTime)
    						if CalculatedVelocity.Y < settings.AntiGroundValue then
    							if settings.Target.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
    								TargetLock = (closestpoint(settings.Target) + Vector3.new(CalculatedVelocity.X, 0, CalculatedVelocity.Z) * settings.Prediction + Vector3.new(0, settings.JumpOffset, 0))
    							else 
    								TargetLock = (closestpoint(settings.Target) + Vector3.new(CalculatedVelocity.X, 0, CalculatedVelocity.Z) * settings.Prediction)
    							end
    						elseif CalculatedVelocity.Y > settings.AntiGroundValue then
    							if settings.Target.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
    								TargetLock = (closestpoint(settings.Target) + CalculatedVelocity * settings.Prediction + Vector3.new(0, settings.JumpOffset, 0))
    							else 
    								TargetLock = (closestpoint(settings.Target) + CalculatedVelocity * settings.Prediction)
    							end
    						end
    						OldTargetPos = closestpoint(settings.Target)
    					end
    				elseif settings.Resolver == false then
    					if settings.Target.Velocity.Y < settings.AntiGroundValue then
    						if settings.Target.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
    							TargetLock = (closestpoint(settings.Target) + Vector3.new(settings.Target.Velocity.X, 0, settings.Target.Velocity.Z) * settings.Prediction + Vector3.new(0, settings.JumpOffset, 0))
    						else 
    							TargetLock = (closestpoint(settings.Target) + Vector3.new(settings.Target.Velocity.X, 0, settings.Target.Velocity.Z) * settings.Prediction)
    						end
    					elseif settings.Target.Velocity.Y > settings.AntiGroundValue then
    						if settings.Target.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
    							TargetLock = (closestpoint(settings.Target) + settings.Target.Velocity * settings.Prediction + Vector3.new(0, settings.JumpOffset, 0))
    						else 
    							TargetLock = (closestpoint(settings.Target) + settings.Target.Velocity * settings.Prediction)
    						end
    					end
    				end
					if settings.AutoResolver == true then
					    if CompareVector3(settings.AutoResolverLimit, settings.Target.Velocity) then
					    	local CalculatedVelocity = Calculate(OldTargetPos, closestpoint(settings.Target), UniversalDeltaTime)
    				    	if CalculatedVelocity.Y < settings.AntiGroundValue then
    				    		if settings.Target.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
    				    			TargetLock = (closestpoint(settings.Target) + Vector3.new(CalculatedVelocity.X, 0, CalculatedVelocity.Z) * settings.Prediction + Vector3.new(0, settings.JumpOffset, 0))
    				    		else 
    				    			TargetLock = (closestpoint(settings.Target) + Vector3.new(CalculatedVelocity.X, 0, CalculatedVelocity.Z) * settings.Prediction)
    				    		end
    				    	elseif CalculatedVelocity.Y > settings.AntiGroundValue then
    				    		if settings.Target.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
    				    			TargetLock = (closestpoint(settings.Target) + CalculatedVelocity * settings.Prediction + Vector3.new(0, settings.JumpOffset, 0))
    				    		else 
    				    			TargetLock = (closestpoint(settings.Target) + CalculatedVelocity * settings.Prediction)
    				    		end
    				    	end
    				    	OldTargetPos = closestpoint(settings.Target)
    				    end
					end
    				game:GetService("ReplicatedStorage").MainEvent:FireServer("UpdateMousePosI", TargetLock)
                	game:GetService("ReplicatedStorage").MainEvent:FireServer("UpdateMousePos", TargetLock)
                    print('redirected..')
				end
            end)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newchar)
    Character = newchar
    game:GetService('StarterGui'):SetCore("ResetButtonCallback", true)
    LoadSilent()
end)
    
LoadSilent()
settings.Executed = true
