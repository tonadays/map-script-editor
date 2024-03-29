TOOL.Category = "Trouble in Terrorist Town"
TOOL.Name = "#tool.tttscripteditor.name"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["selected_entity"] = ""
TOOL.ClientConVar["replacespawns"] = "0"
TOOL.ClientConVar["auto_ammo"] = "0"
TOOL.ClientConVar["auto_ammo_max"] = "6"
cleanup.Register("ttt_weapons")

if CLIENT then
    language.Add("tool.tttscripteditor.name", "TTT Script Editor")
    language.Add("tool.tttscripteditor.desc", "Spawn entity dummies and import/export their placement")
    language.Add("tool.tttscripteditor.0", "Left click to spawn entity. Right click for matching entity, usually ammo.")
    language.Add("tool.tttscripteditor.none", "No entity selected")
    language.Add("Cleanup_ttt_weapons", "TTT Dummy Weapons/ammo/spawns")
    language.Add("Undone_TTTWeapon", "Undone TTT item")
end

-- TTT entity kind enum globals
WEAPON_NONE = 0
WEAPON_MELEE = 1
WEAPON_PISTOL = 2
WEAPON_HEAVY = 3
WEAPON_NADE = 4
WEAPON_CARRY = 5
WEAPON_EQUIP1 = 6
WEAPON_EQUIP2 = 7
WEAPON_ROLE = 8
-- Entity kind enum globals specific to map script editor
WEAPON_RANDOM = 9
AMMO_RANDOM = 10
AMMOSPAWN = 11
PLAYERSPAWN = 12
-- Strings corrosponding to each entity kind
--[[
local entity_kind_names = {
    [WEAPON_NONE] = "None",
    [WEAPON_MELEE] = "Crowbar",
    [WEAPON_PISTOL] = "Secondary weapon",
    [WEAPON_HEAVY] = "Primary weapon",
    [WEAPON_NADE] = "Grenade",
    [WEAPON_CARRY] = "Magneto-stick",
    [WEAPON_EQUIP1] = "Primary equipment",
    [WEAPON_EQUIP2] = "Secondary equipment",
    [WEAPON_ROLE] = "Default equipment",
    [WEAPON_RANDOM] = "Random weapon",
    [AMMO_RANDOM] = "Random ammo",
    [AMMOSPAWN] = "Ammo spawn",
    [PLAYERSPAWN] = "Player spawn",
}
--]]
-- Entity group enum globals
ENTGROUP_EDITOR = 0
ENTGROUP_PRIMARY = 1
ENTGROUP_SECONDARY = 2
ENTGROUP_AMMO = 3
ENTGROUP_NADE = 4
ENTGROUP_EQUIPMENT = 5
ENTGROUP_SPECIAL = 6

-- Grouping entities together using aformentioned entity groups
local entity_group_names = {
    [ENTGROUP_EDITOR] = "Editor",
    [ENTGROUP_PRIMARY] = "Primary",
    [ENTGROUP_SECONDARY] = "Secondary",
    [ENTGROUP_AMMO] = "Ammo",
    [ENTGROUP_NADE] = "Grenades",
    [ENTGROUP_EQUIPMENT] = "Equipment",
    [ENTGROUP_SPECIAL] = "Special",
}

-- Mapping entity kinds to entity groups
local entity_group_index = {
    [WEAPON_NONE] = ENTGROUP_SPECIAL,
    [WEAPON_MELEE] = ENTGROUP_SPECIAL,
    [WEAPON_PISTOL] = ENTGROUP_SECONDARY,
    [WEAPON_HEAVY] = ENTGROUP_PRIMARY,
    [WEAPON_NADE] = ENTGROUP_NADE,
    [WEAPON_CARRY] = ENTGROUP_SPECIAL,
    [WEAPON_EQUIP1] = ENTGROUP_EQUIPMENT,
    [WEAPON_EQUIP2] = ENTGROUP_EQUIPMENT,
    [WEAPON_ROLE] = ENTGROUP_EQUIPMENT,
    [WEAPON_RANDOM] = ENTGROUP_EDITOR,
    [AMMO_RANDOM] = ENTGROUP_EDITOR,
    [AMMOSPAWN] = ENTGROUP_AMMO,
    [PLAYERSPAWN] = ENTGROUP_EDITOR,
}

