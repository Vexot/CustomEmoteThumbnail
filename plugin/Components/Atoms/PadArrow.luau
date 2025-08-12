--!strict
local RunService = game:GetService('RunService')
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local Types = require(MainPath.Types)
local GeneralData = require(MainPath.GeneralData)
local States = require(MainPath.Util.States)

local SimpleShadow = require(script.Parent.SimpleShadow)
local OnEvent, peek = Fusion.OnEvent, Fusion.peek

export type Props = {
    Id: Types.ParamValueIds,
    Increase: boolean,

    Size: UDim2,
    Position: UDim2,
    AnchorPoint: Vector2,

    Rotation: number,
    InternalRotation: number?,
}

return function (scope: Fusion.Scope<Fusion.Fusion>, props: Props)
    local hovered, pressed = scope:Value(false), scope:Value(false)
    local holdConnection: RBXScriptConnection?, holdStartTime: number?

    local function increase()
        States.increase(props.Id, GeneralData.PadIncrement * (props.Increase and 1 or -1))
    end
    
    local function stopHold()
        holdStartTime = nil
        holdConnection = holdConnection and holdConnection:Disconnect() or nil
    end
    table.insert(scope, stopHold)

    local function startHold()
        holdStartTime = tick()
        increase()
        if holdConnection then return end

        local lastRepeatTime = 0
        holdConnection = RunService.Heartbeat:Connect(function()
            if not holdStartTime then return end
            
            local elapsedTime = tick() - holdStartTime
            if elapsedTime < GeneralData.HoldThreshold then return end
            
            local timeSinceLastRepeat = elapsedTime - lastRepeatTime
            if timeSinceLastRepeat < GeneralData.RepeatInterval then return end

            increase()
            lastRepeatTime = elapsedTime
        end)
    end
    
    return scope:New "ImageButton" {
        Name = `{props.Id}_{props.Increase and 'Increase' or 'Decrease'}`,
        ImageTransparency = 1,
        BackgroundTransparency = 1,

        Rotation = props.Rotation,
        AnchorPoint = props.AnchorPoint,
        Position = props.Position,
        Size = props.Size,

        [OnEvent 'MouseButton1Up'] = function()
            pressed:set(false)
            hovered:set(false)
            stopHold()
        end,

        [OnEvent 'MouseButton1Down'] = function()
            pressed:set(true)
            startHold()
        end,

        [OnEvent 'MouseEnter'] = function()
            hovered:set(true)
        end,

        [OnEvent 'MouseLeave'] = function()
            hovered:set(false)
            stopHold()
            pressed:set(false)
        end,

        [Fusion.Children] = {
            scope:New "ImageLabel" {
                Name = "Bg",
                ZIndex = 2,
                BackgroundTransparency = 1,
                BackgroundColor3 = Ignite.GetThemeItem(scope, scope:Computed(function(use)
                    return use(pressed) and 'Accent/Primary' or 'Text/Title'
                end) :: Fusion.UsedAs<any>, 'Default'),
                
                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.fromScale(.5, .5),
                Size = UDim2.fromScale(1, 1),
                Rotation = props.InternalRotation or 0,

                ScaleType = Enum.ScaleType.Fit,
                Image = "rbxassetid://98426693706865",
                ImageTransparency = scope:Spring(scope:Computed(function(use)
                    return (use(pressed) and .05) or (use(hovered) and .1) or .5
                end), 15, 1),
                ImageColor3 = Ignite.GetThemeItem(scope, scope:Computed(function(use)
                    return use(pressed) and 'Accent/Primary' or 'Text/Title'
                end) :: Fusion.UsedAs<any>, 'Highlight'),
            },

            SimpleShadow(scope, {
                Size = scope:Spring(scope:Computed(function(use)
                    local s = use(pressed) and 2.2 or 1.5
                    return UDim2.fromScale(s+.2, s)
                end), 10, 1),
                Transparency = scope:Computed(function(use)
                    return (use(pressed) and .6) or (use(hovered) and .45) or .8
                end),
            })
        }
    }
end