--!strict
local Players = game:GetService('Players')

local MainPath = script.Parent.Parent
local Fusion = require(MainPath.Packages.Fusion)

local ThumbnailUtil = require(MainPath.Util.Thumbnail)
local GeneralData = require(MainPath.GeneralData)
local Types = require(MainPath.Types)

local Clip = require(script.Parent.Clip)
local States = require(script.Parent.States)

local Character = {}

local viewportCharacter: Model? = nil
local viewportInstance: any = nil

function Character.createCharacter(desiredColor: Color3?): Model?
    local defaultColor = desiredColor or Color3.new(1,1,1)--Color3.fromRGB(162, 162, 162)
    
    local success, humDesc = pcall(function()
        return Players:GetHumanoidDescriptionFromOutfitId(GeneralData.MannequinOutfitId)
    end)
    
    if not success then
        warn(`[{GeneralData.ShortName} - Plugin]: Failed to fetch Roblox's animation rig. Using fallback rig.`)
        if humDesc and humDesc:IsA('HumanoidDescription') then humDesc:Destroy() end
        humDesc = Instance.new('HumanoidDescription')
    end
    
    local character = Players:CreateHumanoidModelFromDescription(humDesc, Enum.HumanoidRigType.R15)
    
    for _, descendant in pairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Parent == character then
            for _, child in pairs(descendant:GetChildren()) do
                if child:IsA("SurfaceAppearance") or child:IsA("Decal") or child:IsA("Texture") then
                    child:Destroy()
                end
            end
            
            if descendant:IsA("MeshPart") then
                descendant.TextureID = ''
            end
            
            descendant.Color = defaultColor
        elseif descendant:IsA("Accessory") then
            descendant:Destroy()
        end
    end
    
    humDesc:Destroy()
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