-- Entity info table, will be filtered of ents unavailable in the current game
local available_ents = {
    -- Default primary weapons
    weapon_zm_shotgun = {
        kind = WEAPON_HEAVY,
        name = "Shotgun",
        mdl = "models/weapons/w_shot_xm1014.mdl",
        snd = "item_box_buckshot_ttt"
    },
    weapon_zm_mac10 = {
        kind = WEAPON_HEAVY,
        name = "MAC10",
        mdl = "models/weapons/w_smg_mac10.mdl",
        snd = "item_ammo_smg1_ttt"
    },
    weapon_zm_rifle = {
        kind = WEAPON_HEAVY,
        name = "Rifle",
        mdl = "models/weapons/w_snip_scout.mdl",
        snd = "item_ammo_357_ttt"
    },
    weapon_zm_sledge = {
        kind = WEAPON_HEAVY,
        name = "HUGE249",
        mdl = "models/weapons/w_mach_m249para.mdl",
        snd = nil
    },
    weapon_ttt_m16 = {
        kind = WEAPON_HEAVY,
        name = "M16",
        mdl = "models/weapons/w_rif_m4a1.mdl",
        snd = "item_ammo_pistol_ttt"
    },
    -- Default secondary weapons
    weapon_zm_pistol = {
        kind = WEAPON_PISTOL,
        name = "Pistol",
        mdl = "models/weapons/w_pist_fiveseven.mdl",
        snd = "item_ammo_pistol_ttt"
    },
    weapon_zm_revolver = {
        kind = WEAPON_PISTOL,
        name = "Deagle",
        mdl = "models/weapons/w_pist_deagle.mdl",
        snd = "item_ammo_revolver_ttt"
    },
    weapon_ttt_glock = {
        kind = WEAPON_PISTOL,
        name = "Glock",
        mdl = "models/weapons/w_pist_glock18.mdl",
        snd = "item_ammo_pistol_ttt"
    },
    -- Ammunition
    item_ammo_pistol_ttt = {
        kind = AMMOSPAWN,
        name = "Pistol/Rifle Ammo",
        mdl = "models/items/boxsrounds.mdl",
        snd = nil
    },
    item_ammo_smg1_ttt = {
        kind = AMMOSPAWN,
        name = "SMG ammo",
        mdl = "models/items/boxmrounds.mdl",
        snd = nil
    },
    item_ammo_revolver_ttt = {
        kind = AMMOSPAWN,
        name = "Revolver Ammo",
        mdl = "models/items/357ammo.mdl",
        color = Color(255, 100, 100),
        snd = nil
    },
    item_ammo_357_ttt = {
        kind = AMMOSPAWN,
        name = "Sniper Rifle Ammo",
        mdl = "models/items/357ammo.mdl",
        snd = nil
    },
    item_box_buckshot_ttt = {
        kind = AMMOSPAWN,
        name = "Shotgun Ammo",
        mdl = "models/items/boxbuckshot.mdl",
        snd = nil
    },
    -- Grenades
    weapon_zm_molotov = {
        kind = WEAPON_NADE,
        name = "Fire nade",
        mdl = "models/weapons/w_eq_flashbang.mdl",
        snd = nil
    },
    weapon_ttt_confgrenade = {
        kind = WEAPON_NADE,
        name = "Discombobulator",
        mdl = "models/weapons/w_eq_fraggrenade.mdl",
        snd = nil
    },
    weapon_ttt_smokegrenade = {
        kind = WEAPON_NADE,
        name = "Smoke nade",
        mdl = "models/weapons/w_eq_smokegrenade.mdl",
        snd = nil
    },
    -- Specific to map script editor
    ttt_random_weapon = {
        kind = WEAPON_RANDOM,
        name = "Random weapon",
        -- mdl = "models/weapons/w_shotgun.mdl",
        mdl = "models/weapons/w_irifle.mdl",
        color = Color(255, 255, 0),
        snd = "ttt_random_ammo"
    },
    ttt_random_ammo = {
        kind = AMMO_RANDOM,
        name = "Random ammo",
        mdl = "models/Items/battery.mdl",
        color = Color(0, 255, 0),
        snd = nil
    },
    ttt_playerspawn = {
        kind = PLAYERSPAWN,
        name = "Player spawn",
        mdl = "models/player.mdl",
        color = Color(0, 255, 0),
        snd = nil
    }
}

