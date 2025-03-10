local PlayerDamage = module:hook_class("PlayerDamage")
module:hook(50, PlayerDamage, "damage_fall", function(self, data)
	return nil
end)
