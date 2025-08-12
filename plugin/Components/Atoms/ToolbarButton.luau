--!strict
local MainPath = script.Parent.Parent.Parent
local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local peek = Fusion.peek
local OnChange = Fusion.OnChange

export type Props = {
    ButtonData: {
        Id: string,
        IconAsset: string,
        ToolTip: string,
        Text: string,
    },
    
    Plugin: Plugin,
    Toolbar: PluginToolbar,
    DockWidget: DockWidgetPluginGui?,

    WidgetEnabled: Fusion.Value<boolean>,
}

return function(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props): PluginToolbarButton
    local btnData = props.ButtonData
    local button = props.Toolbar:CreateButton(btnData.Id, btnData.ToolTip, btnData.IconAsset, btnData.Text) :: PluginToolbarButton

    local function update()
        local newValue = not peek(props.WidgetEnabled)
        props.WidgetEnabled:set(newValue)
        button:SetActive(newValue)
    end

    if props.DockWidget then
        scope:Hydrate(props.DockWidget) {
            Enabled = props.WidgetEnabled,
            [OnChange 'Enabled'] = function(newValue)
                if newValue == peek(props.WidgetEnabled) then return end
                update()
            end,
        }
    end

    table.insert(scope, button.Click:Connect(update))
    table.insert(scope, button)
    return button
end