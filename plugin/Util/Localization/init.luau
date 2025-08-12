--!strict
local StudioService = game:GetService("StudioService")

local Localization = {}

local currentLanguage: string? = nil
local fallbackLanguage = 'en'

local languageCache: {[string]: {[string]: string}} = {}

local function getCurrentLanguage(): string
    if not currentLanguage then
        local localeId = StudioService.StudioLocaleId
        currentLanguage = string.split(localeId, "_")[1] or fallbackLanguage
    end
    return currentLanguage :: string
end

local function loadLanguageData(language: string): {[string]: string}?
    local cached = languageCache[language]
    if cached then return cached end
    
    local languageModule = script:FindFirstChild(language)
    if not (languageModule and languageModule:IsA("ModuleScript")) then return end
    
    local success, result = pcall(require, languageModule :: ModuleScript)
    if success and type(result) == "table" then
        languageCache[language] = result
        return result
    end
    return
end

local function formatString(str: string, params: {[string]: any}?): string
    if not params then
        return str
    end
    
    local result = str
    for key, value in pairs(params) do
        result = string.gsub(result, "{" .. key .. "}", tostring(value))
    end
    
    return result
end

function Localization.get(key: string, params: {[string]: any}?): string
    local language = getCurrentLanguage()
    
    local languageData = loadLanguageData(language)
    if languageData and languageData[key] then
        return formatString(languageData[key], params)
    end
    
    if language ~= fallbackLanguage then
        local englishData = loadLanguageData(fallbackLanguage)
        if englishData and englishData[key] then
            return formatString(englishData[key], params)
        end
    end
    
    return key
end

function Localization.getLanguage(): string
    return getCurrentLanguage()
end

return Localization