-- Ents unavailable in the current game
local unavailable_ents = {}

-- General utility for getting table size where # won't work
local function GetTableSize(t)
    local count = 0

    for _, __ in pairs(t) do
        count = count + 1
    end

    return count
end

-- Checks that the model path is valid and, if supplied, that the entity's lua file exists in the given path
local function IsValidEditorEnt(info)
    if not info then return false end
    if not info.mdl or not util.IsValidModel(info.mdl) then return false end
    -- This check is only performed for custom weapons and entities which have a string in the lua key
    if info.lua and not file.Exists(info.lua, "GAME") then return false end

    return true
end

local function DummyInit(s)
    local cls = s:GetClass()

    -- special colours for certain ents
    if available_ents[cls].color then
        s:SetColor(available_ents[cls].color)
    end

    s:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    s:SetSolid(SOLID_VPHYSICS)
    s:SetMoveType(MOVETYPE_VPHYSICS)

    -- special init for ttt_playerspawn
    if cls == "ttt_playerspawn" then
        s:PhysicsInitBox(Vector(-18, -18, -0.1), Vector(18, 18, 66))
        s:SetPos(s:GetPos() + Vector(0, 0, 1))
    else
        s:PhysicsInit(SOLID_VPHYSICS)
    end

    s:SetModel(s.Model)
end

-- filters available_ents and inits usable entiites
for cls, info in pairs(available_ents) do
    if IsValidEditorEnt(info) then
        local ent_tbl = {
            Type = "anim",
            Model = Model(info.mdl),
            Initialize = DummyInit
        }

        scripted_ents.Register(ent_tbl, cls, false)
    else
        unavailable_ents[cls] = info
        available_ents[cls] = nil
    end
end

print("[ttt script editor] filtered " .. GetTableSize(unavailable_ents) .. " unavailable ents")

function TOOL:SpawnEntity(cls, trace)
    if not cls then return end
    -- entity info
    local info = available_ents[cls]

    if not info or not info.mdl then
        error("attempted to spawn ent " .. cls .. "with missing or incomplete info")

        return
    end

    local ent = ents.Create(cls)
    ent:SetModel(info.mdl)
    ent:SetPos(trace.HitPos)

    local tr = util.TraceEntity({
        start = trace.StartPos,
        endpos = trace.HitPos,
        filter = self:GetOwner()
    }, ent)

    if tr.Hit then
        ent:SetPos(tr.HitPos)
    end

    ent:Spawn()
    ent:PhysWake()
    undo.Create("TTTWeapon")
    undo.AddEntity(ent)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()
    self:GetOwner():AddCleanup("ttt_weapons", ent)
end

function TOOL:LeftClick(trace)
    local cls = self:GetClientInfo("selected_entity")

    --[[
        notification.AddLegacy("#tool.tttscripteditor.none", NOTIFY_HINT, 3)
        surface.PlaySound("buttons/button15.wav")
        Msg("Prop undone\n")
    --]]
    if cls == "" then
        self:GetOwner():ChatPrint("#tool.tttscripteditor.none")

        return
    end

    if not available_ents[cls] then
        self:GetOwner():ChatPrint("No " .. cls .. " entity available")

        return
    end

    self:SpawnEntity(cls, trace)
end

function TOOL:RightClick(trace)
    local cls = self:GetClientInfo("selected_entity")

    if cls == "" then
        self:GetOwner():ChatPrint("#tool.tttscripteditor.none")

        return
    end

    local info = available_ents[cls]

    if not info then
        self:GetOwner():ChatPrint("No " .. cls .. " entity available")

        return
    end

    if not info.snd then
        self:GetOwner():ChatPrint("No matching entity for " .. cls)

        return
    end

    self:SpawnEntity(info.snd, trace)
