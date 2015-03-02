--[[
LuCI - Lua Configuration Interface

]]--

module("luci.controller.wifi_schedule", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/wifi_schedule") then
		return
	end
	
	local page

	page = entry({"admin", "network", "wifi_schedule"}, cbi("wifi_schedule/schedule"), _("Wifi Schedule"), 500)
	page.dependent = true
end
