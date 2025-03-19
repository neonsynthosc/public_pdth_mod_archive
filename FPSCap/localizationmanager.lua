
-- Derived from MenuNodeGui:init()
local string_ids_all = {
	[Idstring("english"):key()] = {
		["menu_fps_limit"] = "FRAME RATE LIMIT",
		["menu_fps_limit_help"] = "Specify the maximum frame rate in frames per second. Use lower values to decrease overheating & mouse lag."
	},
	[Idstring("french"):key()] = {
		["menu_fps_limit"] = "LIMITE IPS",
		["menu_fps_limit_help"] = "Spécifiez le taux d'IPS maximum en images par seconde. Des valeurs faibles causeront moins de surchauffe et moins de latence souris."
	},
	[Idstring("german"):key()] = {
		["menu_fps_limit"] = "Max. Bildrate",
		["menu_fps_limit_help"] = "Wähle die maximale Bildrate in Bildern pro Sekunde. Verwende niedrigere Werte, um Überhitzung & Mauslag zu verringern."
	},
	[Idstring("italian"):key()] = {
		["menu_fps_limit"] = "LIMITE DEL FRAME RATE",
		["menu_fps_limit_help"] = "Determina il frame rate massimo in frame al secondo. Usa valori più bassi per diminuire il surriscaldamento e il ritardo di risposta del mouse."
	},
	[Idstring("spanish"):key()] = {
		["menu_fps_limit"] = "Límite de velocidad de fotogramas",
		["menu_fps_limit_help"] = "Especifique la velocidad de fotogramas máxima en imágenes por segundo. Utilice valores más bajos para disminuir el sobrecalentamiento y Ratón Lag."
	},
	-- Not sure if PD:TH supports adding languages this way since I can't test whether it works or fails for them
	[Idstring("dutch"):key()] = {
		["menu_fps_limit"] = "FRAMERATE LIMIET",
		["menu_fps_limit_help"] = "Bepaal de maximale framerate in frames per seconde. Gebruik lagere waardes om overhitting en muisvertraging te voorkomen."
	},
	-- Apparently PD:TH doesn't have a Russian font set so these turn into long strings of underscores instead, boo  :/
	[Idstring("russian"):key()] = {
		["menu_fps_limit"] = "ОГРАНИЧЕНИЕ FPS",
		["menu_fps_limit_help"] = "Укажите максимальное количество кадров в секунду. Используйте пониженные значения, чтобы снизить перегрев компьютера и задержку мыши."
	}
}

-- Defaults to English
local string_ids = string_ids_all[Idstring("english"):key()]

local init_actual = LocalizationManager.init
function LocalizationManager:init(...)
	init_actual(self, ...)

	string_ids = string_ids_all[SystemInfo:language():key()] or string_ids
end

local text_actual = LocalizationManager.text
function LocalizationManager:text(string_id, ...)
	if string_id == nil then
		return tostring(string_id)
	end

	return string_ids[string_id] or text_actual(self, string_id, ...)
end
