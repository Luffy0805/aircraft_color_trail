-- Internationalization support
local S = minetest.get_translator(minetest.get_current_modname())

local pa28_color_smoke = {}
local player_states = {}

-- Configuration des décalages de fumée par avion
-- x : décalage latéral (mode 2/3)
-- y : décalage vertical (mode 2/3)
-- z : décalage longitudinal (mode 1)
local offset_config = {
    ["PA-28"] = {
        mode1 = {x =   0, y =   0, z = -1},
        mode2 = {x =   3, y = -0.2},
        mode3 = {x =   3, y = -0.2},
    },
    ["Savoia S-21"] = {
        mode1 = {x =   0, y =   0, z = -4},
        mode2 = {x =   4, y = -0.3},
        mode3 = {x =   4, y = -0.3},
    },
    ["Sopwith F1 Camel"] = {
        mode1 = {x =   0, y =   0, z = -2},
        mode2 = {x =   3, y = -0.2},
        mode3 = {x =   3, y = -0.2},
    },
    ["Albatros"] = {
        mode1 = {x =   0, y =   0, z = -4},
        mode2 = {x =   15, y = -0.3},
        mode3 = {x =   4, y = -0.3},
    },
    ["Super Cub"] = {
        mode1 = {x =   0, y =   0, z = -2},
        mode2 = {x =   3, y = -0.2},
        mode3 = {x =   3, y = -0.2},
    },
    ["Super Duck Hydroplane"] = {
        mode1 = {x =   0, y =   0, z = -4},
        mode2 = {x =   15, y = -0.3},
        mode3 = {x =   4, y = -0.3},
    },
    ["Ju 52 3M"] = {
        mode1 = {x =   0, y =   0, z = -2},
        mode2 = {x =   3, y = -0.2},
        mode3 = {x =   3, y = -0.2},
    },
    ["Ju 52 3M Hydroplane"] = {
        mode1 = {x =   0, y =   0, z = -4},
        mode2 = {x =   15, y = -0.3},
        mode3 = {x =   4, y = -0.3},
    },
    -- Ajoutez ici d'autres avions si besoin
	
}

-- Fonction pour trouver l'entité de l'appareil piloté par le joueur
local function get_aircraft_entity_for_player(player)
    local name = player:get_player_name()
    local pos = player:get_pos()
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 20)) do
        local ent = obj:get_luaentity()
        if ent and ent._vehicle_name and (ent.driver_name == name or ent.co_pilot == name) then
            return ent
        end
    end
    return nil
end

-- Fonctions de gestion de la teinte (colour)
local function find_colorant_in_pa28_inv(inv, index)
    index = index or 1
    if not inv then return nil end
    local list = inv:get_list("main") or {}
    local dyes = {}
    for _, st in ipairs(list) do
        if not st:is_empty() then
            local nm = st:get_name()
            if nm:find("dye:") == 1 then table.insert(dyes, nm) end
        end
    end
    local cmap = {
        ["dye:black"] = "#000000", ["dye:blue"] = "#0000FF", ["dye:brown"] = "#964B00",
        ["dye:cyan"] = "#00FFFF", ["dye:dark_green"] = "#006400", ["dye:dark_grey"] = "#A9A9A9",
        ["dye:green"] = "#008000", ["dye:grey"] = "#808080", ["dye:magenta"] = "#FF00FF",
        ["dye:orange"] = "#FFA500", ["dye:pink"] = "#FFC0CB", ["dye:red"] = "#FF0000",
        ["dye:violet"] = "#8A2BE2", ["dye:white"] = "#FFFFFF", ["dye:yellow"] = "#FFFF00",
    }
    local dye = dyes[index]
    return dye and (cmap[dye] or "#FFFFFF") or nil
end

local function remove_one_dye_from_inv(inv)
    if not inv then return false end
    local list = inv:get_list("main") or {}
    for i, st in ipairs(list) do
        if not st:is_empty() and st:get_name():find("dye:") == 1 then
            st:take_item(1)
            inv:set_stack("main", i, st)
            return true
        end
    end
    return false
end

local function remove_dye_from_inv_slot(inv, slot_index)
    if not inv then return false end
    local list = inv:get_list("main") or {}
    local cnt = 0
    for i, st in ipairs(list) do
        if not st:is_empty() and st:get_name():find("dye:") == 1 then
            cnt = cnt + 1
            if cnt == slot_index then
                st:take_item(1)
                inv:set_stack("main", i, st)
                return true
            end
        end
    end
    return false
