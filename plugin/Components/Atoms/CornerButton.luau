
--!strict
local RunService = game:GetService('RunService')
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local GeneralData = require(MainPath.GeneralData)
local SimpleShadow = require(script.Parent.SimpleShadow)

local OnEvent = Fusion.OnEvent

export type Props = {
    Id: string,
    Increase: boolean,
    Icon: string,
    OnPress: (boolean) -> (),

    Size: UDim2,
    Position: UDim2,
    AnchorPoint: Vector2,
    Order: number?,
}

return function (scope: Fusion.Scope<Fusion.Fusion>, props: Props)
    local hovered, pressed = scope:Value(false), scope:Value(false)
    local holdConnection: RBXScriptConnection?, holdStartTime: number?

    local function stopHold()
        holdStartTime = nil
        holdConnection = holdConnection and holdConnection:Disconnect() or nil
    end
    table.insert(scope, stopHold)

    local function startHold()
        holdStartTime = tick()
        props.OnPress(props.Increase)
        if holdConnection then return end

        local lastRepeatTime = 0
        holdConnection = RunService.Heartbeat:Connect(function()
            if not holdStartTime then return end
            
            local elapsedTime = tick() - holdStartTime
            if elapsedTime < GeneralData.HoldThreshold then return end
            
            local timeSinceLastRepeat = elapsedTime - lastRepeatTime
            if timeSinceLastRepeat < GeneralData.RepeatInterval then return end

            props.OnPress(props.Increase)
            lastRepeatTime = elapsedTime
        end)
    end
    
    return scope:New "ImageButton" {
        Name = `{props.Id}_{props.Increase and 'Increase' or 'Decrease'}`,
        ImageTransparency = 1,
        LayoutOrder = props.Order or 0,
        BackgroundTransparency = 1,

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
                Name = "Icon",
                ZIndex = 2,
                BackgroundTransparency = 1,

                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.fromScale(.5, .5),
                Size = UDim2.fromScale(.7, .7),

                ScaleType = Enum.ScaleType.Fit,
                Image = props.Icon,
                ImageTransparency = scope:Spring(scope:Computed(function(use)
                    return (use(pressed) and .05) or (use(hovered) and .2) or .4
                end), 15, 1),
                ImageColor3 = Ignite.GetThemeItem(scope, scope:Computed(function(use)
                    return use(pressed) and 'Accent/Primary' or 'Text/Title'
                end) :: Fusion.UsedAs<any>, 'Highlight'),
            },

            SimpleShadow(scope, {
                Size = scope:Spring(scope:Computed(function(use)
                    local s = use(pressed) and 1.5 or 1.3
                    return UDim2.fromScale(s, s)
                end), 10, 1),
                Transparency = scope:Computed(function(use)
                    return (not use(pressed) and use(hovered)) and .75 or .9
                end),
            })
        }
    }
end