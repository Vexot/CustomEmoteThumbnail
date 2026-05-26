--!strict
local InsertService = game:GetService 'InsertService'

local MainPath = script.Parent.Parent
local Fusion = require(MainPath.Packages.Fusion)

local ThumbnailUtil = require(MainPath.Util.Thumbnail)
local GeneralData = require(MainPath.GeneralData)
local Types = require(MainPath.Types)

local Clip = require(script.Parent.Clip)
local States = require(script.Parent.States)

local Template = script:WaitForChild 'Mannequin'

local Character = {}

local viewportCharacter: Model? = nil
local viewportInstance: any = nil

function Character.createCharacter(desiredColor: Color3?): Model?
    local defaultColor = desiredColor or Color3.new(1, 1, 1)
    local character = Template:Clone()
    
    for _, remove in character:QueryDescendants('Accessory,SurfaceAppearance,Decal,Texture') do
        remove:Destroy()
    end

    for _, part in character:QueryDescendants('BasePart') do
        if part:IsA("MeshPart") then
            local fixedId = GeneralData.FixMeshIds[part.Name] :: string?
            if fixedId then
                local mesh = InsertService:CreateMeshPartAsync(
                    fixedId, Enum.CollisionFidelity.Default,
                    Enum.RenderFidelity.Precise
                )

                part:ApplyMesh(mesh)
            end

            part.TextureID = ''
        end
        
        part.Color = defaultColor
    end
    
    return character
end

function Character.setViewportCharacter(character: Model?)
    viewportCharacter = character
end

function Character.applyPose(clip: Types.Clip?, thumbParams: Types.ThumbParams?)
    if not viewportCharacter or not thumbParams then return end
    
    local thumbKeyframe = Fusion.peek(thumbParams["KeyFrame" :: Types.ParamValueIds])
    local thumbTime = Fusion.peek(thumbParams["Time" :: Types.ParamValueIds])
    local charRotation = Fusion.peek(thumbParams["Rotation" :: Types.ParamValueIds])
    
    local keyFrame = clip and (
        (clip:IsA('CurveAnimation') and ThumbnailUtil.GetThumbnailKeyframeFromCurve(thumbTime, clip, charRotation))
        or (clip:IsA('KeyframeSequence') and ThumbnailUtil.GetThumbnailKeyframe(thumbKeyframe, clip, charRotation))
    ) or nil
    
    ThumbnailUtil.SetPlayerCharacterNeutralPose(viewportCharacter)
    if keyFrame and typeof(keyFrame) == "Instance" and keyFrame:IsA("Keyframe") then
        ThumbnailUtil.ApplyKeyframe(viewportCharacter, keyFrame)
    end
    
    if viewportInstance and viewportInstance.updateCamera then
        task.defer(function()
            viewportInstance:updateCamera()
        end)
    end
end

function Character.init(scope: Fusion.Scope<any>, viewport: any?)
    viewportInstance = viewport
end

function Character.refresh()
    local currentClip = Clip.getClip() and Fusion.peek(Clip.getClip())
    local currentParams = States.getParams()
    
    Character.applyPose(currentClip, currentParams)
end

function Character.cleanup()
    viewportCharacter = nil
    viewportInstance = nil
end

return Character