end

-- Fonction principale pour spawn des particules en fonction du mode et configs avion
local function spawn_color_particles_at(pos, color, mode, yaw, inv, vehicle_name)
    local cfg = offset_config[vehicle_name] or offset_config["PA-28"]

    if mode == "2" or mode == "3" then
        local key = (mode == "2") and "mode2" or "mode3"
        local conf = cfg[key] or {x = 3, y = -0.2}

        local dir = minetest.yaw_to_dir(yaw)
        local right = {x = -dir.z, y = conf.y, z = dir.x}
        local left  = {x = dir.z,  y = conf.y, z = -dir.x}

        local pr = vector.add(pos, vector.multiply(right, conf.x))
        local pl = vector.add(pos, vector.multiply(left,  conf.x))

        if mode == "2" then
            local function spawn(p)
                minetest.add_particlespawner({
                    amount = 10, 
					time = 20,
                    minpos = vector.subtract(p, {x=0.3,y=0.3,z=0.3}),
                    maxpos = vector.add (p, {x=0.3,y=0.3,z=0.3}),
                    minvel = {x=0.001,y=-0.001,z=0.001}, 
					maxvel = {x=0.001,y=0.001,z=0.001},
                    minacc = {x=-0.001,y=0,z=-0.001}, 
					maxacc = {x=0.001,y=0.001,z=0.001},
                    minexptime = 30, 
					maxexptime = 5, 
					minsize = 10, 
					maxsize = 12,
                    texture = "smoke.png^[colorize:"..color..":100", 
					glow = 15,
                })
            end
            spawn(pl); spawn(pr)

        else -- mode 3
            local colL = find_colorant_in_pa28_inv(inv,1) or "#FFFFFF"
            local colR = find_colorant_in_pa28_inv(inv,2) or "#FFFFFF"
            local function spawn(p,c)
                minetest.add_particlespawner({
                    amount = 10, 
					time = 20,
                    minpos = vector.subtract(p, {x=0.3,y=0.3,z=0.3}),
                    maxpos = vector.add(p, {x=0.3,y=0.3,z=0.3}),
                    minvel = {x=0.001,y=-0.001,z=0.001}, 
					maxvel = {x=0.001,y=0.001,z=0.001},
                    minacc = {x=-0.001,y=0,z=-0.001}, 
					maxacc = {x=0.001,y=0.001,z=0.001},
                    minexptime = 30, 
					maxexptime = 50, 
					minsize = 10, 
					maxsize = 12,
                    texture = "smoke.png^[colorize:"..c..":100", 
					glow = 15,
                })
            end
            spawn(pl,colL); spawn(pr,colR)
        end

    else
        local conf = cfg.mode1 or {x=0,y=0,z=-2}
        local dir = minetest.yaw_to_dir(yaw)
        local sp = {
            x = pos.x + dir.x * (conf.z or -2) + (conf.x or 0),
            y = pos.y + (conf.y or 0),
            z = pos.z + dir.z * (conf.z or -2) + (conf.x or 0),
        }
        minetest.add_particlespawner({
            amount = 10, 
			time = 20,
            minpos = vector.subtract(sp,{x=0.7,y=0.7,z=0.7}),
            maxpos = vector.add (sp,{x=0.7,y=0.7,z=0.7}),
            minvel = {x=0.01,y=-0.01,z=0.01}, 
			maxvel = {x=0.01,y=0.01,z=0.01},
            minacc = {x=-0.0015,y=0,z=-0.0015}, 
			maxacc = {x=0.0015,y=0.001,z=0.0015},
            minexptime = 30, 
			maxexptime = 50, 
			minsize = 12, 
			maxsize = 14,
            texture = "smoke.png^[colorize:"..color..":100", 
			glow = 15,
        })
    end
end

