-- Hydroxide Enhanced - Modern Architecture
-- Version 2.0 - Improved Performance, Security, and Maintainability

local environment = assert(getgenv, "<OH> ~ Your exploit is not supported")()

-- Early exit if already loaded
if oh then
    warn("[Hydroxide] Already loaded, reinitializing...")
    oh.Exit()
end

-- Configuration Management
local config = {
    web = true,
    user = "zaniityy",
    branch = "main", -- change to "revision" if using that branch
    debug = false,
    performance = {
        enableCaching = true,
        cacheTimeout = 300, -- seconds
        lazyLoad = true
    },
    security = {
        validateImports = true,
        strictMode = true
    }
}

local importCache = {}
local methodRegistry = {}
local performanceMetrics = {
    imports = {},
    methodCalls = {}
}

-- Utility: Type checking with enhanced validation
local function isValidType(value, expectedType)
    local actualType = type(value)
    if actualType == expectedType then
        return true
    end
    if expectedType == "callable" and (actualType == "function" or (actualType == "table" and getmetatable(value) and getmetatable(value).__call)) then
        return true
    end
    return false
end

-- Utility: Safe method checker with detailed reporting
local function hasMethods(methods)
    local missing = {}
    for name in pairs(methods) do
        if not environment[name] then
            table.insert(missing, name)
        end
    end
    
    if #missing > 0 and config.debug then
        warn("[Hydroxide] Missing methods:", table.concat(missing, ", "))
    end
    
    return #missing == 0, missing
end

-- Utility: Method injector with validation and registration
local function useMethods(module, namespace)
    if not module or type(module) ~= "table" then
        warn("[Hydroxide] Invalid module provided to useMethods")
        return false
    end
    
    local registered = 0
    for name, method in pairs(module) do
        if method then
            if config.security.validateImports and not isValidType(method, "callable") and type(method) ~= "table" then
                warn("[Hydroxide] Skipping invalid method:", name)
                continue
            end
            
            environment[name] = method
            methodRegistry[name] = {
                source = namespace or "unknown",
                type = type(method),
                timestamp = os.clock()
            }
            registered = registered + 1
        end
    end
    
    if config.debug then
        print(("[Hydroxide] Registered %d methods from %s"):format(registered, namespace or "module"))
    end
    
    return true
end

-- Enhanced exploit compatibility layer with fallback mechanisms
if Window and PROTOSMASHER_LOADED then
    getgenv().get_script_function = nil
end

-- Global method registry with enhanced compatibility and fallbacks
local globalMethods = {
    -- Core methods with validation
    checkCaller = checkcaller,
    newCClosure = newcclosure,
    hookFunction = hookfunction or detour_function,
    getGc = getgc or get_gc_objects,
    getInfo = debug.getinfo or getinfo,
    getSenv = getsenv,
    getMenv = getmenv or getsenv,
    getContext = getthreadcontext or get_thread_context or (syn and syn.get_thread_identity),
    getConnections = get_signal_cons or getconnections,
    getScriptClosure = getscriptclosure or get_script_function,
    getNamecallMethod = getnamecallmethod or get_namecall_method,
    getCallingScript = getcallingscript or get_calling_script,
    getLoadedModules = getloadedmodules or get_loaded_modules,
    
    -- Debug methods with enhanced error handling
    getConstants = debug.getconstants or getconstants or getconsts,
    getUpvalues = debug.getupvalues or getupvalues or getupvals,
    getProtos = debug.getprotos or getprotos,
    getStack = debug.getstack or getstack,
    getConstant = debug.getconstant or getconstant or getconst,
    getUpvalue = debug.getupvalue or getupvalue or getupval,
    getProto = debug.getproto or getproto,
    
    -- Metatable operations
    getMetatable = getrawmetatable or debug.getmetatable,
    
    -- UI and system methods
    getHui = get_hidden_gui or gethui,
    setClipboard = setclipboard or writeclipboard,
    
    -- Modification methods
    setConstant = debug.setconstant or setconstant or setconst,
    setContext = setthreadcontext or set_thread_context or (syn and syn.set_thread_identity),
    setUpvalue = debug.setupvalue or setupvalue or setupval,
    setStack = debug.setstack or setstack,
    setReadOnly = setreadonly or (make_writeable and function(table, readonly) 
        if readonly then 
            make_readonly(table) 
        else 
            make_writeable(table) 
        end 
    end),
    
    -- Type checking methods
    isLClosure = islclosure or is_l_closure or (iscclosure and function(closure) 
        return not iscclosure(closure) 
    end),
    isReadOnly = isreadonly or is_readonly,
    isXClosure = is_synapse_function or issentinelclosure or is_protosmasher_closure or 
                is_sirhurt_closure or iselectronfunction or istempleclosure or checkclosure,
    
    -- Hook methods
    hookMetaMethod = hookmetamethod or (hookfunction and function(object, method, hook) 
        return hookfunction(getrawmetatable(object)[method], hook) 
    end),
    
    -- File system operations with validation
    readFile = readfile,
    writeFile = writefile,
    makeFolder = makefolder,
    isFolder = isfolder,
    isFile = isfile,
}

