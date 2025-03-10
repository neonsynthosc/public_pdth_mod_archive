local module = ... or DorHUD:module('juke_box')

module:add_menu_option("bank_music", {
	type = "multi_choice",
	text_id = "debug_bank",
	help_id = "menu_bank_music_help",
	localize_choices = false,
	choices = {
		{"bank",  "Gun Metal Grey"},
		{"str", "Double Cross"},
		{"apa","Phoney Money / The Take"},
		{"bri",  "Stone Cold"},
		{"dia", "Breach of Security"},
		{"sla", "Crime Wave"}
	},
	default_value = "bank"
})
module:add_menu_option("heat_street_music", {
	type = "multi_choice",
	text_id = "debug_street",
	help_id = "menu_str_music_help",
	localize_choices = false,
	choices = {
		{"bank",  "Gun Metal Grey"},
		{"str", "Double Cross"},
		{"apa","Phoney Money / The Take"},
		{"bri",  "Stone Cold"},
		{"dia", "Breach of Security"},
		{"sla", "Crime Wave"}
	},
	default_value = "str"
})
module:add_menu_option("apartment_music", {
	type = "multi_choice",
	text_id = "debug_apartment",
	help_id = "menu_apa_music_help",
	localize_choices = false,
	choices = {
		{"bank",  "Gun Metal Grey"},
		{"str", "Double Cross"},
		{"apa","Phoney Money / The Take"},
		{"bri",  "Stone Cold"},
		{"dia", "Breach of Security"},
		{"sla", "Crime Wave"}
	},
	default_value = "apa"
})
module:add_menu_option("bridge_music", {
	type = "multi_choice",
	text_id = "debug_bridge",
	help_id = "menu_bri_music_help",
	localize_choices = false,
	choices = {
		{"bank",  "Gun Metal Grey"},
		{"str", "Double Cross"},
		{"apa","Phoney Money / The Take"},
		{"bri",  "Stone Cold"},
		{"dia", "Breach of Security"},
		{"sla", "Crime Wave"}
	},
	default_value = "bri"
})
module:add_menu_option("diamond_heist_music", {
	type = "multi_choice",
	text_id = "debug_diamond_heist",
	help_id = "menu_dia_music_help",
	localize_choices = false,
	choices = {
		{"bank",  "Gun Metal Grey"},
		{"str", "Double Cross"},
		{"apa","Phoney Money / The Take"},
		{"bri",  "Stone Cold"},
		{"dia", "Breach of Security"},
		{"sla", "Crime Wave"}
	},
	default_value = "dia"
})
module:add_menu_option("slaughter_house_music", {
	type = "multi_choice",
	text_id = "debug_slaughter_house",
	help_id = "menu_sla_music_help",
	localize_choices = false,
	choices = {
		{"bank",  "Gun Metal Grey"},
		{"str", "Double Cross"},
		{"apa", "Phoney Money / The Take"},
		{"bri", "Stone Cold"},
		{"dia", "Breach of Security"},
		{"sla", "Crime Wave"}
	},
	default_value = "sla"
})