-- Déclaration de l'outil (remote) pour déclencher et changer les modes
minetest.register_tool("aircraft_color_trail:remote", {
    description = S("Color Smoke Remote (Mode 1 - Central)"),
    inventory_image = "color_smoke_remote.png",

    on_use = function(itemstack, user, pointed_thing)
        local ctrl = user:get_player_control()
        local meta = itemstack:get_meta()
        local mode = meta:get_string("mode") or "1"

        if ctrl.aux1 or ctrl.sneak then
            -- mode change
			
            if mode == "1" then 
                mode = "2"
                meta:set_string("description", S("Color Smoke Remote (Mode 2 - Side Jets)"))
            elseif mode == "2" then 
                mode = "3"
                meta:set_string("description", S("Color Smoke Remote (Mode 3 - Dual Colored Jets)"))
            else 
                mode = "1"
                meta:set_string("description", S("Color Smoke Remote (Mode 1 - Central)"))
            end
            meta:set_string("mode", mode)
            minetest.chat_send_player(user:get_player_name(), S("Mode %s"):format(mode))
            return itemstack
        end

        local pname = user:get_player_name()
        local plane = get_aircraft_entity_for_player(user)
        if not plane then
            minetest.chat_send_player(pname, S("You must be a pilot or co-pilot of a plane."))
            return itemstack
        end

        -- Check supported plane on EACH click
        local vehicle_name = plane._vehicle_name
        local vehicle_cfg = offset_config[vehicle_name]
        if not vehicle_cfg then
            minetest.chat_send_player(pname, S("Plane not supported for smoke: ") .. (vehicle_name or S("Unknown")))
            local supported = {}
            for k, _ in pairs(offset_config) do
                table.insert(supported, k)
            end
            table.sort(supported)
            minetest.chat_send_player(pname, S("Supported planes: ") .. table.concat(supported, ", "))
            return itemstack
        end

        local inv = plane._inv
        if not inv then
            minetest.chat_send_player(pname, S("Plane inventory inaccessible."))
            return itemstack
        end
        if #inv:get_list("main") == 0 then
            minetest.chat_send_player(pname, S("Inventory is empty."))
            return itemstack
        end
        local color = find_colorant_in_pa28_inv(inv)
        if not color then
            minetest.chat_send_player(pname, S("No dye found."))
            return itemstack
        end

        local st = player_states[pname]
        if st and st.active then
            st.active = false
            minetest.chat_send_player(pname, S("Smoke deactivated."))
        else
            player_states[pname] = {active = true, time_accum = 0, last_pos = user:get_pos(), warned_ground = false}
            minetest.chat_send_player(pname, S("Smoke activated."))
        end
        return itemstack
    end,
})



