--!strict
local MainPath = script.Parent.Parent.Parent
local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Out = Fusion.Out
local peek = Fusion.peek

type scope = Fusion.Scope<typeof(Fusion) & typeof(Ignite)>
type Props = {
    Min: Fusion.UsedAs<number>,
    Max: Fusion.UsedAs<number>,
    Step: Fusion.UsedAs<number>?,

    ProgressValue: Fusion.Value<number>,
    OnUpdate: (number) -> (),

    Visible: Fusion.Value<boolean>?,
    ZIndex: number?,
    Order: number?,
}

local function getConstrainedValue(progress: number, min: number, max: number, step: number?): number
    local rawValue = min + (max - min) * progress
    
    local constrainedValue = rawValue
    if step and step > 0 then
        constrainedValue = math.round(rawValue / step) * step
    end
    
    return math.clamp(constrainedValue, min, max)
end

local function MoveDragger(
    progressPercentState: Fusion.Value<number>, sliderAbsSizeState: Fusion.Value<Vector2>,
    sliderAbsPosState: Fusion.Value<Vector2>, mousePosXState: Fusion.Value<number>,
    min: Fusion.UsedAs<number>, max: Fusion.UsedAs<number>, step: Fusion.UsedAs<number>?
)
    return function(x: number?)
        local sliderAbsWidth = (peek(sliderAbsSizeState) or Vector2.zero).X
        local sliderAbsPosX = (peek(sliderAbsPosState) or Vector2.zero).X

        local relPosX = math.clamp(
            ((x or peek(mousePosXState)) - sliderAbsPosX) / sliderAbsWidth,
            0, 1
        )
        
        local minVal: number = peek(min)
        local maxVal: number = peek(max)
        local stepVal: number? = step and peek(step) or nil
        
        local constrainedValue = getConstrainedValue(relPosX, minVal, maxVal, stepVal)
        local finalProgress = (constrainedValue - minVal) / (maxVal - minVal)
        progressPercentState:set(finalProgress)
    end
end

local function OnDraggerMove(
    scope: scope, sliderRef: Fusion.Value<ImageButton>,
    moveDragger: (x: number?) -> nil, isHolding: Fusion.Value<boolean>,
    overrideProgress: Fusion.Value<number>, onUpdate: (number) -> (),
    min: Fusion.UsedAs<number>, max: Fusion.UsedAs<number>, step: Fusion.UsedAs<number>?
)
    return function()
        isHolding:set(true)
        moveDragger()

        local removeUpdateDraggerPosConn = scope:AddRootEvent("MouseMoved", moveDragger)
        local removeStopDraggingConn: () -> nil,
            draggerButton1UpConn: RBXScriptConnection,
            pluginMouseMoveConn: RBXScriptConnection = nil, nil, nil

        local function stopDragging()
            isHolding:set(false)

            local constrainedValue = getConstrainedValue(
                peek(overrideProgress), peek(min), peek(max),
                step and peek(step) or nil
            )

            onUpdate(constrainedValue)

            removeStopDraggingConn()
            draggerButton1UpConn:Disconnect()
            pluginMouseMoveConn:Disconnect()
            removeUpdateDraggerPosConn()
        end

        draggerButton1UpConn = peek(sliderRef).MouseButton1Up:Connect(stopDragging)
        removeStopDraggingConn = scope:AddRootEvent("InputEnded", stopDragging)
        pluginMouseMoveConn = script:FindFirstAncestorOfClass("Plugin"):GetMouse().Move:Connect(stopDragging)
    end
end

return function(scope: scope, props: Props)
    local isHolding = scope:Value(false)
    local mousePosXState = scope:Value(0)
    local overrideProgress = scope:Value(0)

    local sliderRef = scope:Value(nil)
    local sliderAbsSizeState, sliderAbsPosState = scope:Value(Vector2.zero), scope:Value(Vector2.zero)

    local moveDragger = MoveDragger(
        overrideProgress, sliderAbsSizeState,
        sliderAbsPosState, mousePosXState,
        props.Min, props.Max, props.Step
    )
    
    local displayProgress = scope:Computed(function(use)
        if use(isHolding) then
            return use(overrideProgress)
        else
            local currentValue = use(props.ProgressValue)
            local minVal, maxVal: number = use(props.Min), use(props.Max)
            return (currentValue - minVal) / (maxVal - minVal)
        end
    end)

    if props.Visible and typeof(props.Visible) == "table" then
        scope:Observer(props.Visible):onChange(function()
            if not peek(props.Visible) and peek(isHolding) then
                isHolding:set(false)
            end
        end)
    end
    
    local mainColor = Ignite.GetThemeItem(scope, 'Accent/Primary', 'Highlight')
    local main = scope:New "ImageButton" {
        Name = 'Main',
        ImageTransparency = 1,

        Size = UDim2.new(1, -10, 0, 6),
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5),

        BackgroundTransparency = .5,
        BackgroundColor3 = mainColor,

        [Out "AbsoluteSize"] = sliderAbsSizeState,
        [Out "AbsolutePosition"] = sliderAbsPosState,

        [OnEvent "MouseButton1Down"] = OnDraggerMove(scope, sliderRef :: any, moveDragger, isHolding, overrideProgress, props.OnUpdate, props.Min, props.Max, props.Step),
        [OnEvent "MouseMoved"] = function(x: number) mousePosXState:set(x) end,

        [Children] = {
            scope:New "UICorner" {
                CornerRadius = UDim.new(1, 0),
            },

            scope:New 'Frame' {
                Name = "Track",
                ZIndex = 2,
                BackgroundColor3 = mainColor,

                Size = UDim2.fromOffset(9, 9),
                AnchorPoint = Vector2.new(.5, .5),
                Position = scope:Spring(scope:Computed(function(use)
                    return UDim2.fromScale(use(displayProgress), .5)
                end), 30, 1),

                [Children] = {
                    scope:New 'UICorner' {
                        CornerRadius = UDim.new(1, 0),
                    },

                    scope:New 'UIStroke' {
                        Color = Color3.new(1,1,1),
                        Thickness = 1.5,
                    }
                }
            },

            scope:New "Frame" {
                Name = "Progress",
                BackgroundColor3 = mainColor,
                Size = scope:Spring(scope:Computed(function(use)
                    return UDim2.fromScale(use(displayProgress), 1)
                end), 30, 1),

                [Children] = scope:New "UICorner" {
                    CornerRadius = UDim.new(1, 0),
                },
            },
        }
    }

    sliderRef:set(main)
    return scope:New 'Frame' {
        Name = script.Name,
        ZIndex = props.ZIndex or 1,
        LayoutOrder = props.Order or 0,
        BackgroundTransparency = 1,
        Visible = props.Visible or true,
        Size = UDim2.new(1, 0, 0, 12),

        [Children] = main,
    }
end
