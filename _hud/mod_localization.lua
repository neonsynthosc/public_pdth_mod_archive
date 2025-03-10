local module = ... or D:module("_hud")

local strings = {
	["_hud_scaling"] = {
		english = "HUD Scale",
		spanish = "Escala del HUD",
		german = "HUD Skalierung",
	},
	["_hud_font_scaling"] = {
		english = "HUD Font Scale",
		spanish = "Escala de la fuente del HUD",
		german = "HUD Schriftskalierung",
	},
	["_hud_use_custom_name_labels"] = {
		english = "Use custom name labels",
		spanish = "Utilizar etiquetas de vida personalizadas",
		german = "Nutze benutzerdefinierte Namenlabel",
	},
	["_hud_peer_contour_colors"] = {
		english = "Color code player and deployable contours",
		spanish = "Utilizar colores de jugador en los contornos del jugador y desplegables",
		german = "Farbcode Spieler und Einsetzbar-Konturen",
	},
	["_hud_use_custom_health_panel"] = {
		english = "Use custom health panel",
		spanish = "Usar panel de vida personalizado",
		german = "Nutze benutzerdefiniertes Gesundheitspanel",
	},
	["_hud_custom_health_panel_layout"] = {
		english = "Health Panel Layout",
		spanish = "Diseño del panel de salud",
		german = "Gesundheitspanellayout",
	},
	["_hud_vanilla_style"] = {
		english = "Vanilla Style",
		spanish = "Estilo Vanilla",
		german = "Vanilla Stil",
	},
	["_hud_raid_style"] = {
		english = "Raid Style",
		spanish = "Estilo Raid",
		german = "Raid Stil",
	},
	["_hud_raid_alt_style"] = {
		english = "Alternative Raid Style",
		spanish = "Estilo Raid alternativo",
		german = "Alternatives Raid Stil",
	},
	["_hud_display_armor_and_health_values"] = {
		english = "Display armor and health values",
		spanish = "Mostrar valores de armadura y vida",
		german = "Zeige Rüstungs- und Gesundheitswerte",
	},
	["_hud_display_armor_and_health_values_help"] = {
		english = "Show text items that indicate your raw armor and health values.",
		spanish = "Muestra textos que indican los valores armadura y vida.",
		german = "Zeige Text, welches deine Rüstungs- und Gesundheitswerte darstellt.",
	},
	["_hud_display_armor_regen_timer"] = {
		english = "Display armor regen timer",
		spanish = "Mostrar tiempo de regeneración de armadura",
		german = "Zeige Rüstungs-Regenerationstimer",
	},
	["_hud_display_armor_regen_timer_help"] = {
		english = "Shows a timer that indicates the time remaining for your armor to regenerate.",
		spanish = "Muestra un temporizador que indica el tiempo restante para que tu armadura se regenere.",
		german = "Zeigt einen Timer, welches darstellt, wie lange es dauert, bis deine Rüstung regeneriert.",
	},
	["_hud_reposition_chat_input"] = {
		english = "Reposition chat input panel",
		spanish = "Reposicionar el panel de chat",
		german = "Repositioniere Chateingabepanel",
	},
	["_hud_reposition_chat_input_help"] = {
		english = "Move the chat input panel above the top player mugshot.",
		spanish = "Mueve la entrada de texto del chat para que este sobre el último panel de jugador.",
		german = "Bewege den Chateingabepanel über das Polizeifoto des obersten Spielers.",
	},
	["_hud_use_custom_inventory_panel"] = {
		english = "Use custom inventory panel",
		spanish = "Utilizar el panel de inventario personalizado",
		german = "Nutze benutzerdefinierten Inventarpanel",
	},
	["_hud_mugshot_name"] = {
		english = "Mugshot name",
		spanish = "Nombre de la foto policial",
		german = "Polizeifoto-Name",
	},
	["_hud_mugshot_name_help"] = {
		english = "Select what to display as your username in the custom health panel.",
		spanish = "Selecciona qué mostrar como tu nombre de usuario en el panel de vida personalizado.",
		german = "Wähle, was dein Nutzername im benutzerdefinierten Gesundheitspanel sein soll.",
	},
	["_hud_character_name"] = {
		english = "Character name",
		spanish = "Nombre del personaje",
		german = "Charaktername",
	},
	["_hud_steam_username"] = {
		english = "Steam username",
		spanish = "Nombre de Steam",
		german = "Steam Nutzername",
	},
	["_hud_short_username"] = {
		english = "Shortened Steam username",
		spanish = "Nombre de Steam acortado",
		german = "Abgekürzter Steam Nutzername",
	},
	["_hud_custom_username"] = {
		english = "Custom username",
		spanish = "Nombre de usuario personalizado",
		german = "Benutzerdefinierter Nutzername",
	},
	["_hud_custom_mugshot_name"] = {
		english = "Custom mugshot name",
		spanish = "Nombre personalizado",
		german = "Benutzerdefinierter Polizeibild-Name",
	},
	["_hud_display_name_in_upper_cases"] = {
		english = "Display mugshot name in upper cases",
		spanish = "Mostrar nombre en mayúsculas",
		german = "Zeige Polizeibild-Namen in Großbuchstaben",
	},
	["_hud_name_use_peer_color"] = {
		english = "Use peer color in custom health bar",
		spanish = "Utilizar color del jugador en el panel de vida",
		german = "Nutze Peer-Farbe in benutzerdefinierter Gesundheitsleiste",
	},
	["_hud_name_use_peer_color_help"] = {
		english = "Sets your name color to match your chat color.",
		spanish = "Colorea tu nombre para que coincida con tu color de chat.",
		german = "Legt deine Namensfarbe fest, damit es zu deiner Chatfarbe passt.",
	},
	["_hud_enable_custom_ammo_panel"] = {
		english = "Use custom ammo panel",
		spanish = "Utilizar indicador de munición personalizado.",
		german = "Nutze benutzerdefinierten Munitionspanel",
	},
	["_hud_custom_ammo_panel_style"] = {
		english = "Weapon Panel Style",
		spanish = "Estilo del panel de armas",
	},
	["_hud_style_vanilla_plus"] = {
		english = "Vanilla+",
	},
	["_hud_style_custom"] = {
		english = "Custom",
		spanish = "Personalizado",
	},
	["_hud_ammo_panel_show_real_ammo"] = {
		english = "Show real ammo values",
		spanish = "Mostrar valores de municion verdaderos",
		german = "Zeige reale Munitionswerte",
	},
	["_hud_ammo_panel_show_real_ammo_help"] = {
		english = "Show total ammo count without taking in mind the munition inside your current clip.",
		spanish = "Muestra el valor total de tu minición sin tomar en cuenta la munición de tu cargador.",
		german = "Zeige insgesamte Munition ohne die Munition in deinem aktuellen Magazin zu berücksichtigen.",
	},
	["_hud_enable_deployable_spy"] = {
		english = "Enable deployable spy",
		spanish = "Habilidar espía de desplegables",
		german = "Aktiviere den Spion für Einsetzbares",
	},
	["_hud_enable_deployable_spy_help"] = {
		english = "Show remaining bag charges and sentry gun ammo and health.",
		spanish = "Muestra la cantidad de cargas restantes en las bolsas y la cantidad de vida y munición restante en una torreta.",
		german = "Zeige, wieviel in den Taschen übrig ist und wieviel Munition und Gesundheit die Sentrygun hat.",
	},
	["_hud_medic_bag_spy"] = {
		english = "Medic Bag text format",
		german = "Arzttasche Textformat",
	},
	["_hud_medic_bag_spy_help"] = {
		english = "$CHARGES; = Shows remaining charges.\n$PERCENT; = Shows remaining percentage.\n\nSupports DAHM Color tags.",
		german = "$CHARGES; = Zeigt übrige Ladungen.\n$PERCENT; = Zeige übrigen prozentualen Anteil.\n\nUnterstützt DAHM Farbmarkierungen.",
	},
	["_hud_ammo_bag_spy"] = {
		english = "Ammo Bag text format",
		german = "Munitionstasche Textformat",
	},
	["_hud_ammo_bag_spy_help"] = {
		english = "$CHARGES; = Shows remaining charges.\n$PERCENT; = Shows remaining percentage.\n\nSupports DAHM Color tags.",
		german = "$CHARGES; = Zeigt übrige Ladungen.\n$PERCENT; = Zeige übrigen prozentualen Anteil.\n\nUnterstützt DAHM Farbmarkierungen.",
	},
	["_hud_sentry_gun_spy"] = {
		english = "Sentry Gun text format",
		german = "Sentrygun Textformat",
	},
	["_hud_sentry_gun_spy_help"] = {
		english = "$AMMO; = Shows current ammo.\n$AMMO_MAX; = Shows max ammo.\n$HEALTH; = Shows current health.\n\nSupports color tags.",
		german = "$AMMO; = Zeigt momentane Munition.\n$AMMO_MAX; = Zeigt maximale Munition.\n$HEALTH; = Zeigt momentane Gesundheit.\n\nUnterstützt DAHM Farbmarkierungen.",
	},
	["_hud_use_custom_drop_in_panel"] = {
		english = "Use custom drop-in panel",
		spanish = "Utilizar panel personalizado de entrada de jugador.",
		german = "Nutze benutzerdefiniertes Eintrittspanel",
	},
	["_hud_drop_in_peer_info"] = {
		english = "Level: $LEVEL;\nMask set: $MASK;\nDeployable: $DEPLOYABLE;\nCrew bonus: $CREW_BONUS;\nReady: $READY;",
		spanish = "Nivel: $LEVEL;\nSet de máscara: $MASK;\nEquipamiento desplegable: $DEPLOYABLE;\nBono de equipo: $CREW_BONUS;\nPreparado: $READY;",
		german = "Level: $LEVEL;\nMaskenset: $MASK;\nEinsetzbares: $DEPLOYABLE;\nTeambonus: $CREW_BONUS;\nBereit: $READY;",
	},
	["_hud_drop_in_show_peer_info"] = {
		english = "Show peer info in drop in",
		spanish = "Mostrar información del jugador mientras se une",
		german = "Zeige Peerinfo beim Eintritt",
	},
	["_hud_drop_in_show_peer_info_help"] = {
		english = "Shows loadout info about the joining peer.",
		spanish = "Muestra información sobre el equipamiento del jugador que se esta uniendo a la partida.",
		german = "Zeige Ausrüstungsinfo vom eintretenden Peer.",
	},
	["_hud_leftbottom"] = {
		english = "Left Bottom",
		spanish = "Abajo a la izquierda",
		german = "Links unten",
	},
	["_hud_lefttop"] = {
		english = "Left Top",
		spanish = "Arriba a la izquierda",
		german = "Links oben",
	},
	["_hud_centertop"] = {
		english = "Center Top",
		spanish = "Centrado arriba",
		german = "Mitte oben",
	},
	["_hud_righttop"] = {
		english = "Right Top",
		spanish = "Arriba a la derecha",
		german = "Rechts oben",
	},
	["_hud_rightbottom"] = {
		english = "Right Bottom",
		spanish = "Abajo a la derecha",
		german = "Rechts unten",
	},
	["_hud_centerbottom"] = {
		english = "Bottom Center",
		spanish = "Centrado abajo",
		german = "Mitte unten",
	},
	["_hud_mod_list_position"] = {
		english = "Player mod list position",
		spanish = "Posición de la lista de mods del jugador",
		german = "Spieler Modlistenposition",
	},
	["_hud_drop_in_mod_list_title"] = {
		english = "Gameplay changing mods",
		spanish = "Mods que alteran la jugabilidad",
		german = "Gameplay-verändernde Mods",
	},
	["_hud_reload_timer"] = {
		english = "Show reload timer",
		spanish = "Mostrar el tiempo de recarga",
		german = "Zeige Nachlade-Timer",
	},
	["_hud_shotgun_fire_timer"] = {
		english = "Show shotgun fire timer",
		spanish = "Mostrar el tiempo de disparo de escopetas",
		german = "Zeige Shotgun Feuerungstimer",
	},
	["_hud_yes"] = {
		english = "Yes",
		spanish = "Sí",
		german = "Ja",
	},
	["_hud_no"] = {
		english = "No",
		spanish = "No",
		german = "Nein",
	},
	["_hud_none_selected"] = {
		english = "None selected",
		spanish = "Ninguno seleccionado",
		german = "Nichts ausgewählt",
	},
	["_hud_use_custom_control_panel"] = {
		english = "Use custom control panel",
		german = "Nutze benutzerdefinierten Kontrolle-Panel",
	},
	["_hud_assault_title"] = {
		english = "Police Assault in Progress",
		german = "Polizeivorstoß im Gange",
	},
	["_hud_reinforced_assault_title"] = {
		english = "Reinforced Police Assault in Progress",
		german = "Verstärkter Polizeivorstoß im Gange",
	},
	["_hud_use_custom_ponr_panel"] = {
		english = "Use custom point of no return panel",
		german = "Nutze benutzerdefinierten Kein-Zurück-Mehr-Panel",
	},
	["_hud_ponr_title"] = {
		english = "Point of no return in $TIME;",
		german = "Kein Zurück mehr in $TIME;",
	},
	["_hud_use_loadout_dropdowns"] = {
		english = "Use loadout dropdowns",
		german = "Nutze Ausrüstungsdropdowns",
	},
	["_hud_use_loadout_dropdowns_help"] = {
		english = "Allows you to quickly equip weapons, equipments and crew bonuses without having to switch through all of them.\n\nRequires DAHM 1.6.1.1 or above.",
		german = "Ermöglicht dir, schnell Waffen, Einsetzbares und Teamboni auszusuchen, ohne durchzuwechseln.\n\nBenötigt DAHM 1.6.1.1 oder höher.",
	},
}

for key, translations in pairs(strings) do
	module:add_localization_string(key, translations)
end
