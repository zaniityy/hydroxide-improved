-- Hydroxide Environment Utilities - Enhanced Version
-- Secure execution contexts and environment management

local client = game:GetService("Players").LocalPlayer
local control = client.PlayerScripts:FindFirstChild("Control Script")

local methods = {}

-- Enhanced secure call with better error handling
local function secureCall(closure, ...)
    if type(closure) ~= "function" then
        error("secureCall expects a function as first argument", 2)
    end
    
    local env = getfenv(1)
    local renv = getrenv()
    local results
    
    -- Set up secure environment
    local success, setupError = pcall(function()
        setfenv(1, setmetatable({ script = script }, {
            __index = renv
        }))
    end)
    
    if not success then
        warn("[Hydroxide] Failed to setup secure environment:", setupError)
        return closure(...)
    end

    -- Execute with proper error handling
    local callSuccess, callResults = pcall(function()
        return (syn and { syn.secure_call(closure, control, ...) }) or { closure(...) }
    end)
    
    if callSuccess then
        results = callResults
    else
        warn("[Hydroxide] Secure call failed:", callResults)
        results = { false, callResults }
    end

    -- Restore environment
    pcall(function()
        setfenv(1, env)
    end)

    return unpack(results)
end

-- Sandbox function execution with timeout
local function sandboxCall(closure, timeout, ...)
    timeout = timeout or 5 -- default 5 seconds
    
    local thread = coroutine.create(function(...)
        return closure(...)
    end)
    
    local startTime = os.clock()
    local results = {}
    local success, err
    
    while coroutine.status(thread) ~= "dead" do
        success, err = coroutine.resume(thread, ...)
        
        if not success then
            return false, err
        end
        
        if os.clock() - startTime > timeout then
            return false, "Timeout exceeded"
        end
        
        if success then
            results = {err}
        end
        
        task.wait()
    end
    
    return success, unpack(results)
end

-- Get safe environment (no script access)
local function getSafeEnvironment()
    local safeEnv = {}
    local renv = getrenv()
    
    -- Whitelist safe functions
    local whitelist = {
        "print", "warn", "error", "assert", "type", "typeof",
        "tonumber", "tostring", "pairs", "ipairs", "next",
        "select", "unpack", "pcall", "xpcall",
        "string", "table", "math", "os", "utf8",
        "coroutine", "debug"
    }
    
    for _, name in ipairs(whitelist) do
        safeEnv[name] = renv[name]
    end
    
    return safeEnv
end

-- Validate function before execution
local function validateFunction(func)
    if type(func) ~= "function" then
        return false, "Not a function"
    end
    
    -- Check if it's a valid Lua closure
    local success, info = pcall(debug.getinfo, func)
    if not success then
        return false, "Cannot get function info"
    end
    
    -- Additional validation can be added here
    return true, info
end

methods.secureCall = secureCall
methods.sandboxCall = sandboxCall
methods.getSafeEnvironment = getSafeEnvironment
methods.validateFunction = validateFunction

return methods
