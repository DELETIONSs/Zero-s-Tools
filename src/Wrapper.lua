--!native
--!optimize 2
--!divine-intellect
local SP = {}

-- Safe GetService (with cloneref)
function SP:SGS(name)
    local ok, service = pcall(function()
        return game:GetService(name)
    end)
    if not ok then return nil end
    if cloneref then
        return cloneref(service)
    else
        return service
    end
end

-- Creates a secure folder (using createsecurefolder or fallback)
function SP:CreateSecureFolder(path)
    if type(path) ~= "string" or path == "" then
        path = "SecureFolder"
    end

    local success = false
    if createsecurefolder then
        local ok = pcall(function() createsecurefolder(path) end)
        success = ok
    elseif create_secure_folder then
        local ok = pcall(function() create_secure_folder(path) end)
        success = ok
    end

    if success then
        SP:ConsoleInfo("Secure folder created at path: " .. path)
        return true
    else
        SP:ConsoleWarn("Failed to create secure folder; using fallback.")
        local fallback = Instance.new("Folder")
        fallback.Name = path
        fallback.Parent = self:SGS("CoreGui") or game:GetService("CoreGui")
        return fallback
    end
end

-- Protect GUI across multiple environments
function SP:ProtectGui(gui)
    if typeof(gui) ~= "Instance" then
        SP:ConsoleErr("ProtectGui called with non-instance: " .. tostring(gui))
        return
    end

    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        SP:ConsoleInfo("GUI protected via syn.protect_gui")
    elseif protect_gui then
        protect_gui(gui)
        SP:ConsoleInfo("GUI protected via protect_gui")
    elseif gethui then
        gui.Parent = gethui()
        SP:ConsoleInfo("GUI parented to gethui()")
    else
        local cg = self:SGS("CoreGui") or game:GetService("CoreGui")
        gui.Parent = cg
        SP:ConsoleInfo("GUI parented to CoreGui (fallback)")
    end
end

-- Console / logging functions (Wave's console API wrappers + fallback to print)

-- Clears console if supported
function SP:ConsoleClear()
    if rconsoleclear then
        rconsoleclear()
    end
end

-- Close/destroy console
function SP:ConsoleClose()
    if rconsoleclose then
        rconsoleclose()
    elseif rconsoledestroy then
        rconsoledestroy()
    end
end

-- Create a new console
function SP:ConsoleCreate()
    if rconsolecreate then
        rconsolecreate()
    end
end

-- Set console name/title
function SP:ConsoleName(title)
    if rconsolename then
        rconsolename(title)
    elseif rconsolesettitle then
        rconsolesettitle(title)
    end
end

-- Print a plain message
function SP:ConsolePrint(msg)
    if rconsoleprint then
        rconsoleprint(tostring(msg))
    else
        print(msg)
    end
end

-- Print with RGB coloring (if supported)
function SP:PrintConsole(msg, r, g, b)
    if printconsole then
        printconsole(tostring(msg), r or 255, g or 255, b or 255)
    else
        -- fallback: normal print
        print(msg)
    end
end

-- Info (prefix with [INFO])
function SP:ConsoleInfo(msg)
    if rconsoleinfo then
        rconsoleinfo(tostring(msg))
    else
        -- fallback: prefix and print
        print("[INFO] " .. tostring(msg))
    end
end

-- Error (prefix with [ERROR])
function SP:ConsoleErr(msg)
    if rconsoleerr then
        rconsoleerr(tostring(msg))
    else
        print("[ERROR] " .. tostring(msg))
    end
end

-- Debug (distinct style)
function SP:ConsoleDebug(msg)
    if rconsoledebug then
        rconsoledebug(tostring(msg))
    else
        print("[DEBUG] " .. tostring(msg))
    end
end

-- Input (pause and await user input)
function SP:ConsoleInput()
    if rconsoleinput then
        return rconsoleinput()
    else
        -- No interactive console support; fallback: return nil or prompt in regular console
        return nil
    end
end

-- Initialization / loader
function SP:Load()
    self:ConsoleInfo("SP+Console: Initializing...")
    -- Optionally, auto-create a console window
    self:ConsoleCreate()
    -- Set a name
    self:ConsoleName("SP Console")
    self:ConsoleInfo("SP+Console ready.")
end

return SP