-- Global management in globalstep for dye consumption and spawning
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pname = player:get_player_name()
        local st = player_states[pname]

        if st and st.active then
            local plane = get_aircraft_entity_for_player(player)

            -- If no longer in a plane or inventory inaccessible
            if not plane or not plane._inv then
                st.active = false
                minetest.chat_send_player(pname, S("You left the plane: smoke stopped."))
                -- Reset warnings
                st.warned_ground = false
                st.last_plane_warned = nil

            elseif plane.isonground then
                -- If on ground and not warned yet
                if not st.warned_ground then
                    minetest.chat_send_player(pname, S("On ground: smoke deactivated."))
                    st.warned_ground = true
                    st.active = false

                    -- Check supported plane and send message if not
                    local vehicle_name = plane._vehicle_name
                    local vehicle_cfg = offset_config[vehicle_name]
                    if not vehicle_cfg then
                        minetest.chat_send_player(pname, S("Plane not supported for smoke: ") .. (vehicle_name or S("Unknown")))
                        local supported = {}
                        for k, _ in pairs(offset_config) do
                            table.insert(supported, k)
                        end
                        table.sort(supported)
                        minetest.chat_send_player(pname, S("Supported planes: ") .. table.concat(supported, ", "))
                        st.last_plane_warned = vehicle_name
                    else
                        st.last_plane_warned = nil
                    end
                end

            else
                -- In flight
                st.warned_ground = false

                local inv = plane._inv
                local color = find_colorant_in_pa28_inv(inv)
                if not color then
                    st.active = false
                    minetest.chat_send_player(pname, S("Out of dye: smoke stopped."))
                    st.last_plane_warned = nil
                else
                    local vehicle_name = plane._vehicle_name
                    local vehicle_cfg = offset_config[vehicle_name]

                    -- Check supported plane
                    if not vehicle_cfg then
                        if st.last_plane_warned ~= vehicle_name then
                            minetest.chat_send_player(pname, S("Plane not supported for smoke: ") .. (vehicle_name or S("Unknown")))
                            local supported = {}
                            for k, _ in pairs(offset_config) do
                                table.insert(supported, k)
                            end
                            table.sort(supported)
                            minetest.chat_send_player(pname, S("Supported planes: ") .. table.concat(supported, ", "))
                            st.last_plane_warned = vehicle_name
                        end
                        st.active = false
                    else
                        -- Plane supported, reset warning
                        st.last_plane_warned = nil

                        local pos = player:get_pos()
                        local wield = player:get_wielded_item()
                        local mode = wield:get_meta():get_string("mode") or "1"
                        local yaw = (plane.object and plane.object:get_yaw()) or 0
                        local dir = minetest.yaw_to_dir(yaw)

                        -- Calculate main spawn point
                        local spawn_base
                        if mode == "2" or mode == "3" then
                            spawn_base = vector.new(pos)
                        else
                            local conf = vehicle_cfg.mode1 or {x=0, y=0, z=-2}
                            local zoff = conf.z or -2
                            spawn_base = {
                                x = pos.x - dir.x * (-zoff),
                                y = pos.y + (conf.y or 0),
                                z = pos.z - dir.z * (-zoff)
                            }
                        end

                        -- Spawn colored particles
                        spawn_color_particles_at(spawn_base, color, mode, yaw, inv, vehicle_name)

                        -- Manage dye consumption
                        if mode == "1" then
                            st.time_accum = (st.time_accum or 0) + dtime
                            if st.time_accum >= 10 then
                                st.time_accum = st.time_accum - 10
                                if not remove_one_dye_from_inv(inv) then
                                    st.active = false
                                    minetest.chat_send_player(pname, S("Out of dye: smoke stopped."))
                                end
                            end
                        elseif mode == "2" then
                            st.time_accum = (st.time_accum or 0) + dtime
                            if st.time_accum >= 5 then
                                st.time_accum = st.time_accum - 5
                                if not remove_one_dye_from_inv(inv) then
                                    st.active = false
                                    minetest.chat_send_player(pname, S("Out of dye: smoke stopped."))
                                end
                            end
                        elseif mode == "3" then
                            st.time_accum_slot1 = (st.time_accum_slot1 or 0) + dtime
                            st.time_accum_slot2 = (st.time_accum_slot2 or 0) + dtime

                            if st.time_accum_slot1 >= 10 then
                                st.time_accum_slot1 = st.time_accum_slot1 - 10
                                if not remove_dye_from_inv_slot(inv, 1) then
                                    st.active = false
                                    minetest.chat_send_player(pname, S("Out of dye slot 1: smoke stopped."))
                                end
                            end
                            if st.time_accum_slot2 >= 10 then
                                st.time_accum_slot2 = st.time_accum_slot2 - 10
                                if not remove_dye_from_inv_slot(inv, 2) then
                                    st.active = false
                                    minetest.chat_send_player(pname, S("Out of dye slot 2: smoke stopped."))
                                end
                            end
						else 
                            st.time_accum = (st.time_accum or 0) + dtime
                            if st.time_accum >= 10 then
                                st.time_accum = st.time_accum - 10
                                if not remove_one_dye_from_inv(inv) then
                                    st.active = false
                                    minetest.chat_send_player(pname, S("Out of dye: smoke stopped."))
                                end
                            end
						end
                        st.last_pos = pos
                    end
                end
            end
        end
    end
end)



-- Integrated manual
minetest.register_craftitem("aircraft_color_trail:manual", {
    description = S("Color Smoke System Manual"),
    inventory_image = "book_pa28.png",
	stack_max = 1,
    on_use = function(itemstack, player, pointed_thing)
        minetest.show_formspec(player:get_player_name(), "pa28_color_trail:manual",
            "size[8,9]"..
            "label[0.3,0.2;"..S("How the Color Smoke System works:").."]"..
            -- manual details retained...
            "textarea[0.3,0.7;7.8,8;;;"..
            S("This mod adds a colored smoke trail system for the PA-28 airplane.").."\n\n"..
            S("- Left click toggles smoke").."\n"..
            S("- AUX1 or SNEAK + left click changes mode").."\n\n"..
            S("Modes:").."\n1. "..S("Central jet (1 dye/10s)").."\n2. "..S("Side jets (1 dye/5s)").."\n3. "..S("Dual‑colored jets (slots 1 & 2, 1 dye each/10s)")..
            "\n\n"..
            S("Dyes must be in the airplane’s inventory.").."\n"..
            S("Smoke only works while flying.")..
            "]"
        )
        return itemstack
    end,
})


minetest.register_chatcommand("my_plane", {
    description = S("Affiche le nom de ton véhicule actuel"),
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, S("Joueur non trouvé.")
        end
        local plane = get_aircraft_entity_for_player(player)
        if not plane then
            return false, S("Tu ne pilotes ni ne copilotes aucun avion.")
        end
        local vehicle_name = plane._vehicle_name or S("Inconnu")
        return true, S("Ton véhicule est : ") .. vehicle_name
    end,
})