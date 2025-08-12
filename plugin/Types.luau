--!strict
local Main = script.Parent
local Fusion = require(Main.Packages.Fusion)

export type Clip = CurveAnimation|KeyframeSequence|nil
export type ClipValue = Fusion.Value<Clip>

export type ParamValueIds = 'Time' | 'KeyFrame' | 'Rotation' | 'HorizontalOffset' | 'VerticalOffset' | 'Zoom'
export type ThumbParams = { [ParamValueIds]: Fusion.Value<number> }

return nil