--!strict
local HttpService = game:GetService("HttpService")

local MainPath = script.Parent.Parent
local GeneralData = require(MainPath.GeneralData)

local Versioning = {}

local ENDPOINT = "https://api.github.com/repos/Vexot/CustomEmoteThumbnail/releases/latest"

function Versioning.checkForUpdate(endpoint: string?): boolean
    local currentVersion = GeneralData.Version
    if not currentVersion then return false end
    
    local success, response = pcall(function()
        return HttpService:GetAsync(ENDPOINT)
    end)
    if not success then return false end
    
    local decodeSuccess, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if not decodeSuccess or type(data) ~= "table" then return false end
    
    local latestVersion = data.tag_name
    if not latestVersion or type(latestVersion) ~= "string" then return false end

    return currentVersion ~= latestVersion
end

function Versioning.getCurrentVersion(): string?
    return GeneralData.Version
end

return Versioning