end

-- convenience function for BuildCPanel
local function AddSimpleDLabel(CPanel, text)
    -- local DPanel = vgui.Create( "DPanel", CPanel)
    -- DPanel:SetBackgroundColor(Color(0, 0, 0, 0))
    -- DPanel:SetContentAlignment(5) -- center
    local DLabel = vgui.Create("DLabel", CPanel)
    DLabel:SetText(text)
    DLabel:SetTextColor(Color(0, 0, 0))
    CPanel:AddItem(DLabel)
end

-- note that for historic reasons, this is not a method.
-- is there any better way to set or get cvars inside here, particularly client cvars?
function TOOL.BuildCPanel(panel)
    AddSimpleDLabel(panel, "#tool.tttscripteditor.desc")
    -- entity list
    local ent_list = vgui.Create("DListView", panel)
    ent_list:Dock(FILL)
    ent_list:SetMultiSelect(false)
    ent_list:SetHeight(200)
    ent_list:AddColumn("Name")
    ent_list:AddColumn("Group")
    local current_selected_entity = GetConVar("tttscripteditor_selected_entity"):GetString()

    for cls, info in pairs(available_ents) do
        -- access the entity group by entity kind
        local group = entity_group_index[info.kind]
        local line = ent_list:AddLine(info.name, entity_group_names[group])
        line:SetSortValue(2, group)

        if current_selected_entity ~= "" and current_selected_entity == cls then
            ent_list:SelectItem(line)
        end

        line.OnSelect = function()
            RunConsoleCommand("tttscripteditor_selected_entity", cls)
        end
    end

    ent_list:SortByColumn(2, false)
    panel:AddItem(ent_list)

    panel:AddControl("Button", {
        Label = "Report counts",
        Command = "tttscripteditor_count",
        Text = "Count"
    })

    -- auto_ammo number input
    local current_auto_ammo_value = GetConVar("tttscripteditor_auto_ammo"):GetInt()
    AddSimpleDLabel(panel, "Amount of matching ammo for all random weapons")
    local auto_ammo_max = GetConVar("tttscripteditor_auto_ammo_max"):GetInt()
    local auto_ammo_slider = vgui.Create("DNumSlider", panel)
    auto_ammo_slider:SetMin(0)
    auto_ammo_slider:SetMax(auto_ammo_max)
    auto_ammo_slider:SetDecimals(0)
    auto_ammo_slider:SetDark(true)
    auto_ammo_slider.Label:SetVisible(false)
    local auto_ammo_label = vgui.Create("DLabel", auto_ammo_slider)
    auto_ammo_label:SetText("auto_ammo")
    auto_ammo_label:SetTextColor(Color(0, 0, 0))
    auto_ammo_label:Dock(LEFT)

    auto_ammo_slider.OnValueChanged = function(self)
        -- rounding is required here because SetDecimals() doesn't affect values passed to OnValueChanged
        local value = math.Round(self:GetValue(), 0)
        local new_value = value

        if value > auto_ammo_max then
            new_value = auto_ammo_max
            self:SetValue(new_value)
        end

        RunConsoleCommand("tttscripteditor_auto_ammo", new_value)
    end

    if current_auto_ammo_value and current_auto_ammo_value ~= "" then
        local new_value = current_auto_ammo_value

        if current_auto_ammo_value > auto_ammo_max then
            new_value = auto_ammo_max
            RunConsoleCommand("tttscripteditor_auto_ammo", new_value)
        end

        auto_ammo_slider:SetValue(new_value)
    end

    panel:AddItem(auto_ammo_slider)
    -- Exporting
    AddSimpleDLabel(panel, "Export entity placements")

    panel:AddControl("CheckBox", {
        Label = "Replace existing player spawnpoints",
        Command = "tttscripteditor_replacespawns",
        Text = "Replace spawns"
    })

    panel:AddControl("Button", {
        Label = "Export to file",
        Command = "tttscripteditor_queryexport",
        Text = "Export"
    })

    -- Importing
    AddSimpleDLabel(panel, "Import entity placements")

    panel:AddControl("Button", {
        Label = "Import from file",
        Command = "tttscripteditor_queryimport",
        Text = "Import"
    })

    panel:AddControl("Button", {
        Label = "Convert HL2 entities",
        Command = "tttscripteditor_replacehl2",
        Text = "Convert"
    })

    panel:AddControl("Button", {
        Label = "Remove all existing weapon/ammo",
        Command = "tttscripteditor_removeall",
        Text = "Remove all existing items"
    })