-- Exploit-specific compatibility patches
if PROTOSMASHER_LOADED then
    globalMethods.getConstant = function(closure, index)
        return globalMethods.getConstants(closure)[index]
    end
end

-- Enhanced upvalue getter with table support and error handling
local oldGetUpvalue = globalMethods.getUpvalue
local oldGetUpvalues = globalMethods.getUpvalues

globalMethods.getUpvalue = function(closure, index)
    local success, result = pcall(function()
        if type(closure) == "table" then
            return oldGetUpvalue(closure.Data, index)
        end
        return oldGetUpvalue(closure, index)
    end)
    
    if not success and config.debug then
        warn("[Hydroxide] getUpvalue failed:", result)
    end
    
    return success and result or nil
end

globalMethods.getUpvalues = function(closure)
    local success, result = pcall(function()
        if type(closure) == "table" then
            return oldGetUpvalues(closure.Data)
        end
        return oldGetUpvalues(closure)
    end)
    
    if not success and config.debug then
        warn("[Hydroxide] getUpvalues failed:", result)
    end
    
    return success and result or {}
end

-- Inject utility methods into environment
environment.hasMethods = hasMethods
environment.isValidType = isValidType
-- Core OH namespace with enhanced features
environment.oh = {
    Events = {},
    Hooks = {},
    Cache = importCache,
    Methods = globalMethods,
    Config = config,
    Registry = methodRegistry,
    Performance = performanceMetrics,
    
    Constants = {
        Types = {
            ["nil"] = "rbxassetid://4800232219",
            table = "rbxassetid://4666594276",
            string = "rbxassetid://4666593882",
            number = "rbxassetid://4666593882",
            boolean = "rbxassetid://4666593882",
            userdata = "rbxassetid://4666594723",
            vector = "rbxassetid://4666594723",
            ["function"] = "rbxassetid://4666593447",
            ["thread"] = "rbxassetid://4666593447",
            ["integral"] = "rbxassetid://4666593882"
        },
        Syntax = {
            ["nil"] = Color3.fromRGB(244, 135, 113),
            table = Color3.fromRGB(225, 225, 225),
            string = Color3.fromRGB(225, 150, 85),
            number = Color3.fromRGB(170, 225, 127),
            boolean = Color3.fromRGB(127, 200, 255),
            userdata = Color3.fromRGB(225, 225, 225),
            vector = Color3.fromRGB(225, 225, 225),
            ["function"] = Color3.fromRGB(225, 225, 225),
            ["thread"] = Color3.fromRGB(225, 225, 225),
            ["unnamed_function"] = Color3.fromRGB(175, 175, 175)
        }
    },
    
    -- Enhanced exit with proper cleanup and reporting
    Exit = function()
        local startTime = os.clock()
        local disconnected = 0
        local unhooked = 0
        
        -- Disconnect all events
        for _i, event in pairs(oh.Events) do
            pcall(function()
                event:Disconnect()
                disconnected = disconnected + 1
            end)
        end

        -- Restore all hooks
        for original, hook in pairs(oh.Hooks) do
            pcall(function()
                local hookType = type(hook)
                if hookType == "function" then
                    hookFunction(hook, original)
                    unhooked = unhooked + 1
                elseif hookType == "table" then
                    hookFunction(hook.Closure.Data, hook.Original)
                    unhooked = unhooked + 1
                end
            end)
        end

        -- Clean up UI
        local ui = importCache["rbxassetid://11389137937"]
        local assets = importCache["rbxassetid://5042114982"]

        if ui then
            pcall(function()
                unpack(ui):Destroy()
            end)
        end

        if assets then
            pcall(function()
                unpack(assets):Destroy()
            end)
        end
        
        local elapsed = os.clock() - startTime
        if config.debug then
            print(("[Hydroxide] Cleaned up in %.3fs: %d events, %d hooks"):format(
                elapsed, disconnected, unhooked
            ))
        end
        
        -- Clear references
        getgenv().oh = nil
    end,
    
    -- Performance monitoring
    GetPerformanceReport = function()
        return {
            imports = performanceMetrics.imports,
            methodCalls = performanceMetrics.methodCalls,
            cacheSize = #importCache,
            registeredMethods = #methodRegistry
        }
    end,
    
    -- Utility: Get method info
    GetMethodInfo = function(methodName)
        return methodRegistry[methodName]
    end
}

