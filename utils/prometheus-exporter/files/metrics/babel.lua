#!/usr/bin/lua
--[[

	Part of AREDN -- Used for creating Amateur Radio Emergency Data Networks
	Copyright (C) 2025 Tim Wilkinson
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

local f = io.popen("/usr/sbin/babel-dump")
if f then
    local lines = f:read("*a")
    f:close()
    local interfaces = 0;
    local neighbors = 0; 
    local routes = 0;
    local xroutes = 0;
    for line in lines:gmatch("[^\r\n]+")
    do
        if line:match("interface") then
            interfaces = interfaces + 1
        elseif line:match("neighbour") then
            neighbors = neighbors + 1
        elseif line:match("xroute") then
            xroutes = xroutes + 1
        elseif line:match("route") then
            routes = routes + 1
        end
    end
    f:close()
    print('# HELP node_babel_interface_total')
    print('# HELP node_babel_interface_total counter')
    print('# HELP node_babel_neighbor_total')
    print('# HELP node_babel_neighbor_total counter')
    print('# HELP node_babel_routes_total')
    print('# HELP node_babel_routes_total counter')
    print('# HELP node_babel_xroutes_total')
    print('# HELP node_babel_xroutes_total counter')
    print('node_babel_interface_total ' .. interfaces)
    print('node_babel_neighbor_total ' .. neighbors)
    print('node_babel_xroute_total ' .. xroutes)
    print('node_babel_route_total ' .. routes)
end
