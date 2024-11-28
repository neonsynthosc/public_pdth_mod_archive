function GroupAITweakData:_set_overkill()
	local is_singleplayer = Global.game_settings.single_player
	self.difficulty_curve_points = {0.1}
	self.max_nr_simultaneous_boss_types = 8

	self.unit_categories.tank.max_amount = 2
	self.unit_categories.taser.max_amount = 2
	self.unit_categories.spooc.max_amount = 2
	self.unit_categories.shield.max_amount = 2

	self.besiege.assault.sustain_duration_min = {150, 180, 250}
	self.besiege.assault.sustain_duration_max = {200, 220, 360}
	self.besiege.assault.delay = {20, 20, 20}
	self.besiege.assault.units = {
		swat = {0, 0, 0},
		swat_kevlar = {1, 1, 0.25},
		shield = {0.5, 0.5, 0.5},
		tank = {0.5, 0.5, 0.5},
		spooc = {0.5, 0.5, 0.5},
		taser = {0.5, 0.5, 0.5}
	}
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = {50, 70, 90}
	self.street.assault.sustain_duration_max = {60, 90, 120}
	self.street.assault.delay = {40, 35, 30}
	self.street.assault.units = {
		swat = {0.5, 0.25, 0},
		swat_kevlar = {1, 1, 0.25},
		shield = {0.5, 0.5, 0.5},
		tank = {0.35, 0.35, 0.35},
		taser = {0.5, 0.5, 0.5},
		spooc = {0.5, 0.5, 0.5}
	}
	self.street.blockade.units = {
		defend = {
			swat = {1, 0.5, 0.5},
			swat_kevlar = {0.4, 1, 1},
			shield = {0.1, 0.2, 0.3}
		},
		frontal = {
			swat = {1, 0.5, 0.5},
			swat_kevlar = {0.2, 0.5, 1},
			shield = {0, 0.1, 0.5},
			spooc = {0.1, 0.3, 0.4}
		},
		flank = {
			spooc = {1, 1, 1},
			taser = {1, 1, 1},
			fbi_special = {0.001, 0.001, 0.001}
		}
	}
end

function GroupAITweakData:_set_overkill_145()
	local is_singleplayer = Global.game_settings.single_player
	self.difficulty_curve_points = {0.1}
	self.max_nr_simultaneous_boss_types = 8

	self.unit_categories.tank.max_amount = 2
	self.unit_categories.taser.max_amount = 2
	self.unit_categories.spooc.max_amount = 2
	self.unit_categories.shield.max_amount = 2

	self.besiege.assault.sustain_duration_min = {200, 360, 400}
	self.besiege.assault.sustain_duration_max = {200, 360, 400}
	self.besiege.assault.delay = {15, 15, 15}
	self.besiege.assault.units = {
		swat = {0, 0, 0},
		swat_kevlar = {1, 1, 0.25},
		shield = {0.5, 0.5, 0.5},
		tank = {0.5, 0.5, 0.5},
		spooc = {0.5, 0.5, 0.5},
		taser = {0.5, 0.5, 0.5}
	}
	if is_singleplayer then
		self.besiege.assault.force = {30, 30, 30}
	else
		self.besiege.assault.force = {30, 35, 35}
	end

	self.besiege.recon.interval = {50000, 50000, 50000}
	self.besiege.recon.group_size = {0, 0, 0}
	self.besiege.recon.interval_variation = 0
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = {90, 120, 160}
	self.street.assault.sustain_duration_max = {90, 120, 160}
	self.street.assault.delay = {30, 30, 30}
	self.street.assault.units = {
		swat = {0, 0, 0},
		swat_kevlar = {1, 1, 0.1},
		shield = {0.5, 0.5, 0.5},
		tank = {0.35, 0.35, 0.35},
		taser = {0.5, 0.5, 0.5},
		spooc = {0.5, 0.5, 0.5}
	}
	self.street.blockade.units = {
		defend = {
			swat = {1, 0.5, 0.5},
			swat_kevlar = {0.4, 1, 1},
			shield = {0.1, 0.2, 0.3}
		},
		frontal = {
			swat = {1, 0.5, 0.5},
			swat_kevlar = {0.2, 0.5, 1},
			shield = {0, 0.1, 0.5},
			spooc = {0.1, 0.3, 0.4}
		},
		flank = {
			spooc = {1, 1, 1},
			taser = {1, 1, 1},
			fbi_special = {0.001, 0.001, 0.001}
		}
	}
end

-- function GroupAITweakData:_set_overkill_193()
-- 	GroupAITweakData._set_overkill_145(self)
-- end