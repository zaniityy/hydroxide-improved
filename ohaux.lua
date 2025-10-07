-- Hydroxide Auxiliary Utilities - Enhanced Version
-- Optimized search algorithms with caching and performance improvements

local aux = {}

-- Cache frequently used functions
local getGc = getgc
local getInfo = debug.getinfo or getinfo
local getUpvalue = debug.getupvalue or getupvalue or getupval
local getConstants = debug.getconstants or getconstants or getconsts
local isXClosure = is_synapse_function or issentinelclosure or is_protosmasher_closure or 
                   is_sirhurt_closure or istempleclosure or checkclosure
local isLClosure = islclosure or is_l_closure or (iscclosure and function(f) return not iscclosure(f) end)

assert(getGc and getInfo and getConstants and isXClosure, "Your exploit is not supported")

-- Performance: Cache for GC results to avoid repeated scans
local gcCache = {}
local gcCacheTimeout = 5 -- seconds
local lastGcScan = 0

-- Placeholder for userdata in constant matching
local placeholderUserdataConstant = newproxy(false)

-- Enhanced constant matching with better validation
local function matchConstants(closure, list)
    if not list or type(list) ~= "table" then
        return true
    end
    
    local success, constants = pcall(getConstants, closure)
    if not success or not constants then
        return false
    end
    
    for index, value in pairs(list) do
        local constant = constants[index]
        
        -- Special handling for userdata placeholder
        if value == placeholderUserdataConstant then
            if type(constant) ~= "userdata" then
                return false
            end
        elseif constant ~= value then
            return false
        end
    end
    
    return true
end

-- Optimized GC scanning with caching
local function getGcCached()
    local currentTime = os.clock()
    
    -- Use cached GC if within timeout
    if gcCache.data and (currentTime - lastGcScan) < gcCacheTimeout then
        return gcCache.data
    end
    
    -- Perform new GC scan
    local success, result = pcall(getGc)
    if success then
        gcCache.data = result
        lastGcScan = currentTime
        return result
    end
    
    return {}
end

-- Enhanced closure search with better filtering and performance
local function searchClosure(script, name, upvalueIndex, constants, useCache)
    useCache = useCache ~= false -- default to true
    
    local gcObjects = useCache and getGcCached() or getGc()
    local matches = {}
    local searchStartTime = os.clock()
    
    for _i, v in pairs(gcObjects) do
        -- Type check first (fastest)
        if type(v) ~= "function" then
            continue
        end
        
        -- Check closure type
        if not isLClosure(v) or isXClosure(v) then
            continue
        end
        
        -- Safe environment check
        local success, fenv = pcall(getfenv, v)
        if not success then
            continue
        end
        
        local parentScript = rawget(fenv, "script")
        
        -- Script filtering
        local scriptMatches = (script == nil and parentScript and parentScript.Parent == nil) or 
                             (script == parentScript)
        
        if not scriptMatches then
            continue
        end
        
        -- Upvalue validation
        if upvalueIndex then
            local uvSuccess = pcall(getUpvalue, v, upvalueIndex)
            if not uvSuccess then
                continue
            end
        end
        
        -- Name matching
        if name and name ~= "Unnamed function" then
            local infoSuccess, info = pcall(getInfo, v)
            if not infoSuccess or not info or info.name ~= name then
                continue
            end
        end
        
        -- Constants matching
        if not matchConstants(v, constants) then
            continue
        end
        
        -- Found a match
        table.insert(matches, v)
    end
    
    local elapsed = os.clock() - searchStartTime
    
    -- Return first match for compatibility, but store all matches
    if #matches > 0 then
        if #matches > 1 and oh and oh.Config and oh.Config.debug then
            warn(("[ohaux] Found %d matches in %.3fms, returning first"):format(
                #matches, elapsed * 1000
            ))
        end
        return matches[1], matches
    end
    
    return nil, matches
end

-- Advanced: Search for multiple closures matching criteria
local function searchClosures(script, name, upvalueIndex, constants, maxResults)
    maxResults = maxResults or math.huge
    
    local _, matches = searchClosure(script, name, upvalueIndex, constants, true)
    
    if maxResults < #matches then
        local limited = {}
        for i = 1, maxResults do
            table.insert(limited, matches[i])
        end
        return limited
    end
    
    return matches
end

-- Clear GC cache manually if needed
local function clearGcCache()
    gcCache = {}
    lastGcScan = 0
end

-- Get cache statistics
local function getCacheStats()
    return {
        hasCachedData = gcCache.data ~= nil,
        lastScan = lastGcScan,
        age = os.clock() - lastGcScan,
        timeout = gcCacheTimeout
    }
end

-- Export API
aux.placeholderUserdataConstant = placeholderUserdataConstant
aux.searchClosure = searchClosure
aux.searchClosures = searchClosures
aux.matchConstants = matchConstants
aux.clearGcCache = clearGcCache
aux.getCacheStats = getCacheStats
aux.getGcCached = getGcCached

return aux
