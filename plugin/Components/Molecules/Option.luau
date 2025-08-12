--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local States = require(MainPath.Util.States)
local Localization = require(MainPath.Util.Localization)

local peek = Fusion.peek
local Children = Fusion.Children

local Atoms = MainPath.Components.Atoms
local CornerButton = require(Atoms.CornerButton)

export type Props = {
    Min: Fusion.UsedAs<number>?,
    Max: Fusion.UsedAs<number>?,
    Step: Fusion.UsedAs<number>?,

    TrackValue: Fusion.Value<number>,
    Id: string,
}

local function SpaceOut(s: string): string
    local n, r = s:gsub("(%l)(%u)", "%1 %2")
	return r and n
end

return function(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props)
    local isFocus = scope:Value(false)
    local currVal = scope:Value(tostring(peek(props.TrackValue)))

    local updating = false
    local function updateToActual()
        if peek(isFocus) or updating then return end
        updating = true

        local new = peek(props.TrackValue)
        task.defer(function()
            currVal:set(tostring(new))
            task.defer(function()
                updating = false
            end)
        end)
    end

    scope:Observer(isFocus):onChange(function()
        if peek(isFocus) then return end
        local stored = tonumber(peek(currVal))

        task.defer(function()
            if stored then
               States.set(props.Id :: any, stored :: number)
            end
            updateToActual()
        end)
    end)

    scope:Observer(props.TrackValue):onChange(updateToActual) 

    return scope:New 'Frame' {
        Name = props.Id,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,

        [Children] = {
            scope:New 'UIListLayout' {
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 4),
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
                        HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
                    },

                    scope:TextLabel {
                        Text = Localization.get(
                            "param_" .. props.Id:lower()
                        ) or SpaceOut(props.Id),
                        Focus = 'Title' :: any,
                        LayoutOrder = 1,
                        ZIndex = 2,
                    },

                    CornerButton(scope, {
                        Id = '',
                        Icon = 'rbxassetid://95004125288022',
                        Increase = true,
                        OnPress = function() States.reset(props.Id :: any) end,

                        Order = 2,
                        Size = UDim2.fromOffset(25, 25),
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.new(),
                    }),
                }
            },

            scope:TextInput {
                LayoutOrder = 2,
                IsFocus = isFocus,
                Value = currVal :: any,
                Width = UDim.new(1, 0),
                Placeholder = Localization.get(
                    "value_range",
                    { min = peek(props.Min) or '-inf', max = peek(props.Max) or 'inf' }
                ),
                --[[Validation = {
                    Pattern = '^[-+]?%d*%.?%d*$',
                    Mode = 'Restrict',
                } :: any,]]
            },
        }
    }
end