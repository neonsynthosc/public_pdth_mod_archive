return DMod:new("extended_mute", {
    author = "dorentuz",
    categories = "players",
    description = "Allows you to chooses to mute a player in text and/or voice chat.",
    dependencies = { "enhanced_chat", "[calm_down_bro]" },
    priority = 9999, -- should run after all other chat output hooks
    update = { id = "pdthextmute", url = "https://www.dropbox.com/s/0jv6pny4g8xgc14/version.txt?dl=1" },
    version = "1.0",
	hooks = {
        {
            "lib/managers/menumanager", function(module)
                local MutePlayer = module:hook_class("MutePlayer")
                module:hook(MutePlayer, "modify_node", function(self, node, up)
                    local new_node = deep_clone(node)
                    for _, peer in pairs(managers.network:session():peers()) do
                        -- name label
                        local label_item = node:create_item({ type = "MenuItemDivider" }, {
                            name = "mute_player_" .. peer:user_id(),
                            text_id = peer:name(true, true),
                            localize = "false"
                        })
                        new_node:add_item(label_item)
                        -- text
                        local text_item = node:create_item(managers.menu:create_checkbox_item_values({
                            name = "mute_text_" .. peer:user_id(),
                            text_id = "menu_mute_text",
                            callback = "mute_player_text",
                            peer = peer
                        }))
                        text_item:set_value(peer:property("mute_text") and "on" or "off")
                        new_node:add_item(text_item)
                        -- voip
                        local voip_item = node:create_item(managers.menu:create_checkbox_item_values({
                            name = "mute_voip_" .. peer:user_id(),
                            text_id = "menu_mute_voice",
                            callback = "mute_player",
                            rpc = peer:rpc(),
                            peer = peer
                        }))
                        voip_item:set_value(managers.network.voice_chat:is_muted(peer) and "on" or "off")
                        new_node:add_item(voip_item)
                        -- sounds
                        if D:has_module("calm_down_bro") then
                            local sounds_item = node:create_item(managers.menu:create_checkbox_item_values({
                                name = "mute_sounds_" .. peer:user_id(),
                                text_id = "menu_mute_sounds",
                                callback = "mute_player_sounds",
                                peer = peer
                            }))
                            sounds_item:set_value(peer:property("mute_sounds") and "on" or "off")
                            new_node:add_item(sounds_item)
                        end
                    end
                    managers.menu:add_back_button(new_node)
                    return new_node
                end, true)

                local MenuCallbackHandler = module:hook_class("MenuCallbackHandler")
                module:hook(MenuCallbackHandler, "mute_player_text", function(self, item)
                    item:parameters().peer:set_property("mute_text", item:value() == "on")
                end, false)
                module:hook(MenuCallbackHandler, "mute_player_sounds", function(self, item)
                    item:parameters().peer:set_property("mute_sounds", item:value() == "on")
                end, false)
            end
        },
        {
            "event", "OnChatOutput", "OnChatOutput_MutePlayers", function(msg, _, offset, options)
                if not options or not options.sender_id or options.sender_id < 1 then
                    return
                end

                local session = managers.network and managers.network:session()
                local peer = session and session:peer(options.sender_id)
                if peer and peer:property("mute_text") then
                    return false
                end
            end
        }
    },
    localization = {
        english = { menu_mute_voice = "Mute voice chat", menu_mute_text = "Mute text chat", menu_mute_sounds = "Mute sounds" },
        french  = { menu_mute_voice = "Chat vocal muet", menu_mute_text = "Chat texte muet", menu_mute_sounds = "Sons muets" },
        german  = { menu_mute_voice = "Stummschalten des Sprachchats", menu_mute_text = "Text-Chat stumm schalten", menu_mute_sounds = "Stummschaltung von Sounds" },
        italian = { menu_mute_voice = "Silenziare la chat vocale", menu_mute_text = "Silenziare la chat di testo", menu_mute_sounds = "Suoni silenziosi" },
        korean  = { menu_mute_voice = "음성 채팅 음소거", menu_mute_text = "문자 채팅 음소거", menu_mute_sounds = "음소거" },
        russian = { menu_mute_voice = "Голосовой чат без звука", menu_mute_text = "Немой текстовый чат", menu_mute_sounds = "Глухие звуки" },
        spanish = { menu_mute_voice = "Silenciar chat de voz", menu_mute_text = "Silenciar chat de texto", menu_mute_sounds = "Silenciar los sonidos" },
    }
})