-- Enhanced error connection handling with better compatibility
if getConnections then 
    local ScriptContext = game:GetService("ScriptContext")
    local connections = getConnections(ScriptContext.Error)
    local patchedCount = 0
    
    for __, connection in pairs(connections) do
        pcall(function()
            local conn = getrawmetatable(connection)
            local old = conn and conn.__index
            
            if old then
                -- Make metatable writable
                if PROTOSMASHER_LOADED ~= nil then 
                    setwriteable(conn) 
                else 
                    setReadOnly(conn, false) 
                end
                
                -- Patch __index to always return Connected = true
                conn.__index = newcclosure(function(t, k)
                    if k == "Connected" then
                        return true
                    end
                    return old(t, k)
                end)
                
                -- Restore readonly and disable connection
                if PROTOSMASHER_LOADED ~= nil then
                    setReadOnly(conn)
                    connection:Disconnect()
                else
                    setReadOnly(conn, true)
                    connection:Disable()
                end
                
                patchedCount = patchedCount + 1
            end
        end)
    end
    
    if config.debug then
        print(("[Hydroxide] Patched %d error connections"):format(patchedCount))
    end
end

-- Inject global methods into environment
useMethods(globalMethods, "core")

-- Validate critical methods are available
local criticalMethodsList = {"getGc", "getInfo", "getConstants", "hookFunction", "newCClosure"}
local missingCritical = {}

for _, methodName in ipairs(criticalMethodsList) do
    if not globalMethods[methodName] then
        table.insert(missingCritical, methodName)
    end
end

if #missingCritical > 0 then
    local errorMsg = string.format(
        "\n[Hydroxide] Critical methods missing: %s\n" ..
        "\nYour executor doesn't support the following required functions:\n" ..
        "- %s\n" ..
        "\nHydroxide requires an executor with advanced debugging capabilities.\n" ..
        "Supported executors include: Synapse X, Script-Ware, Krnl, Fluxus, etc.\n",
        table.concat(missingCritical, ", "),
        table.concat(missingCritical, "\n- ")
    )
    error(errorMsg)
end

if config.debug then
    print("[Hydroxide] All critical methods validated successfully")
end

-- Enhanced import system with caching and validation
local HttpService = game:GetService("HttpService")

-- Fetch release info with error handling (optional, fallback if fails)
local releaseInfo = { tag_name = "2.0.0" }
local success, result = pcall(function()
    return HttpService:JSONDecode(game:HttpGetAsync("https://api.github.com/repos/" .. config.user .. "/hydroxide-improved/releases"))[1]
end)

if success and result then
    releaseInfo = result
    if config.debug then
        print(("[Hydroxide] Latest release: %s"):format(releaseInfo.tag_name))
    end
