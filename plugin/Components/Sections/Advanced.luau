--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local States = require(MainPath.Util.States)

local Molecules = MainPath.Components.Molecules
local Option = require(Molecules.Option)

type Props = {
    Order: number?,
    Visible: Fusion.UsedAs<boolean>,
}

return function(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props)
    scope = scope:innerScope()

    local built = {}
    for id, val in pairs(States.getParams()) do
        if id=='KeyFrame' or id=='Time' then continue end

        local config = States.getConfig(id)
        table.insert(built, Option(scope, {
            Id = id,
            Min = config and config.Min,
            Max = config and config.Max,
            Step = config and config.Step,
            TrackValue = val,
        }))
    end

    local main = scope:Scrollable {
        Name = script.Name,
        Size = UDim2.fromScale(1, 0),
        LayoutOrder = props.Order or 0,
        Visible = props.Visible,

        [Fusion.Children] = {
            scope:New "UIPadding" {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            },

            scope:New "UIListLayout" {
                SortOrder = Enum.SortOrder.Name,
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 10),
            },

            built :: any,
        },
    }

    scope:New 'UIFlexItem' {
        FlexMode = Enum.UIFlexMode.Fill,
        Parent = main,
    }

    return main
end