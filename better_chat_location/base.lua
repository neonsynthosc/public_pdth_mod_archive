local module = DMod:new("better_chat_location", {
	name = "Better Chat Location", version = "1.1",
	author = "Shane", description = {
	english = "Move down chat-input and chat size up.",
	korean = "채팅 입력창을 아래로 내리고 채팅창 사이즈를 키웁니다."
	}
})

if Util:version_compare(DorHUD:version(), "1.3.99") > 0 then
	module:set_update({
		id = "41030",
		platform = "modworkshop"
	})
end

module:hook_post_require("lib/tweak_data/tweakdata", "tweakdata", 10)
module:hook_post_require("lib/managers/hudmanager", "hudmanager", 10)

return module