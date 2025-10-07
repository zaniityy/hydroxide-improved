-- Hydroxide Configuration System
-- Flexible configuration with JSON persistence and feature flags

local config = {}

-- Default configuration
local defaults = {
    version = "2.0",
    
    -- Core settings
    debug = false,
    strictMode = true,
    web = true,
    user = "Upbolt",
    branch = "revision",
    
    -- Performance settings
    performance = {
        enableCaching = true,
        cacheTimeout = 300, -- seconds
        lazyLoad = true,
        gcCacheTimeout = 5,
        maxCacheSize = 1000
    },
    
    -- Security settings
    security = {
        validateImports = true,
        sanitizeInputs = true,
        antiDetection = true,
        maxRecursionDepth = 50
    },
    
    -- Logging settings
    logging = {
        enabled = true,
        level = 1, -- 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR, 4=FATAL
        toFile = false,
        filePath = "hydroxide_log.txt",
        maxHistory = 1000,
        enableTimestamps = true,
        enableColors = true
    },
    
    -- UI settings
    ui = {
        theme = "dark",
        transparency = 0.95,
        scale = 1.0,
        position = { x = 100, y = 100 },
        autoSave = true
    },
    
    -- Feature flags
    features = {
        remoteSpyEnabled = true,
        closureSpyEnabled = true,
        upvalueScannerEnabled = true,
        constantScannerEnabled = true,
        scriptScannerEnabled = true,
        moduleScannerEnabled = true,
        explorerEnabled = true
    },
    
    -- Module-specific settings
    remoteSpy = {
        maxLogs = 500,
        captureStacks = true,
        filterByScript = false
    },
    
    closureSpy = {
        maxLogs = 500,
        captureStacks = true,
        autoScan = false
    }
}

-- Current configuration (starts as copy of defaults)
local currentConfig = {}

-- Deep copy function
local function deepCopy(original)
    if type(original) ~= 'table' then
        return original
    end
    
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = deepCopy(value)
    end
    
    return copy
end

-- Deep merge function
local function deepMerge(target, source)
    for key, value in pairs(source) do
        if type(value) == 'table' and type(target[key]) == 'table' then
            deepMerge(target[key], value)
        else
            target[key] = value
        end
    end
end

-- Initialize configuration
local function initialize()
    currentConfig = deepCopy(defaults)
    
    -- Try to load saved configuration
    if isfile and readfile then
        local success, savedConfig = pcall(function()
            local HttpService = game:GetService("HttpService")
            return HttpService:JSONDecode(readfile("hydroxide_config.json"))
        end)
        
        if success and savedConfig then
            deepMerge(currentConfig, savedConfig)
        end
    end
end

-- Save configuration to file
local function save()
    if not writefile then
        return false, "writefile not available"
    end
    
    local success, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        local json = HttpService:JSONEncode(currentConfig)
        writefile("hydroxide_config.json", json)
    end)
    
    return success, err
end

-- Get configuration value
local function get(path)
    if not path then
        return currentConfig
    end
    
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local value = currentConfig
    for _, key in ipairs(keys) do
        if type(value) ~= 'table' then
            return nil
        end
        value = value[key]
    end
    
    return value
end

-- Set configuration value
local function set(path, value, autoSave)
    autoSave = autoSave ~= false -- default true
    
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local current = currentConfig
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(current[key]) ~= 'table' then
            current[key] = {}
        end
        current = current[key]
    end
    
    local lastKey = keys[#keys]
    local oldValue = current[lastKey]
    current[lastKey] = value
    
    if autoSave then
        save()
    end
    
    return oldValue
end

-- Reset to defaults
local function reset(saveAfter)
    currentConfig = deepCopy(defaults)
    
    if saveAfter and writefile then
        save()
    end
    
    return currentConfig
end

-- Validate configuration
local function validate()
    local errors = {}
    
    -- Type validation
    if type(currentConfig.performance.cacheTimeout) ~= "number" then
        table.insert(errors, "performance.cacheTimeout must be a number")
    end
    
    if type(currentConfig.logging.level) ~= "number" then
        table.insert(errors, "logging.level must be a number")
    end
    
    -- Range validation
    if currentConfig.logging.level < 0 or currentConfig.logging.level > 4 then
        table.insert(errors, "logging.level must be between 0 and 4")
    end
    
    if currentConfig.ui.scale < 0.5 or currentConfig.ui.scale > 2.0 then
        table.insert(errors, "ui.scale must be between 0.5 and 2.0")
    end
    
    return #errors == 0, errors
end

-- Export public API
config.initialize = initialize
config.get = get
config.set = set
config.save = save
config.reset = reset
config.validate = validate
config.defaults = defaults

-- Initialize on load
initialize()

return config