end

-- STOOLs not being loaded on client = headache bonanza
if CLIENT then
    function QueryFileExists()
        local map = string.lower(game.GetMap())
        if not map then return end
        local fname = "ttt/maps/" .. map .. "_ttt.txt"

        if file.Exists(fname, "DATA") then
            Derma_StringRequest("File exists", "The file \"" .. fname .. "\" already exists. Save under a different filename? Leave unchanged to overwrite.", fname, function(txt)
                RunConsoleCommand("tttscripteditor_export", txt)
            end)
        else
            RunConsoleCommand("tttscripteditor_export")
        end
    end

    function QueryImportName()
        local map = string.lower(game.GetMap())
        if not map then return end
        local fname = "ttt/maps/" .. map .. "_ttt.txt"

        Derma_StringRequest("Import", "What file do you want to import? Note that files meant for other maps will result in crazy things happening.", fname, function(txt)
            RunConsoleCommand("tttscripteditor_import", txt)
        end)
    end
else
    -- again, hilarious things happen when this shit is used in mp
    concommand.Add("tttscripteditor_queryexport", function()
        BroadcastLua("QueryFileExists()")
    end)

    concommand.Add("tttscripteditor_queryimport", function()
        BroadcastLua("QueryImportName()")
    end)
end

local function PrintCount(ply)
    -- could be a simple pairs loop to make this
    local counts = {
        [WEAPON_NONE] = 0,
        [WEAPON_MELEE] = 0,
        [WEAPON_PISTOL] = 0,
        [WEAPON_HEAVY] = 0,
        [WEAPON_NADE] = 0,
        [WEAPON_CARRY] = 0,
        [WEAPON_EQUIP1] = 0,
        [WEAPON_EQUIP2] = 0,
        [WEAPON_ROLE] = 0,
        [WEAPON_RANDOM] = 0,
        [AMMO_RANDOM] = 0,
        [AMMOSPAWN] = 0,
        [PLAYERSPAWN] = 0
    }

    for cls, info in pairs(available_ents) do
        for _, ent in pairs(ents.FindByClass(cls)) do
            counts[info.kind] = counts[info.kind] + 1
        end
    end

    ply:ChatPrint("Entity count (use report_entities in console for more detail)")
    ply:ChatPrint(counts[WEAPON_HEAVY] .. " primary weapons")
    ply:ChatPrint(counts[WEAPON_PISTOL] .. " secondary weapons")
    ply:ChatPrint(counts[WEAPON_NADE] .. " grenades")
    -- ply:ChatPrint(counts[WEAPON_EQUIP1] + counts[WEAPON_EQUIP2] + counts[WEAPON_ROLE] .. "equipment")
    ply:ChatPrint(counts[WEAPON_RANDOM] .. " random weapons")
    ply:ChatPrint(counts[PLAYERSPAWN] .. " player spawns")
end

concommand.Add("tttscripteditor_count", PrintCount)

