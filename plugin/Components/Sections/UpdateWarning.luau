--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local Localization = require(MainPath.Util.Localization)

local Children = Fusion.Children

export type Props = {
    Order: number?,
    Visible: Fusion.UsedAs<boolean>?,
}

return function(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props)
    return scope:EmbeddedContainer {
        Name = script.Name,
        LayoutOrder = props.Order or 0,
        Visible = props.Visible,
        BackgroundColor3 = scope:GetThemeItem('Accent/Primary' :: any, 'Default' :: any),

        Size = UDim2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,

        StrokeBottom = true,
        StrokeTop = true,

        [Children] = {
            scope:PaddingLarge {},

            scope:TextLabel {
                Size = UDim2.fromScale(1, 0),
                AutomaticSize = Enum.AutomaticSize.Y,

                Focus = 'Title' :: any,
                Text = `<b>{Localization.get('warning_update')}</b>`,
                TextColor3 = scope:GetThemeItem('Text/Title' :: any, 'Default' :: any),

                TextSize = 20,
                RichText = true,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Center,
            },
        },
    }
end
