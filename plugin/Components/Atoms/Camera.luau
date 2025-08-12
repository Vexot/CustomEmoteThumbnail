--!strict
local MainPath = script.Parent.Parent.Parent
local Fusion = require(MainPath.Packages.Fusion)
local GeneralData = require(MainPath.GeneralData)

export type Props = {
    CFrame: Fusion.Value<CFrame>?,
    Focus: Fusion.UsedAs<CFrame>?,
}

return function(scope: Fusion.Scope<Fusion.Fusion>, props: Props): Camera
    return scope:New 'Camera' {
        Name = script.Name,

        CameraType = Enum.CameraType.Scriptable,
        FieldOfView = GeneralData.CameraFOV,

        CFrame = props.CFrame,
        Focus = props.Focus,
    } :: Camera
end