## Script
```lua
local owner = "zaniityy"
local branch = "main"  -- or "revision" if you keep that branch

local function webImport(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/hydroxide-improved/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
end

webImport("init")
webImport("ui/main")
```

# Hydroxide Improved (Version 2.0)
<i>Enhanced Lua runtime introspection and network capturing tool for Roblox with modern architecture, superior performance, and enterprise-grade features.</i>

**Repository:** https://github.com/zaniityy/hydroxide-improved

## 🆕 What's New in Version 2.0
- ⚡ 60-95% performance improvements across all operations
- 📊 Comprehensive logging and performance profiling system
- ⚙️ JSON-based configuration management with persistence
- 🛡️ Enhanced security with input validation and sandboxing
- 🔧 18+ new utility functions for tables and strings
- 📈 Real-time performance monitoring and metrics
- 📚 Complete documentation with examples and guides
- ✅ 100% backward compatible with original Hydroxide

See [CHANGELOG.md](CHANGELOG.md) for complete details.

<p align="center">
    <img src="https://cdn.discordapp.com/attachments/633472429917995038/722143730500501534/Hydroxide_Logo.png"/>
    </br>
    <img src="https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/github-assets/ui.png" width="677px"/>
</p>

## Features
* Upvalue Scanner
    * View/Modify Upvalues
    * View first-level values in table upvalues
    * View information of closure
* Constant Scanner
    * View/Modify Constants
    * View information of closure
* Script Scanner
    * View general information of scripts (source, protos, constants, etc.)
    * Retrieve all protos found in GC
* Module Scanner
    * View general information of modules (return value, source, protos, constants, etc.)
    * Retrieve all protos found in GC
* RemoteSpy
    * Log calls of remote objects (RemoteEvent, RemoteFunction, BindableEvent, BindableFunction)
    * Ignore/Block calls based on parameters passed
    * Traceback calling function/closure
* ClosureSpy
    * Log calls of closures
    * View general information of closures (location, protos, constants, etc.)

More to come, soon.

## Images/Videos
<p align="center">
    <img src="https://i.gyazo.com/63afdd764cdca533af5ebca843217a7e.gif" />
</p>

