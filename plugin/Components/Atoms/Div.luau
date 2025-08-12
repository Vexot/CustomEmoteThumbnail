
--!strict
local MainPath = script.Parent.Parent.Parent
local Fusion = require(MainPath.Packages.Fusion)

export type Props = {
    Order: number,
    Visible: Fusion.UsedAs<boolean>?,
}

return function(scope: Fusion.Scope<Fusion.Fusion>, props: Props)
    return scope:New 'Frame' {
        Name = 'Div',
        LayoutOrder = props.Order or 0,
        BackgroundTransparency = .5,
        Size = UDim2.new(1, 0, 0, 1),
        Visible = props.Visible or true,
    }
end

