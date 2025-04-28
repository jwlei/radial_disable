-- @Author taakefyrsten
-- https://next.nexusmods.com/profile/taakefyrsten
-- Version 1.1

-- INIT ------------------------------------
local shouldSkipPad = true

local type_GUI020008 = sdk.find_type_definition("app.GUI020008")
local type_GUI030208 = sdk.find_type_definition("app.GUI030208")
local type_cGUIShortcutPadControl = sdk.find_type_definition("app.cGUIShortcutPadControl")


-- SETTINGS --------------------------------
local config = {
    Enable = true,  -- Toggle mod
}

local function debug(msg)
    local timestamp = os.date("%H:%M:%S")
    print('[RD]' .. '[' .. timestamp .. ']'.. '[DEBUG] ' .. tostring(msg))
end


local function save_config()
    json.dump_file("radial_disable.json", config)
end

local function load_config()
    if loadedTable == nil then
        loadedTable= json.load_file("radial_disable.json")
    end 
    if loadedTable then
        config = loadedTable
        if config.Enable == nil then
            config.Enable = 1
        end
    else
        save_config()
    end
end

load_config()


local function disableGUI020008(args)
    if config.Enable == true then
       shouldSkipPad = true
       return sdk.PreHookResult.SKIP_ORIGINAL 
    end
    
end

local function skipPadInput(args)
    if config.Enable == true and shouldSkipPad == true then 
        debug('SKIPPING PAD')
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end



-- HOOKS --------------------------------
if config.Enable == true then
    if type_GUI020008 then
        --sdk.hook(type_GUI020008:get_method('onOpenApp'), disableGUI020008, nil)
        sdk.hook(type_GUI020008:get_method('guiHudUpdate'), disableGUI020008, nil)
        sdk.hook(type_GUI020008:get_method('guiHudVisibleUpdate'), disableGUI020008, nil)
        sdk.hook(type_GUI020008:get_method('checkOpen'), disableGUI020008, function(retval) return false end)
    
    end

    -- Dont skip pad in customize radial menu
    if type_GUI030208 then
        sdk.hook(
            type_GUI030208:get_method("guiVisibleUpdate"),
            function(args)
                shouldSkipPad = false
            end,
            nil
        )
    end

    -- Skip pad control if HUD is closed
    if type_cGUIShortcutPadControl then
        sdk.hook(type_cGUIShortcutPadControl:get_method("move(System.Single, via.vec2)"), skipPadInput, nil)
    end
end


-- reFramework config ----------------------------
re.on_draw_ui(function()
    if imgui.tree_node("Radial disable") then
        if imgui.checkbox("Enable", config.Enable) then
            config.Enable = not config.Enable
            save_config()
            load_config()
        end
        imgui.tree_pop()
    end
end)
