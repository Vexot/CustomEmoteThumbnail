--!strict
local MainPath = script.Parent.Parent

local Fusion = require(MainPath.Packages.Fusion)
local GeneralData = require(MainPath.GeneralData)
local Types = require(MainPath.Types)

local States = {}

local defParams = GeneralData.DefaultParameters
local paramMapping = GeneralData.ParamMapping
local paramConfig = GeneralData.ParamConfig

local ThumbParams: Types.ThumbParams = {}
local refreshCallback: (() -> ())?

local function preciseSum(...)
	local nums = {...}
	local maxDecimals = 0

	for _, num in ipairs(nums) do
		local s = tostring(num)
		local dotPos = string.find(s, "%.")
        
		if not dotPos then continue end
		local decs = #s - dotPos

		if decs <= maxDecimals then continue end
		maxDecimals = decs
	end

	local scale, total = 10 ^ maxDecimals, 0
	for _, num in ipairs(nums) do
		total += math.round(num * scale)
	end

	return total / scale
end

function States.init(scope: Fusion.Scope<Fusion.Fusion>, callback: (() -> ())?)
    refreshCallback = callback
    
    for paramName, defaultParamKey in pairs(paramMapping) do
        ThumbParams[paramName] = scope:Value(defParams[defaultParamKey])
    end
    
    return ThumbParams
end

local function validateValue(paramName: Types.ParamValueIds, value: number): number
    local config = paramConfig[paramName]
    if not config then return value end -- If no config, return as-is
    
    local validatedValue = config.Format and config.Format(value) or value

    if config.Min and validatedValue < config.Min then
        validatedValue = config.Min
    end
    
    if config.Max and validatedValue > config.Max then
        validatedValue = config.Max
    end
    
    if config.Step then
        validatedValue = math.round(validatedValue / config.Step) * config.Step
    end
    
    return validatedValue
end

function States.set(paramName: Types.ParamValueIds, value: number): ()
    local param = ThumbParams[paramName]
    if not param then return error(`Unknown parameter: {paramName}`) end

    local validated = validateValue(paramName, value)
    if not validated then return end

    param:set(validated)
    if refreshCallback then refreshCallback() end
end

function States.increase(paramName: Types.ParamValueIds, amount: number): ()
    local param = ThumbParams[paramName]
    if not param then return error(`Unknown parameter: {paramName}`) end

    local validated = validateValue(paramName, preciseSum(Fusion.peek(param), amount))
    if not validated then return end

    param:set(validated)
    if refreshCallback then refreshCallback() end
end

function States.reset(paramName: Types.ParamValueIds): ()
    local defaultParamKey = paramMapping[paramName]
    if not defaultParamKey then return error(`Unknown parameter: {paramName}`) end
    
    local param = ThumbParams[paramName]
    if not param then return end

    param:set(defParams[defaultParamKey])
    if refreshCallback then refreshCallback() end
end

function States.resetAll()
    for paramName, defaultParamKey in pairs(paramMapping) do
        local param = ThumbParams[paramName]
        if not param then continue end
        ThumbParams[paramName]:set(defParams[defaultParamKey])
    end
    if refreshCallback then refreshCallback() end
end

function States.getState(paramName: Types.ParamValueIds): Fusion.Value<number>?
    return ThumbParams[paramName]
end

function States.getValue(paramName: Types.ParamValueIds): number?
    local param = ThumbParams[paramName]
    return param and Fusion.peek(param) or nil
end

function States.getAllValues(): {[string]: number}
    local values = {}
    for paramName, valueState in pairs(ThumbParams) do
        values[paramName] = Fusion.peek(valueState)
    end
    return values
end

function States.getConfig(paramName: string) return paramConfig[paramName] end
function States.getAllConfigs() return paramConfig end
function States.getParams() return ThumbParams end

return States
