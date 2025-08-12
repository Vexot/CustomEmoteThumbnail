--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local Types = require(MainPath.Types)
local Localization = require(MainPath.Util.Localization)
local States = require(MainPath.Util.States)
local Clip = require(MainPath.Util.Clip)

local OnEvent = Fusion.OnEvent

export type Props = {
    Order: number?,
    Clip: Types.ClipValue,
}

return function(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props)
    return scope:New 'Frame' {
        Name = script.Name,
        LayoutOrder = props.Order or 0,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

        [Fusion.Children] = {
            scope:New 'UIListLayout' {
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 10)
            },
			
            scope:Button {
                LayoutOrder = 1,
                Width = UDim.new(1, 0),
                Content = {'rbxassetid://95004125288022', Localization.get("action_resetParams")},
                Variant = 'Destructive' :: any,

                [OnEvent 'MouseButton1Up'] = function()
                    States.resetAll()
                end
            },

            scope:Button {
                LayoutOrder = 2,
                Width = UDim.new(1, 0),
                Content = {'rbxassetid://4458874645', Localization.get("action_save")},
                Variant = scope:Computed(function(use)
                    return use(props.Clip) and 'Primary' or 'Secondary'
                end) :: any,

                [OnEvent 'MouseButton1Up'] = function()
                    if not Fusion.peek(props.Clip) then return end
                    Clip.applyToAnim()
                end
            },
        }
    }
end