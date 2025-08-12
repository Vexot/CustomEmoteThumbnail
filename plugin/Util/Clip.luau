--!strict
local Selection = game:GetService("Selection")

local MainPath = script.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local Ignite = require(MainPath.Packages.Ignite)

local Thumbnail = require(MainPath.Util.Thumbnail)
local States = require(MainPath.Util.States)

local Types = require(MainPath.Types)
local GeneralData = require(MainPath.GeneralData)

local Clip = {}

local selectedClip: Types.ClipValue? = nil
local isCurve: Fusion.Value<boolean>? = nil

local timeSliderMin: Fusion.Value<number>? = nil
local timeSliderMax: Fusion.Value<number>? = nil
local timeSliderStepInterval: Fusion.Value<number>? = nil

local pluginVisible: Fusion.Value<boolean>? = nil
local selConnection: RBXScriptConnection?

function Clip.updateSliderValues(clip: Types.Clip)
    if not (timeSliderMin and timeSliderMax and timeSliderStepInterval and isCurve) then return end
    
    if not clip then
        timeSliderMin:set(0)
        timeSliderMax:set(1)
        timeSliderStepInterval:set(GeneralData.CurveIncrement)

        isCurve:set(true)
        States.resetAll()

        --if refreshCallback then refreshCallback() end
        return
    end
    
    if clip:IsA("KeyframeSequence") then
        local emoteKeyframes = clip:GetKeyframes()
        timeSliderMin:set(1)
        timeSliderMax:set(#emoteKeyframes)
        timeSliderStepInterval:set(GeneralData.KeyIncrement)

        isCurve:set(false)
        States.reset('KeyFrame')
    elseif clip:IsA("CurveAnimation") then
        local totalTime = Thumbnail.GetCurveAnimationTimeLength(clip)
        local totalIncrements = math.floor(totalTime / GeneralData.CurveIncrement)

        timeSliderMin:set(0)
        timeSliderMax:set(totalIncrements * GeneralData.CurveIncrement)
        timeSliderStepInterval:set(GeneralData.CurveIncrement)

        isCurve:set(true)
        States.reset('Time')
    else
        Clip.updateSliderValues(nil)
        return
    end
    
    --if refreshCallback then refreshCallback() end
end

function Clip.applyToAnim()
    if not selectedClip then return end

    local selected = Selection:Get()
    if #selected > 1 or #selected < 1 then return end

    local selectedInstance = selected[1]
    if not selectedInstance:IsA("Animation") then return end

    local curved = Fusion.peek(isCurve)
    for internal, value in pairs(States.getAllValues()) do
        local fixedId = GeneralData.ParamMapping[internal]
        if not fixedId or (curved and internal=='KeyFrame') or (not curved and internal=='Time') then continue end

        local exists = selectedInstance:FindFirstChild(fixedId)
        if not exists then
            exists = Instance.new("NumberValue")
                exists.Name = fixedId
                exists.Parent = selectedInstance
        end

        exists.Value = value
    end
end

function Clip.applyIfExistent(anim: Animation)
    if not anim then return end

    for internal, fixedId in pairs(GeneralData.ParamMapping) do
        local exists = anim:FindFirstChild(fixedId)
        if not (exists and exists:IsA('NumberValue')) then continue end
        States.set(internal, exists.Value)
    end
end

function Clip.checkSelection()
    if not selectedClip then return end
    
    local selected = Selection:Get()
    
    if #selected == 1 then
        local selectedInstance = selected[1]
        
        if selectedInstance:IsA("Animation") then
            local animationId = selectedInstance.AnimationId
            if animationId and animationId ~= "" then
                local fetched = Thumbnail.GetAnimationClip(selectedInstance) :: Types.Clip?
                selectedClip:set(fetched)

                Clip.updateSliderValues(fetched)
                States.resetAll()

                if fetched then Clip.applyIfExistent(selectedInstance) end
                return
            end
        end
    end
    
    selectedClip:set(nil)
    Clip.updateSliderValues(nil)
end

function Clip.handleVisibility()
    if not pluginVisible then return end

    if Fusion.peek(pluginVisible) then
        if selConnection then return end
        selConnection = Selection.SelectionChanged:Connect(Clip.checkSelection)
        Clip.checkSelection()
    else
        selConnection = selConnection and selConnection:Disconnect() or nil
        Clip.updateSliderValues(nil)
    end
end

function Clip.init(scope: Fusion.Scope<Fusion.Fusion & Ignite.Ignite>, widgetEnabled: Fusion.Value<boolean>)
    pluginVisible = widgetEnabled

    selectedClip = scope:Value(nil)
    isCurve = scope:Value(true)

    timeSliderMin = scope:Value(0)
    timeSliderMax = scope:Value(1)
    timeSliderStepInterval = scope:Value(GeneralData.CurveIncrement)

    table.insert(scope, function()
        if not selConnection then return end
        selConnection = selConnection:Disconnect()
    end)

    scope:Observer(widgetEnabled):onChange(function()
        task.defer(Clip.handleVisibility)
    end)
    Clip.handleVisibility()
end

function Clip.getAll()
    return {
        Clip = selectedClip,
        Min = timeSliderMin,
        Max = timeSliderMax,
        Step = timeSliderStepInterval,
        IsCurve = isCurve,
    }
end

function Clip.getValue(val: string): Fusion.Value<any>?
    return Clip.getAll()[val] or nil
end

function Clip.getClip(): Types.ClipValue? return selectedClip end

return Clip