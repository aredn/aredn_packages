#!/usr/bin/lua
--[[

	Part of AREDN -- Used for creating Amateur Radio Emergency Data Networks
	Copyright (C) 2023 Tim Wilkinson
	See Contributors file for additional contributors

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Additional Terms:

	Additional use restrictions exist on the AREDN(TM) trademark and logo.
		See AREDNLicense.txt for more info.

	Attributions to the AREDN Project must be retained in the source code.
	If importing this code into a new or existing project attribution
	to the AREDN project must be added to the source code.

	You must not misrepresent the origin of the material contained within.

	Modified versions must be modified to attribute to the original source
	and be marked in reasonable ways as differentiate it from the original
	version

--]]

require("luci.jsonc")

local f = io.open("/tmp/wireless_monitor.info")
if f then
    local info = luci.jsonc.parse(f:read("*a"))
    f:close()

    print('# HELP node_wifimon_action')
    print('# TYPE node_wifimon_action gauge')
    for k,v in pairs(info.action_state)
    do
        print('node_wifimon_action{action="' .. k .. '"} ' .. (v and 1 or 0))
    end

    print('# HELP node_wifimon_stations')
    print('# TYPE node_wifimon_stations gauge')
    print('node_wifimon_stations ' .. #info.unresponsive.stations)

    print('# HELP node_wifimon_unresponsive_station')
    print('# TYPE node_wifimon_unresponsive_station gauge')
    local c = 0
    for ip, v in ipairs(info.unresponsive.stations)
    do
        if v >= 1 then
            c = c + 1
        end
        print('node_wifimon_unresponsive_station{remote_ip="' .. ip .. '"}' .. v)
    end
    print('# HELP node_wifimon_unresponsive_stations')
    print('# TYPE node_wifimon_unresponsive_stations gauge')
    print('node_wifimon_unresponsive_stations ' .. c)
end
