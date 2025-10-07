-- Hydroxide String Utilities - Enhanced Version
-- Advanced string manipulation and formatting

local methods = {}

-- Enhanced toString with better type handling
local function toString(value)
    local dataType = typeof(value)

    if dataType == "userdata" or dataType == "table" then
        local success, mt = pcall(getMetatable, value)
        local __tostring = success and mt and rawget(mt, "__tostring")

        if not success or not mt or not __tostring then 
            return tostring(value) 
        end

        local protected = pcall(function()
            rawset(mt, "__tostring", nil)
        end)
        
        if not protected then
            return tostring(value)
        end
        
        local result = tostring(value):gsub((dataType == "userdata" and "userdata: ") or "table: ", '')
        
        pcall(function()
            rawset(mt, "__tostring", __tostring)
        end)

        return result 
    elseif type(value) == "userdata" then
        return userdataValue(value)
    elseif dataType == "function" then
        local success, info = pcall(getInfo, value)
        local closureName = success and info and info.name or ''
        return (closureName == '' and "Unnamed function") or closureName
    else
        return tostring(value)
    end
end

-- Enhanced escape character mapping
local gsubCharacters = {
    ["\""] = "\\\"",
    ["\\"] = "\\\\",
    ["\0"] = "\\0",
    ["\n"] = "\\n",
    ["\t"] = "\\t",
    ["\f"] = "\\f",
    ["\r"] = "\\r",
    ["\v"] = "\\v",
    ["\a"] = "\\a",
    ["\b"] = "\\b"
}

-- Safe string escaping
local function escape(str)
    if type(str) ~= "string" then
        return tostring(str)
    end
    return str:gsub("[%c%z\\\"]", gsubCharacters)
end

-- Data to string with type-specific formatting
local function dataToString(data)
    local dataType = type(data)

    if dataType == "string" then
        return '"' .. escape(data) .. '"'
    elseif dataType == "table" then
        return tableToString(data)
    elseif dataType == "userdata" then
        if typeof(data) == "Instance" then
            return getInstancePath(data)
        end
        return userdataValue(data)
    end

    return tostring(data)
end

-- Convert string to unicode representation
local function toUnicode(string)
    if type(string) ~= "string" then
        return tostring(string)
    end
    
    local codepoints = "utf8.char("
    local count = 0
    
    for _i, v in utf8.codes(string) do
        codepoints = codepoints .. v .. ', '
        count = count + 1
    end
    
    if count == 0 then
        return "utf8.char()"
    end
    
    return codepoints:sub(1, -3) .. ')'
end

-- Split string by delimiter
local function split(str, delimiter)
    delimiter = delimiter or "%s"
    local result = {}
    
    for match in string.gmatch(str, "([^" .. delimiter .. "]+)") do
        table.insert(result, match)
    end
    
    return result
end

-- Trim whitespace from string
local function trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Check if string starts with prefix
local function startsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-- Check if string ends with suffix
local function endsWith(str, suffix)
    return suffix == "" or str:sub(-#suffix) == suffix
end

-- Truncate string to max length
local function truncate(str, maxLength, suffix)
    suffix = suffix or "..."
    if #str <= maxLength then
        return str
    end
    return str:sub(1, maxLength - #suffix) .. suffix
end

-- Pad string to length
local function pad(str, length, char, right)
    char = char or " "
    local padding = string.rep(char, length - #str)
    
    if right then
        return str .. padding
    else
        return padding .. str
    end
end

-- Case conversions
local function toTitleCase(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

-- Count occurrences of substring
local function count(str, pattern)
    local count = 0
    for _ in str:gmatch(pattern) do
        count = count + 1
    end
    return count
end

-- Export all methods
methods.toString = toString
methods.dataToString = dataToString
methods.toUnicode = toUnicode
methods.escape = escape
methods.split = split
methods.trim = trim
methods.startsWith = startsWith
methods.endsWith = endsWith
methods.truncate = truncate
methods.pad = pad
methods.toTitleCase = toTitleCase
methods.count = count

return methods
