--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local peek = Fusion.peek

local Types = require(MainPath.Types)
local Localization = require(MainPath.Util.Localization)
local States = require(MainPath.Util.States)
local Clip = require(MainPath.Util.Clip)

local Atoms = MainPath.Components.Atoms
local Slider = require(Atoms.Slider)
local CornerButton = require(Atoms.CornerButton)

export type Props = {
    Order: number?,
    Visible: Fusion.UsedAs<boolean>,
}

return function( scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props)
    local clipData = Clip.getAll()

    local timeValue, keyframeValue = States.getState('Time'), States.getState('KeyFrame')

    local function increase(increase: boolean)
        local currId = peek(clipData.IsCurve) and 'Time' or 'KeyFrame'
        States.increase(currId :: any, (peek(clipData.Step) or 1) * (increase and 1 or -1))
    end

    return scope:New 'Frame' {
        Name = script.Name,
        LayoutOrder = props.Order or 0,
        BackgroundTransparency = 1,
        Visible = props.Visible,

        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,

        [Fusion.Children] = {
            scope:New 'UIListLayout' {
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 2)
            },

            scope:New 'Frame' {
                Name = 'Title',
                LayoutOrder = 1,
                Size = UDim2.fromScale(1, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,

                [Fusion.Children] = {
                    scope:New 'UIListLayout' {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
                    },

                    CornerButton(scope, {
                        Id = '',
                        Icon = 'rbxassetid://95121442047920',
                        Increase = false,
                        OnPress = increase,

                        Order = 1,
                        Size = UDim2.fromOffset(25, 25),
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.new(),
                    }),

                    scope:TextLabel {
                        Text = scope:Computed(function(use)
                            local step: number = use(clipData.Step)
                            local min: number = use(clipData.Min)
                            local max: number = use(clipData.Max)

                            local isCurve = use(clipData.IsCurve)
                            local t, kf = use(timeValue), use(keyframeValue)
                            local current: number = if isCurve then t else kf

                            local totalSteps = step > 0 and math.floor((max - min) / step) + 1 or 1
                            local currentStep = step > 0 and math.floor((current - min) / step) + 1 or 1
                            
                            return Localization.get(
                                "value_keyframe",
                                { current = currentStep, total = totalSteps }
                            )
                        end),
                        Focus = 'Title' :: any,
                        LayoutOrder = 2,
                        ZIndex = 2,
                    },

                    CornerButton(scope, {
                        Id = '',
                        Icon = 'rbxassetid://86697034162336',
                        Increase = true,
                        OnPress = increase,

                        Order = 3,
                        Size = UDim2.fromOffset(25, 25),
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.new(),
                    }),
                }
            },

            Slider(scope, {
                Order = 2,
                ZIndex = 2,
                Visible = props.Visible :: any,

                Min = clipData.Min :: any,
                Max = clipData.Max :: any,
                Step = clipData.Step :: any,

                ProgressValue = scope:Computed(function(use)
                    local isCurve = use(clipData.IsCurve)
                    local time = use(States.getState('Time'))
                    local keyframe = use(States.getState('KeyFrame'))
                    return isCurve and time or keyframe
                end) :: any,
                
                OnUpdate = function(new: number)
                    local isCurve = Fusion.peek(clipData.IsCurve)
                    States.set((isCurve and 'Time' or 'KeyFrame') :: Types.ParamValueIds, new)
                end :: any,
            })
        }
    }
end