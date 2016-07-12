
--[[ Helper function to create a global player data object ]]--
local function create_global_player(player)

	if global.players[player.index] == nil then -- If there isn't a data object created for this player...
	
		global.players[player.index] = { -- Create one with the opened parameter set to nil
			opened = nil
		}
		
	end
end

--[[ on_init - Setup the global tables and generate event id's (if they don't exist) ]]--
function on_init()

	if global.players == nil then -- If the players global data doesn't exist...
		global.players = {} -- Create it
	end
	
	if global.custom_events == nil then -- If the events global data doesn't exist...
		global.custom_events = {} -- Create it
	end
	
	if not i_has("on_entity_opened") then -- If there isn't an id generated for the "on_entity_opened" event...
		i_generate("on_entity_opened") -- Generate a new one
	end
	
	if not i_has("on_entity_closed") then -- If there isn't an id generated for the "on_entity_closed" event...
		i_generate("on_entity_closed") -- Generate a new one
	end
	
end

--[[ on_tick ]]--
function on_tick(event)

	if event.tick % 10 == 0 then -- Every 10 ticks...
		
		for index, player in pairs(game.players) do -- For every player in the game...
			if player.connected then -- If the player is connected...
				create_global_player(player) -- Create a global data object for the player if he/she doesn't already have one
				
				if player.opened ~= nil and player.opened.valid and global.players[player.index].opened ~= player.opened.name then -- If a player has opened an entity but the global data says otherwise...
				
					game.raise_event(i_get("on_entity_opened"), {player_index = player.index, entity_name = player.opened.name}) -- Raise the "on_entity_opened" event
					global.players[player.index].opened = player.opened.name -- Update the global data
					
				elseif player.opened_self and global.players[player.index].opened ~= "opened_self" then -- ... Or if the player has opened himself/herself but the global data says oterwise...
				
					game.raise_event(i_get("on_entity_opened"), {player_index = player.index, entity_name = "opened_self"}) -- Raise the "on_entity_opened" event
					global.players[player.index].opened = "opened_self" -- Update the global data
					
				elseif not player.opened_self and global.players[player.index].opened == "opened_self" then -- ... Or if the player hasn't opened himself/herself but the global data says otherwise...
				
					game.raise_event(i_get("on_entity_closed"), {player_index = player.index, entity_name = global.players[player.index].opened}) -- Raise the "on_entity_closed" event
					global.players[player.index].opened = nil -- Update the global data
					
				elseif player.opened == nil and global.players[player.index].opened ~= nil and global.players[player.index].opened ~= "opened_self" then -- ... Or if the player hasn't opened an entity but the global data says otherwise...
				
					game.raise_event(i_get("on_entity_closed"), {player_index = player.index, entity_name = global.players[player.index].opened}) -- Raise the "on_entity_closed" event
					global.players[player.index].opened = nil -- Update the global data
					
				end
			end
			
		end
	end
	
end

--[[ Setup event handlers ]]--

script.on_init(on_init)
script.on_configuration_changed(on_init)
script.on_load(on_init)
script.on_event(defines.events.on_tick)


--[[ INTERFACE FUNCTIONS ]]--

--[[ Returns a list of defined custom event names ]]--
function i_events()

	local event_names = {}
	
	for name, evt in pairs(global.custom_events) do
		table.insert(event_names, name)
	end
	
	return event_names
end

--[[ Gets the id of a specific custom event ]]--
function i_get(name)

	return global.custom_events[name]
	
end

--[[ Returns true if the specified custom event name exists, false if not ]]--
function i_has(name)

	if global.custom_events[name] ~= nil then
		return true
	end
	
	return false
end

--[[ Set the specified custom event to a specific id]]--
function i_set(name, id)

	global.custom_events[name] = id
	
	return id
end

--[[ Generate a new id for a specified custom event ]]--
function i_generate(name)

	global.custom_events[name] = script.generate_event_name()
		
	return global.custom_events[name]
end

--[[ Add all interface functions to the "custom events" interface ]]--
remote.add_interface("custom events", {
	events = i_events
	
	get = i_get
	
	has = i_has
	
	set = i_set
	
	generate = i_generate
})