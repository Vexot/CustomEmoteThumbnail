--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local Localization = require(MainPath.Util.Localization)

local Children = Fusion.Children

export type Props = {
    Order: number,
    Camera: Camera,
    Children: Fusion.Child,
    Enabled: Fusion.UsedAs<boolean>,
}

return function(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props)

    local worldModel = scope:New 'WorldModel' {
        [Children] = props.Children,
    }

    return worldModel, scope:New 'Frame' {
        Name = script.Name,
        Size = UDim2.new(1, 0, .5, 0),
        BackgroundColor3 = Color3.fromRGB(43, 45, 51),

        [Children] = {
            scope:New 'UIAspectRatioConstraint' {
                AspectRatio = 1,
                DominantAxis = Enum.DominantAxis.Width,
            },

            scope:New 'UICorner' {
                CornerRadius = UDim.new(0, 8),
            },

            scope:New 'UIStroke' {
                Thickness = 1,
                Transparency = .2,
                Color = Color3.new(1,1,1),
            },

            scope:New 'ViewportFrame' {
                Visible = props.Enabled,

                Size = UDim2.fromScale(1, 1),
                Position = UDim2.fromScale(.5, .5),
                AnchorPoint = Vector2.new(.5, .5),

                CurrentCamera = props.Camera,
                BackgroundTransparency = 1,

			    ImageColor3 = Color3.new(160, 160, 160),
                Ambient = Color3.new(1,1,1),
                LightColor = Color3.new(),

                [Children] = {
                    props.Camera :: Fusion.Child,
                    worldModel,
                }
            },

            scope:New 'TextLabel' {
                Name = 'NotSelected',
                BackgroundTransparency = 1,
                Visible = scope:Computed(function(use)
                    return not use(props.Enabled)
                end),

                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.fromScale(.5, .5),
                Size = UDim2.fromScale(.8, .45),

                Text = Localization.get("warning_selection"),
                TextColor3 = Color3.new(160, 160, 160),
                Font = Enum.Font.Gotham,
                RichText = true,
                TextScaled = true,
                TextWrapped = true,
            }
        }
    }
end