-- This shit will break terribly in MP
if SERVER or CLIENT then
    -- Could just do a GLON dump, but it's nice if the "scripts" are sort of
    -- human-readable so it's easy to go in and delete all pistols or something.
    local function Export(ply, cmd, args)
        if not IsValid(ply) then return end
        local map = string.lower(game.GetMap())
        if not map then return end
        -- Nice header, # is comment
        local buf = "# Trouble in Terrorist Town weapon/ammo placement overrides\n"
        buf = buf .. "# For map: " .. map .. "\n"
        buf = buf .. "# Exported by: " .. ply:Nick() .. "\n"
        -- Write settings ("setting: <name> <value>")
        local rspwns = GetConVar("tttscripteditor_replacespawns"):GetBool() and "1" or "0"
        buf = buf .. "setting:\treplacespawns " .. rspwns .. "\n"
        local num = 0
        local current_auto_ammo_value = GetConVar("tttscripteditor_auto_ammo"):GetInt()

        -- there was an unused cvar here for toggling an IsMoveable check as part of this, i've removed that code as it never influenced anything
        for cls, info in pairs(available_ents) do
            if cls == "ttt_random_weapon" and current_auto_ammo_value ~= 0 then
                for _, ent in pairs(ents.FindByClass(cls)) do
                    if IsValid(ent) then
                        num = num + 1
                        buf = buf .. Format("%s\t%s\t%s\tauto_ammo %s\n", cls, tostring(ent:GetPos()), tostring(ent:GetAngles()), tostring(current_auto_ammo_value))
                    end
                end
            else
                for _, ent in pairs(ents.FindByClass(cls)) do
                    if IsValid(ent) then
                        num = num + 1
                        buf = buf .. Format("%s\t%s\t%s\n", cls, tostring(ent:GetPos()), tostring(ent:GetAngles()))
                    end
                end
            end
        end

        local fname = "ttt/maps/" .. map .. "_ttt.txt"

        if args[1] then
            fname = args[1]
        end

        file.CreateDir("ttt/maps")
        file.Write(fname, buf)

        if not file.Exists(fname, "DATA") then
            ErrorNoHalt("Exported file not found. Bug?\n")
        end

        ply:ChatPrint(num .. " placements saved to /garrysmod/data/" .. fname)
    end

    concommand.Add("tttscripteditor_export", Export)

    local function SpawnDummyEnt(cls, pos, ang)
        if not cls or not pos or not ang then return true end
        local info = available_ents[cls]
        if not info or not info.mdl then return true end
        local ent = ents.Create(cls)
        ent:SetModel(info.mdl)
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        ent:SetSolid(SOLID_VPHYSICS)
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ent:PhysicsInit(SOLID_VPHYSICS)
        ent:Spawn()
        local phys = ent:GetPhysicsObject()

        if IsValid(phys) then
            phys:SetAngles(ang)
        end
    end

    local function Import(ply, cmd, args)
        if not IsValid(ply) then return end
        local map = string.lower(game.GetMap())
        if not map then return end
        local fname = "ttt/maps/" .. map .. "_ttt.txt"

        if args[1] then
            fname = args[1]
        end

        if not file.Exists(fname, "DATA") then
            ply:ChatPrint(fname .. " not found!")

            return
        end

        local buf = file.Read(fname, "DATA")
        local lines = string.Explode("\n", buf)
        local num = 0
        local warn_auto_ammo = false

        for k, line in ipairs(lines) do
            if not string.match(line, "^#") and line ~= "" then
                local data = string.Explode("\t", line)
                local fail = true -- pessimism

                if #data > 0 then
                    if data[1] == "setting:" and tostring(data[2]) then
                        local raw = string.Explode(" ", data[2])
                        RunConsoleCommand("tttscripteditor_" .. raw[1], tonumber(raw[2]))
                        fail = false
                        num = num - 1
                    elseif #data == 3 or #data == 4 then
                        if #data == 4 and not warn_auto_ammo then
                            warn_auto_ammo = true
                        end

                        local cls = data[1]
                        local ang = nil
                        local pos = nil
                        local posraw = string.Explode(" ", data[2])
                        pos = Vector(tonumber(posraw[1]), tonumber(posraw[2]), tonumber(posraw[3]))
                        local angraw = string.Explode(" ", data[3])
                        ang = Angle(tonumber(angraw[1]), tonumber(angraw[2]), tonumber(angraw[3]))
                        fail = SpawnDummyEnt(cls, pos, ang)
                    end
                end

                if fail then
                    ErrorNoHalt("Invalid line " .. k .. " in " .. fname .. "\n")
                else
                    num = num + 1
                end
            end
        end

        ply:ChatPrint("Spawned " .. num .. " dummy ents")

        if warn_auto_ammo then
            ply:ChatPrint("Script contained auto_ammo settings which have been discarded")
        end
    end

    concommand.Add("tttscripteditor_import", Import)

    local function RemoveAll(ply, cmd, args)
        if not IsValid(ply) then return end
        local num = 0

        local delete = function(ent)
            if not IsValid(ent) then return end
            print("\tRemoving", ent, ent:GetClass())
            ent:Remove()
            num = num + 1
        end

        print("Removing ammo...")

        for k, ent in pairs(ents.FindByClass("item_*")) do
            delete(ent)
        end

        for k, ent in pairs(ents.FindByClass("ttt_random_ammo")) do
            delete(ent)
        end

        print("Removing weapons...")

        for k, ent in pairs(ents.FindByClass("weapon_*")) do
            delete(ent)
        end

        for k, ent in pairs(ents.FindByClass("ttt_random_weapon")) do
            delete(ent)
        end

        ply:ChatPrint("Removed " .. num .. " weapon/ammo ents")
    end

    concommand.Add("tttscripteditor_removeall", RemoveAll)

    local hl2_replace = {
        ["item_ammo_pistol"] = "item_ammo_pistol_ttt",
        ["item_box_buckshot"] = "item_box_buckshot_ttt",
        ["item_ammo_smg1"] = "item_ammo_smg1_ttt",
        ["item_ammo_357"] = "item_ammo_357_ttt",
        ["item_ammo_357_large"] = "item_ammo_357_ttt",
        ["item_ammo_revolver"] = "item_ammo_revolver_ttt", -- zm
        ["item_ammo_ar2"] = "item_ammo_pistol_ttt",
        ["item_ammo_ar2_large"] = "item_ammo_smg1_ttt",
        ["item_ammo_smg1_grenade"] = "weapon_zm_pistol",
        ["item_battery"] = "item_ammo_357_ttt",
        ["item_healthkit"] = "weapon_zm_shotgun",
        ["item_suitcharger"] = "weapon_zm_mac10",
        ["item_ammo_ar2_altfire"] = "weapon_zm_mac10",
        ["item_rpg_round"] = "item_ammo_357_ttt",
        ["item_ammo_crossbow"] = "item_box_buckshot_ttt",
        ["item_healthvial"] = "weapon_zm_molotov",
        ["item_healthcharger"] = "item_ammo_revolver_ttt",
        ["item_ammo_crate"] = "weapon_ttt_confgrenade",
        ["item_item_crate"] = "ttt_random_ammo",
        ["weapon_smg1"] = "weapon_zm_mac10",
        ["weapon_shotgun"] = "weapon_zm_shotgun",
        ["weapon_ar2"] = "weapon_ttt_m16",
        ["weapon_357"] = "weapon_zm_rifle",
        ["weapon_crossbow"] = "weapon_zm_pistol",
        ["weapon_rpg"] = "weapon_zm_sledge",
        ["weapon_slam"] = "item_ammo_pistol_ttt",
        ["weapon_frag"] = "weapon_zm_revolver",
        ["weapon_crowbar"] = "weapon_zm_molotov"
    }

    local function ReplaceSingle(ent, new_cls_name)
        -- vector_origin is actually a global documented here: https://wiki.facepunch.com/gmod/Global_Variables
        if ent:GetPos() == vector_origin then return false end
        if ent:IsWeapon() and IsValid(ent:GetOwner()) and ent:GetOwner():IsPlayer() then return false end
        ent:SetSolid(SOLID_NONE)
        local rent = ents.Create(new_cls_name)
        rent:SetModel(available_ents[new_cls_name].mdl)
        rent:SetPos(ent:GetPos())
        rent:SetAngles(ent:GetAngles())
        rent:Spawn()
        rent:Activate()
        rent:PhysWake()
        ent:Remove()

        return true
    end

    local function ReplaceHL2Ents(ply, cmd, args)
        if not IsValid(ply) then return end
        local c = 0

        for _, ent in pairs(ents.GetAll()) do
            local rpl = hl2_replace[ent:GetClass()]

            if rpl then
                local success = ReplaceSingle(ent, rpl)

                if success then
                    c = c + 1
                end
            end
        end

        ply:ChatPrint("Replaced " .. c .. " HL2 entities with TTT versions.")
    end

    concommand.Add("tttscripteditor_replacehl2", ReplaceHL2Ents)
end