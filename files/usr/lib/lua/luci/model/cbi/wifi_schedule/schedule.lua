
require("luci.tools.webadmin")

m = Map("wifi_schedule", translate("Wifi Schedule"),
	translate("Wifi Schedule is a very useful app which will allow you to manage and schedule when your device Wi-Fi will turn on and off."))

s = m:section(TypedSection, "days", "Days of the week")
s.addremove = false
s.anonymous = true

s:tab("wd1", translate("Monday"))
s:tab("wd2", translate("Tuesday"))
s:tab("wd3", translate("Wednesday"))
s:tab("wd4", translate("Thursday"))
s:tab("wd5", translate("Friday"))
s:tab("wd6", translate("Saturday"))
s:tab("wd7", translate("Sunday"))

for day=1,7 do
	for i=0,23 do
		f=i
		t=i+1
		s:taboption("wd"..day, Flag, day.."_"..f,
        		translate(f..":00 - "..t..":00"),
	        	translate(""))
	end
end

s = m:section(TypedSection, "options", "Options")
s.addremove = false
s.anonymous = true

o = s:option(Value, "interval", translate("Interval to query for changes"), translate("In seconds"))
o.optional = true
o.datatype = "and(uinteger,min(30))"
o.default = 30

return m
