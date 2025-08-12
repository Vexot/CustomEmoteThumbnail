--!strict
local MainPath = script.Parent.Parent.Parent
local Fusion = require(MainPath.Packages.Fusion)
local GeneralData = require(MainPath.GeneralData)

export type Props = {
    Size: Fusion.UsedAs<UDim2>,
    AnchorPoint: Vector2?,
    Position: UDim2?,
    Transparency: Fusion.UsedAs<number>?,
}

return function(scope: Fusion.Scope<Fusion.Fusion>, props: Props)
    return scope:New "ImageLabel" {
        Name = script.Name,
        BackgroundTransparency = 1,
        ZIndex = -1,

        AnchorPoint = props.AnchorPoint or Vector2.new(.5, .5),
        Position = props.Position or UDim2.fromScale(.5, .5),
        Size = props.Size,

        Image = "rbxassetid://14327341766",
        ImageTransparency = props.Transparency or .9,
    }
end