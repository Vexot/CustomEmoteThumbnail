--!strict
local MainPath = script.Parent.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local ThumbnailUtil = require(MainPath.Util.Thumbnail)
local Character = require(MainPath.Util.Character)
local GeneralData = require(MainPath.GeneralData)
local Types = require(MainPath.Types)

local Atoms = MainPath.Components.Atoms
local Camera = require(Atoms.Camera)
local ViewportAtom = require(Atoms.Viewport)

local peek = Fusion.peek

local Viewport = {}
Viewport.__index = Viewport

export type Class = typeof(setmetatable({} :: {
    scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>,
    ui: Fusion.Child,
    world: WorldModel,

    camera: Camera,
    cameraCFrame: Fusion.Value<CFrame>,
    cameraFocus: Fusion.Value<CFrame>,

    -- inhereted from props
    character: Model,
    clip: Types.ClipValue,
    thumbParams: Types.ThumbParams,
}, Viewport))

export type Props = {
    Order: number,
    Character: Model,
    Clip: Types.ClipValue,
    ThumbParams: Types.ThumbParams,
}

function Viewport.new(
    scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>,
    props: Props
): Class
    local innerScope = scope:innerScope(Fusion, Ignite)
    local camCFrame, camFocus = innerScope:Value(CFrame.new()), innerScope:Value(CFrame.new())
    
    local camera = Camera(innerScope, {
        CFrame = camCFrame,
        Focus = camFocus,
    })

    local worldModel, vp = ViewportAtom(innerScope, {
        Order = props.Order,
        Camera = camera,
        Children = {props.Character} :: any,
        Enabled = innerScope:Computed(function(use)
            return use(props.Clip)~=nil
        end),
    })

    Character.setViewportCharacter(props.Character)

    return setmetatable({
        ui = vp,
        world = worldModel :: WorldModel,

        camera = camera,
        scope = innerScope,

        character = props.Character,
        clip = props.Clip,
        thumbParams = props.ThumbParams,

        cameraCFrame = camCFrame,
        cameraFocus = camFocus,
    }, Viewport)
end

function Viewport.refresh(self: Class)
    local char = self.character
    if not char then return end

    local clip, thumbParams = peek(self.clip), self.thumbParams
    Character.applyPose(clip, thumbParams)
end

function Viewport.updateCamera(self: Class)
    local char = self.character
    if not char then return end

    local thumbParams = self.thumbParams
    task.delay(nil, function()
        local folderHack = Instance.new("Folder")
            folderHack.Parent = char
            folderHack:Destroy()

        local modelCFrame = char:GetPivot() :: CFrame
        local thumbHorzOffset, thumbVertOffset, thumbZoom =
            peek(thumbParams['HorizontalOffset' :: any]),
            peek(thumbParams['VerticalOffset' :: any]),
            peek(thumbParams['Zoom' :: any])

        local thumbnailCameraCFrame = ThumbnailUtil.ThumbnailZoomExtents(
            char, GeneralData.CameraFOV,
            thumbHorzOffset, thumbVertOffset,
            thumbZoom
        )

        self.cameraCFrame:set(thumbnailCameraCFrame)
        self.cameraFocus:set(modelCFrame)
    end)
end

return Viewport