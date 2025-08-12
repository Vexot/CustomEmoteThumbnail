--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local GeneralData = require(MainPath.GeneralData)
local States = require(MainPath.Util.States)

export type Props = {
    Order: number?,
    Position: UDim2?,
    AnchorPoint: Vector2?
}

local Atoms = MainPath.Components.Atoms
local PadArrow, CornerButton = require(Atoms.PadArrow), require(Atoms.CornerButton)

local ArrowSize, ArrowSpacing = UDim2.fromScale(.244, .3), .2
local CornerSize, Middle = UDim2.fromScale(.32, .32), UDim2.fromScale(.5, .5)

return function(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, props: Props)
    local function rotateIncrease(increase: boolean)
        States.increase('Rotation', GeneralData.RotateIncrement * (increase and 1 or -1))
    end

    local function zoomIncrease(increase: boolean)
        States.increase('Zoom', GeneralData.ZoomIncrement * (increase and 1 or -1))
    end

    return scope:New 'Frame' {
        Name = script.Name,
        LayoutOrder = props.Order or 0,
        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 0, 135),
        Position = props.Position or UDim2.new(),
        AnchorPoint = props.AnchorPoint or Vector2.zero,

        [Fusion.Children] = {
            scope:New 'UIAspectRatioConstraint' {
                AspectRatio = 1,
                AspectType = Enum.AspectType.FitWithinMaxSize,
                DominantAxis = Enum.DominantAxis.Height,
            },

            PadArrow(scope, {
                Id = 'VerticalOffset',
                Increase = true,

                Size = ArrowSize,
                Position = Middle - UDim2.fromScale(0, ArrowSpacing/2),
                AnchorPoint = Vector2.new(.5, 1),
                Rotation = 0,
            }),

            PadArrow(scope, {
                Id = 'VerticalOffset',
                Increase = false,

                Size = ArrowSize,
                Position = Middle + UDim2.fromScale(0, ArrowSpacing/2),
                AnchorPoint = Vector2.new(.5, 0),
                
                InternalRotation = 180,
                Rotation = 0,
            }),

            PadArrow(scope, {
                Id = 'HorizontalOffset',
                Increase = true,

                Size = ArrowSize,
                Position = Middle + UDim2.fromScale(ArrowSpacing/2, 0),
                AnchorPoint = Vector2.new(0, .5),
                Rotation = 90,
            }),

            PadArrow(scope, {
                Id = 'HorizontalOffset',
                Increase = false,

                Size = ArrowSize,
                Position = Middle - UDim2.fromScale(ArrowSpacing/2, 0),
                AnchorPoint = Vector2.new(1, .5),
                Rotation = -90,
            }),

            CornerButton(scope, {
                Id = 'Rotation',
                Increase = true,
                OnPress = rotateIncrease,
                Icon = 'rbxassetid://81223258309674',
                
                Size = CornerSize,
                Position = UDim2.fromScale(0, 1),
                AnchorPoint = Vector2.new(0, 1),
            }),

            CornerButton(scope, {
                Id = 'Rotation',
                Increase = false,
                OnPress = rotateIncrease,
                Icon = 'rbxassetid://93697601535785',
                
                Size = CornerSize,
                Position = UDim2.fromScale(1, 1),
                AnchorPoint = Vector2.new(1, 1),
            }),

            CornerButton(scope, {
                Id = 'Zoom',
                Increase = true,
                OnPress = zoomIncrease,
                Icon = 'rbxassetid://100760444512016',
                
                Size = CornerSize,
                Position = UDim2.fromScale(1, 0),
                AnchorPoint = Vector2.new(1, 0),
            }),

            CornerButton(scope, {
                Id = 'Zoom',
                Increase = false,
                OnPress = zoomIncrease,
                Icon = 'rbxassetid://87254847255383',
                
                Size = CornerSize,
                Position = UDim2.new(),
                AnchorPoint = Vector2.zero,
            }),
        }
    }
end