else
    if config.debug then
        warn("[Hydroxide] Failed to fetch release info (using default):", result)
    end
end

-- Enhanced import function with performance tracking and caching
if readFile and writeFile then
    local hasFolderFunctions = (isFolder and makeFolder) ~= nil
    local ran, result = pcall(readFile, "__oh_version.txt")

    if not ran or releaseInfo.tag_name ~= result then
        -- Fresh install or update required
        if hasFolderFunctions then
            local function createFolder(path)
                if not isFolder(path) then
                    local success, err = pcall(makeFolder, path)
                    if not success and config.debug then
                        warn("[Hydroxide] Failed to create folder:", path, err)
                    end
                end
            end

            -- Create directory structure
            local folders = {
                "hydroxide",
                "hydroxide/user",
                "hydroxide/user/" .. config.user,
                "hydroxide/user/" .. config.user .. "/methods",
                "hydroxide/user/" .. config.user .. "/modules",
                "hydroxide/user/" .. config.user .. "/objects",
                "hydroxide/user/" .. config.user .. "/ui",
                "hydroxide/user/" .. config.user .. "/ui/controls",
                "hydroxide/user/" .. config.user .. "/ui/modules"
            }
            
            for _, folder in ipairs(folders) do
                createFolder(folder)
            end
        end

        -- Enhanced import function with performance metrics
        function environment.import(asset)
            local startTime = os.clock()
            
            if importCache[asset] then
                if config.debug then
                    print(("[Hydroxide] Cache hit: %s"):format(asset))
                end
                return unpack(importCache[asset])
            end

            local assets
            local importMethod = "unknown"

            -- Try different import methods
            if asset:find("rbxassetid://") then
                importMethod = "rbxasset"
                local success, result = pcall(function()
                    return { game:GetObjects(asset)[1] }
                end)
                
                if success then
                    assets = result
                else
                    warn("[Hydroxide] Failed to load asset:", asset, result)
                    return nil
                end
                
            elseif config.web then
                importMethod = "web"
                if readFile and writeFile then
                    local file = (hasFolderFunctions and "hydroxide/user/" .. config.user .. '/' .. asset .. ".lua") 
                                or ("hydroxide-" .. config.user .. '-' .. asset:gsub('/', '-') .. ".lua")
                    local content

                    -- Check if file needs updating
                    if (isFile and not isFile(file)) or not importCache[asset] then
                        local success, result = pcall(function()
                            return game:HttpGetAsync("https://raw.githubusercontent.com/" .. config.user .. "/hydroxide-improved/" .. config.branch .. '/' .. asset .. ".lua")
                        end)
                        
                        if success then
                            content = result
                            pcall(writeFile, file, content)
                        else
                            warn("[Hydroxide] Failed to download:", asset, result)
                            return nil
                        end
                    else
                        local success, result = pcall(readFile, file)

                        if not success or not importCache[asset] then
                            local dlSuccess, dlResult = pcall(function()
                                return game:HttpGetAsync("https://raw.githubusercontent.com/" .. config.user .. "/hydroxide-improved/" .. config.branch .. '/' .. asset .. ".lua")
                            end)
                            
                            if dlSuccess then
                                content = dlResult
                                pcall(writeFile, file, content)
                            else
                                warn("[Hydroxide] Failed to update:", asset, dlResult)
                                return nil
                            end
                        else
                            content = result
                        end
                    end

                    local loadSuccess, loadResult = pcall(loadstring, content, asset .. '.lua')
                    if loadSuccess then
                        local execSuccess, execResult = pcall(loadResult)
                        if execSuccess then
                            assets = { execResult }
                        else
                            warn("[Hydroxide] Failed to execute:", asset, execResult)
                            return nil
                        end
                    else
                        warn("[Hydroxide] Failed to parse:", asset, loadResult)
                        return nil
                    end
                else
                    local success, result = pcall(function()
                        return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/" .. config.user .. "/hydroxide-improved/" .. config.branch .. '/' .. asset .. ".lua"), asset .. '.lua')()
                    end)
                    
                    if success then
                        assets = { result }
                    else
                        warn("[Hydroxide] Failed to load:", asset, result)
                        return nil
                    end
                end
            else
                importMethod = "local"
                local success, result = pcall(function()
                    return loadstring(readFile("hydroxide/" .. asset .. ".lua"), asset .. '.lua')()
                end)
                
                if success then
                    assets = { result }
                else
                    warn("[Hydroxide] Failed to load local:", asset, result)
                    return nil
                end
            end

            if assets then
                importCache[asset] = assets
                
                local elapsed = os.clock() - startTime
                performanceMetrics.imports[asset] = {
                    method = importMethod,
                    time = elapsed,
                    timestamp = os.clock()
                }
                
                if config.debug then
                    print(("[Hydroxide] Imported %s via %s in %.3fms"):format(
                        asset, importMethod, elapsed * 1000
                    ))
                end
                
                return unpack(assets)
            end
            
            return nil
        end

        pcall(writeFile, "__oh_version.txt", releaseInfo.tag_name)
    elseif ran and releaseInfo.tag_name == result then
        -- Using cached version
        function environment.import(asset)
            if importCache[asset] then
                return unpack(importCache[asset])
            end

            local assets
            local startTime = os.clock()

            if asset:find("rbxassetid://") then
                local success, result = pcall(function()
                    return { game:GetObjects(asset)[1] }
                end)
                
                if success then
                    assets = result
                else
                    warn("[Hydroxide] Failed to load asset:", asset, result)
                    return nil
                end
                
            elseif config.web then
                local file = (hasFolderFunctions and "hydroxide/user/" .. config.user .. '/' .. asset .. ".lua") 
                            or ("hydroxide-" .. config.user .. '-' .. asset:gsub('/', '-') .. ".lua")
                local success, result = pcall(readFile, file)
                local content

                if not success then
                    local dlSuccess, dlResult = pcall(function()
                        return game:HttpGetAsync("https://raw.githubusercontent.com/" .. config.user .. "/hydroxide-improved/" .. config.branch .. '/' .. asset .. ".lua")
                    end)
                    
                    if dlSuccess then
                        content = dlResult
                        pcall(writeFile, file, content)
                    else
                        warn("[Hydroxide] Failed to download:", asset, dlResult)
                        return nil
                    end
                else
                    content = result
                end

                local loadSuccess, loadResult = pcall(loadstring, content, asset .. '.lua')
                if loadSuccess then
                    local execSuccess, execResult = pcall(loadResult)
                    if execSuccess then
                        assets = { execResult }
                    else
                        warn("[Hydroxide] Failed to execute:", asset, execResult)
                        return nil
                    end
                else
                    warn("[Hydroxide] Failed to parse:", asset, loadResult)
                    return nil
                end
            else
                local success, result = pcall(function()
                    return loadstring(readFile("hydroxide/" .. asset .. ".lua"), asset .. '.lua')()
                end)
                
                if success then
                    assets = { result }
                else
                    warn("[Hydroxide] Failed to load local:", asset, result)
                    return nil
                end
            end

            if assets then
                importCache[asset] = assets
                
                local elapsed = os.clock() - startTime
                if config.debug then
                    print(("[Hydroxide] Cached import %s in %.3fms"):format(asset, elapsed * 1000))
                end
                
                return unpack(assets)
            end
            
            return nil
        end
    end

    -- Register import method
    useMethods({ import = environment.import }, "import")
end

-- Import and register extension methods with error handling
local function safeImport(module, name)
    local success, result = pcall(import, module)
    if success and result then
        useMethods(result, name)
        return true
    else
        warn("[Hydroxide] Failed to import:", module, result)
        return false
    end
end

safeImport("methods/string", "string")
safeImport("methods/table", "table")
safeImport("methods/userdata", "userdata")
safeImport("methods/environment", "environment")

-- Initialize complete
if config.debug then
    print("[Hydroxide] Initialization complete")
    print("[Hydroxide] Methods registered:", #methodRegistry)
    print("[Hydroxide] Cache entries:", #importCache)
end

--import("ui/main")
