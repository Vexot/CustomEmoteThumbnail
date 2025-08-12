--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local Molecules = MainPath.Components.Molecules
local DynamicPad = require(Molecules.DynamicPad)

type Props = {
    Order: number?,
    Visible: Fusion.UsedAs<boolean>,
}

return function(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props)
    scope = scope:innerScope()

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
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 10),
            },

            DynamicPad(scope, {
                Position = UDim2.fromScale(.5, .5),
                AnchorPoint = Vector2.new(.5, .5),
            }),
        },
    }

    scope:New 'UIFlexItem' {
        FlexMode = Enum.UIFlexMode.Fill,
        Parent = main,
    }

    return main
end