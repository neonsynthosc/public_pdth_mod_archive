function GroupAITweakData:_set_hard()
	self.max_nr_simultaneous_boss_types = 10
	self.unit_categories.shield.max_amount = 4
	self.unit_categories.taser.max_amount = 2
	self.unit_categories.spooc.max_amount = 2
	self.unit_categories.tank.max_amount = 2

	self.besiege.assault.units = {
		swat = {0.6, 0.6, 0.6},
		swat_kevlar = {0.2, 0.2, 0.2},
		shield = {0.08, 0.08, 0.08},
		tank = {0.04, 0.04, 0.04},
		spooc = {0.02, 0.02, 0.02},
		taser = {0.09, 0.09, 0.09}
	}
	self.street.assault.units = {
		swat = {0.6, 0.6, 0.6},
		swat_kevlar = {0.2, 0.2, 0.2},
		shield = {0.08, 0.08, 0.08},
		tank = {0.04, 0.04, 0.04},
		spooc = {0.02, 0.02, 0.02},
		taser = {0.09, 0.09, 0.09}
	}

	self.besiege.assault.force = {56, 56, 56}
	self.street.assault.force.aggressive = {44, 44, 44}
	self.street.assault.force.defensive = {12, 12, 12}
	self.street.blockade.force.defend = {12, 12, 12}
	self.street.blockade.force.frontal = {44, 44, 44}
end

function GroupAITweakData:_set_overkill()
	self.max_nr_simultaneous_boss_types = 11
	self.unit_categories.shield.max_amount = 4
	self.unit_categories.taser.max_amount = 3
	self.unit_categories.spooc.max_amount = 2
	self.unit_categories.tank.max_amount = 2

	self.besiege.assault.units = {
		swat = {0.54, 0.54, 0.54},
		swat_kevlar = {0.18, 0.18, 0.18},
		shield = {0.1, 0.1, 0.1},
		tank = {0.05, 0.05, 0.05},
		spooc = {0.03, 0.03, 0.03},
		taser = {0.1, 0.1, 0.1}
	}
	self.street.assault.units = {
		swat = {0.54, 0.54, 0.54},
		swat_kevlar = {0.18, 0.18, 0.18},
		shield = {0.1, 0.1, 0.1},
		tank = {0.05, 0.05, 0.05},
		spooc = {0.03, 0.03, 0.03},
		taser = {0.1, 0.1, 0.1}
	}

	self.besiege.assault.force = {72, 72, 72}
	self.street.assault.force.aggressive = {60, 60, 60}
	self.street.assault.force.defensive = {12, 12, 12}
	self.street.blockade.force.defend = {12, 12, 12}
	self.street.blockade.force.frontal = {60, 60, 60}
end

function GroupAITweakData:_set_overkill_145()
	self.max_nr_simultaneous_boss_types = 12
	self.unit_categories.shield.max_amount = 4
	self.unit_categories.taser.max_amount = 3
	self.unit_categories.spooc.max_amount = 2
	self.unit_categories.tank.max_amount = 3

	self.besiege.assault.units = {
		swat = {0.36, 0.36, 0.36},
		swat_kevlar = {0.36, 0.36, 0.36},
		shield = {0.1, 0.1, 0.1},
		tank = {0.05, 0.05, 0.05},
		spooc = {0.03, 0.03, 0.03},
		taser = {0.1, 0.1, 0.1}
	}
	self.street.assault.units = {
		swat = {0.36, 0.36, 0.36},
		swat_kevlar = {0.36, 0.36, 0.36},
		shield = {0.1, 0.1, 0.1},
		tank = {0.05, 0.05, 0.05},
		spooc = {0.03, 0.03, 0.03},
		taser = {0.1, 0.1, 0.1}
	}

	self.besiege.assault.force = {84, 84, 84}
	self.street.assault.force.aggressive = {72, 72, 72}
	self.street.assault.force.defensive = {12, 12, 12}
	self.street.blockade.force.defend = {12, 12, 12}
	self.street.blockade.force.frontal = {72, 72, 72}
end

function GroupAITweakData:_set_overkill_193()
	self.max_nr_simultaneous_boss_types = 18
	self.unit_categories.shield.max_amount = 8
	self.unit_categories.taser.max_amount = 4
	self.unit_categories.spooc.max_amount = 3
	self.unit_categories.tank.max_amount = 3

	self.besiege.assault.units = {
		swat = {0.13, 0.13, 0.13},
		swat_kevlar = {0.39, 0.39, 0.39},
		shield = {0.18, 0.18, 0.18},
		tank = {0.09, 0.09, 0.09},
		spooc = {0.05, 0.05, 0.05},
		taser = {0.38, 0.18, 0.18}
	}
	self.street.assault.units = {
		swat = {0.13, 0.13, 0.13},
		swat_kevlar = {0.39, 0.39, 0.39},
		shield = {0.18, 0.18, 0.18},
		tank = {0.09, 0.09, 0.09},
		spooc = {0.05, 0.05, 0.05},
		taser = {0.38, 0.18, 0.18}
	}

	self.besiege.assault.force = {108, 108, 108}
	self.street.assault.force.aggressive = {96, 96, 96}
	self.street.assault.force.defensive = {12, 12, 12}
	self.street.blockade.force.defend = {12, 12, 12}
	self.street.blockade.force.frontal = {96, 96, 96}
end