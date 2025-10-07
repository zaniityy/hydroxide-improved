-- Hydroxide Table Utilities - Enhanced Version
-- Advanced table manipulation and serialization

local methods = {}

-- Enhanced cyclic-safe table to string with depth limit
local function tableToString(data, root, indents, maxDepth)
    local dataType = type(data)
    maxDepth = maxDepth or 10
    indents = indents or 1

    if indents > maxDepth then
        return "... (max depth reached)"
    end

    if dataType == "userdata" then
        return (typeof(data) == "Instance" and getInstancePath(data)) or userdataValue(data)
    elseif dataType == "string" then
        if #(data:gsub('%w', ''):gsub('%s', ''):gsub('%p', '')) > 0 then
            local success, result = pcall(toUnicode, data)
            return (success and result) or toString(data)
        else
            return ('"%s"'):format(data:gsub('"', '\\"'))
        end
    elseif dataType == "table" then
        root = root or data

        local head = '{\n'
        local elements = 0
        local indent = ('\t'):rep(indents)
        
        for i, v in pairs(data) do
            if i ~= root and v ~= root then
                local keyStr = tableToString(i, root, indents + 1, maxDepth)
                local valueStr = tableToString(v, root, indents + 1, maxDepth)
                head = head .. ("%s[%s] = %s,\n"):format(indent, keyStr, valueStr)
            else
                head = head .. ("%sOH_CYCLIC_PROTECTION,\n"):format(indent)
            end

            elements = elements + 1
        end
        
        if elements > 0 then
            return ("%s\n%s"):format(head:sub(1, -3), ('\t'):rep(indents - 1) .. '}')
        else
            return "{}"
        end
    end

    return tostring(data)
end

-- Deep comparison of tables
local function compareTables(x, y, deep)
    if type(x) ~= "table" or type(y) ~= "table" then
        return x == y
    end
    
    -- Shallow comparison
    for i, v in pairs(x) do
        if v ~= y[i] then
            if deep and type(v) == "table" and type(y[i]) == "table" then
                if not compareTables(v, y[i], true) then
                    return false
                end
            else
                return false
            end
        end
    end
    
    -- Check reverse (keys in y not in x)
    for i in pairs(y) do
        if x[i] == nil then
            return false
        end
    end

    return true
end

-- Deep copy a table
local function deepCopy(original, visited)
    visited = visited or {}
    
    if type(original) ~= 'table' then
        return original
    end
    
    if visited[original] then
        return visited[original]
    end
    
    local copy = {}
    visited[original] = copy
    
    for key, value in pairs(original) do
        copy[deepCopy(key, visited)] = deepCopy(value, visited)
    end
    
    return setmetatable(copy, getmetatable(original))
end

-- Merge tables (deep merge)
local function mergeTables(target, source, deep)
    for key, value in pairs(source) do
        if deep and type(value) == 'table' and type(target[key]) == 'table' then
            mergeTables(target[key], value, true)
        else
            target[key] = value
        end
    end
    return target
end

-- Get table size (works with non-sequential tables)
local function tableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Check if table is empty
local function isEmpty(tbl)
    return next(tbl) == nil
end

-- Filter table by predicate function
local function filter(tbl, predicate)
    local result = {}
    for key, value in pairs(tbl) do
        if predicate(value, key) then
            result[key] = value
        end
    end
    return result
end

-- Map table values
local function map(tbl, transform)
    local result = {}
    for key, value in pairs(tbl) do
        result[key] = transform(value, key)
    end
    return result
end

-- Find first matching element
local function find(tbl, predicate)
    for key, value in pairs(tbl) do
        if predicate(value, key) then
            return value, key
        end
    end
    return nil
end

-- Get table keys
local function keys(tbl)
    local result = {}
    for key in pairs(tbl) do
        table.insert(result, key)
    end
    return result
end

-- Get table values
local function values(tbl)
    local result = {}
    for _, value in pairs(tbl) do
        table.insert(result, value)
    end
    return result
end

-- Export all methods
methods.tableToString = tableToString
methods.compareTables = compareTables
methods.deepCopy = deepCopy
methods.mergeTables = mergeTables
methods.tableSize = tableSize
methods.isEmpty = isEmpty
methods.filter = filter
methods.map = map
methods.find = find
methods.keys = keys
methods.values = values

return methods