--!strict
if not plugin then error('Code must be run in a plugin context') end

local Components, Util, Packages = script.Components, script.Util, script.Packages

local GeneralData = require(script.GeneralData)
local Types = require(script.Types)

local Fusion = require(Packages.Fusion)
local Ignite = require(Packages.Ignite)

local Children = Fusion.Children
local MainScope = Fusion.scoped(Fusion, Ignite)

-- Init
local SectionIndex = MainScope:Value(1)
local WidgetEnabled = MainScope:Value(false)

local Localization = require(Util.Localization)
local Character = require(Util.Character)

local CharacterModel = Character.createCharacter()
if not CharacterModel then error("Failed to create character model") end

local Versioning = require(Util.Versioning)
local UpToDate = Versioning.checkForUpdate()

local States = require(Util.States)
States.init(MainScope, Character.refresh)

local Clip = require(Util.Clip)
Clip.init(MainScope, WidgetEnabled)

local Viewport = require(Components.Molecules.Viewport).new(MainScope, {
    Order = 2,
    Clip = Clip.getClip() :: Types.ClipValue,
    Character = CharacterModel,
    ThumbParams = States.getParams(),
})

table.insert(MainScope, CharacterModel)

local Actions = require(Components.Sections.Actions)
local UpdateWarning = require(Components.Sections.UpdateWarning)
local FrameSlider = require(Components.Molecules.FrameSlider)
local SimplifiedSection = require(Components.Sections.Simplified)
local AdvancedSection = require(Components.Sections.Advanced)

local Div = require(Components.Atoms.Div)
local ToolbarButton = require(Components.Atoms.ToolbarButton)
local Toolbar = plugin:CreateToolbar(GeneralData.LongName)

local HasClip = MainScope:Computed(function(use)
    local c = Clip.getClip() :: Types.ClipValue
    return use(c)~=nil
end)

local Widget = MainScope:Widget {
    Id = GeneralData.ShortName,
    Title = Localization.get("plugin_name"),

    InitEnabled = false,
    OverrideEnabledRestore = true,
    InitDockState = Enum.InitialDockState.Left,
    FloatXSize = 1_000, FloatYSize = 1_000,
    --MinWidth = 200, MinHeight = 500,

    [Children] = {
        MainScope:New 'UIListLayout' {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 10),
        },

        MainScope:PaddingLarge {},

        UpdateWarning(MainScope, {
            Order = -1,
            Visible = UpToDate,
        }),

        Actions(MainScope, {
            Order = 0,
            Clip = Clip.getClip() :: Types.ClipValue,
        }),

        Viewport.ui :: any,

        FrameSlider(MainScope, {
            Order = 2,
            Visible = HasClip,
        }),

        Div(MainScope, {
            Order = 3,
            Visible = HasClip,
        }),

        MainScope:EmbeddedContainer {
            Size = UDim2.new(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 3,

            StrokeBottom = true,
            StrokeTop = true,
            Visible = MainScope:Computed(function(use)
                return not use(HasClip)
            end),

            [Children] = {
                MainScope:PaddingLarge {},

                MainScope:TextLabel {
                    Size = UDim2.new(1, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,

                    Focus = 'Title' :: any,
                    Text = Localization.get("warning_earlyaccess"),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextWrapped = true,
                    RichText = true,
                },
            }
        },

        MainScope:Tabs {
            Visible = HasClip,
            LayoutOrder = 4,
            ActiveSection = SectionIndex,
            Sections = {
                { Text = Localization.get("view_simplified") },
                { Text = Localization.get("view_advanced") },
            },
        },

        SimplifiedSection(MainScope, {
            Order = 5,
            Visible = MainScope:Computed(function(use)
                return use(HasClip) and use(SectionIndex) == 1
            end),
        }),

        AdvancedSection(MainScope, {
            Order = 5,
            Visible = MainScope:Computed(function(use)
                return use(HasClip) and use(SectionIndex) == 2
            end),
        }),
    }
} :: DockWidgetPluginGui

Widget.Name = GeneralData.LongName
Character.init(MainScope, Viewport)

local _Button = ToolbarButton(MainScope, {
    ButtonData = {
        Id = `{GeneralData.ShortName}_Toggle`,
        IconAsset = 'rbxassetid://132168702849533',
        ToolTip = Localization.get("plugin_btnTooltip"),
        Text = Localization.get("plugin_btn"),
    },
    Plugin = plugin,
    Toolbar = Toolbar,
    DockWidget = Widget,
    WidgetEnabled = WidgetEnabled,
})

Character.refresh()
plugin.Unloading:Connect(function() MainScope:doCleanup() end)