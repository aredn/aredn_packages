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

require("aredn.utils")
require("aredn.hardware")
local info = require("aredn.info")

os.capture = capture

local lat, lon = info.getLatLon()

print('# HELP node_aredn_info Labeled AREDN node information.' ..
		'# TYPE node_aredn_info gauge')

print('node_aredn_info{' ..
		'board_id="' .. hardware_boardid() .. '"' ..
		',description="' .. (info.getNodeDescription() or "") .. '"' ..
		',firmware_version="' .. info.getFirmwareVersion() .. '"' ..
		',gridsquare="' .. (info.getGridSquare() or "") .. '"' ..
		',lat="' .. (lat or "") .. '"' ..
		',lon="' .. (lon or "") .. '"' ..
		',model="' .. (info.getModel() or "") .. '"' ..
		',node="' .. (info.getNodeName() or "") .. '"' ..
		',tactical="' .. (info.getTacticalName() or "") .. '"' ..
    '} 1')

local dev = info.getMeshRadioDevice()
if dev ~= "" then
	print('# HELP node_aredn_meshrf Labeled AREDN node mesh RF information.' ..
		'# TYPE node_aredn_meshrf gauge')

    print('node_aredn_meshrf{' ..
		'band="' .. info.getBand(dev) .. '"' ..
        ',channel="' .. info.getChannel(dev) .. '"' ..
        ',chanbw="' .. info.getChannelBW(dev) .. '"' ..
        ',device="' .. dev .. '"' ..
        ',frequency="' .. info.getFreq() .. '"' ..
		',ssid="' .. info.getSSID() .. '"' ..
    '} 1')
else
    print('node_details_meshrf 0')
end

print(	'# HELP node_uname_info MinimalLabeled system information as provided by the uname system call.' ..
		'# TYPE node_uname_info gauge' ..
		'node_uname_info{nodename="' .. (info.getNodeName() or "") .. '"} 1'
	)
