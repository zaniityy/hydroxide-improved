-- Hydroxide Logger - Comprehensive Logging and Telemetry System
-- Provides severity-based logging, performance profiling, and diagnostics

local logger = {}

-- Log levels
local LogLevel = {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    FATAL = 4
}

-- Configuration
local config = {
    currentLevel = LogLevel.INFO,
    enableTimestamps = true,
    enableColors = true,
    maxHistorySize = 1000,
    logToFile = false,
    filePath = "hydroxide_log.txt"
}

-- Log history
local logHistory = {}
local performanceProfiles = {}

-- Color codes for console output
local colors = {
    [LogLevel.DEBUG] = "\27[36m",  -- Cyan
    [LogLevel.INFO] = "\27[37m",   -- White
    [LogLevel.WARN] = "\27[33m",   -- Yellow
    [LogLevel.ERROR] = "\27[31m",  -- Red
    [LogLevel.FATAL] = "\27[35m",  -- Magenta
    reset = "\27[0m"
}

local levelNames = {
    [LogLevel.DEBUG] = "DEBUG",
    [LogLevel.INFO] = "INFO",
    [LogLevel.WARN] = "WARN",
    [LogLevel.ERROR] = "ERROR",
    [LogLevel.FATAL] = "FATAL"
}

-- Internal log function
local function logInternal(level, message, ...)
    if level < config.currentLevel then
        return
    end
    
    local args = {...}
    local formattedMessage = message
    
    -- Format message with arguments
    if #args > 0 then
        formattedMessage = string.format(message, ...)
    end
    
    -- Build log entry
    local timestamp = config.enableTimestamps and os.date("%H:%M:%S") or ""
    local levelName = levelNames[level] or "UNKNOWN"
    local color = config.enableColors and (colors[level] or "") or ""
    local reset = config.enableColors and colors.reset or ""
    
    local logEntry = {
        level = level,
        message = formattedMessage,
        timestamp = timestamp,
        time = os.clock()
    }
    
    -- Add to history
    table.insert(logHistory, logEntry)
    if #logHistory > config.maxHistorySize then
        table.remove(logHistory, 1)
    end
    
    -- Format output
    local output = string.format("%s[%s] [%s] %s%s",
        color,
        timestamp,
        levelName,
        formattedMessage,
        reset
    )
    
    -- Print to console
    if level >= LogLevel.ERROR then
        warn(output)
    else
        print(output)
    end
    
    -- Write to file if enabled
    if config.logToFile and writefile then
        pcall(function()
            local fileContent = string.format("[%s] [%s] %s\n", timestamp, levelName, formattedMessage)
            if isfile and isfile(config.filePath) then
                fileContent = readfile(config.filePath) .. fileContent
            end
            writefile(config.filePath, fileContent)
        end)
    end
end

-- Public logging functions
function logger.debug(message, ...)
    logInternal(LogLevel.DEBUG, message, ...)
end

function logger.info(message, ...)
    logInternal(LogLevel.INFO, message, ...)
end

function logger.warn(message, ...)
    logInternal(LogLevel.WARN, message, ...)
end

function logger.error(message, ...)
    logInternal(LogLevel.ERROR, message, ...)
end

function logger.fatal(message, ...)
    logInternal(LogLevel.FATAL, message, ...)
end

-- Performance profiling
function logger.startProfile(name)
    performanceProfiles[name] = {
        startTime = os.clock(),
        endTime = nil,
        duration = nil
    }
end

function logger.endProfile(name, logResult)
    local profile = performanceProfiles[name]
    if not profile then
        logger.warn("No profile found for: %s", name)
        return nil
    end
    
    profile.endTime = os.clock()
    profile.duration = profile.endTime - profile.startTime
    
    if logResult ~= false then
        logger.info("Profile [%s] completed in %.3fms", name, profile.duration * 1000)
    end
    
    return profile.duration
end

-- Scoped profiling (automatic cleanup)
function logger.profile(name, func)
    logger.startProfile(name)
    
    local results = {pcall(func)}
    local success = table.remove(results, 1)
    
    logger.endProfile(name, false)
    
    if not success then
        logger.error("Profile [%s] failed: %s", name, tostring(results[1]))
        error(results[1])
    end
    
    return unpack(results)
end

-- Get profiling results
function logger.getProfile(name)
    return performanceProfiles[name]
end

function logger.getAllProfiles()
    return performanceProfiles
end

-- Configuration
function logger.setLevel(level)
    config.currentLevel = level
end

function logger.getLevel()
    return config.currentLevel
end

function logger.setLogToFile(enabled, path)
    config.logToFile = enabled
    if path then
        config.filePath = path
    end
end

-- History management
function logger.getHistory(count)
    count = count or #logHistory
    local result = {}
    
    local start = math.max(1, #logHistory - count + 1)
    for i = start, #logHistory do
        table.insert(result, logHistory[i])
    end
    
    return result
end

function logger.clearHistory()
    logHistory = {}
end

-- Export log levels
logger.LogLevel = LogLevel

return logger
