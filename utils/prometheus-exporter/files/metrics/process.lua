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

local props = {
    Name = "name",
    VmPeak = "vm_peak_bytes",
    VmSize = "vm_size_bytes",
    VmLck = "vm_lck_bytes",
    VmPin = "vm_pin_bytes",
    VmHWM = "vm_hwm_bytes",
    VmRSS = "vm_rss_bytes",
    VmData = "vm_data_bytes",
    VmStk = "vm_stk_bytes",
    VmExe = "vm_exe_bytes",
    VmLib = "vm_lib_bytes",
    VmPTE = "vm_pte_bytes",
    VmSwap = "vm_swap_bytes",
    RssAnon = "rss_anon_bytes",
    RssFile = "rss_file_bytes",
    RssShmem = "rss_shmem_bytes"
};

for _, p in pairs(props)
do
    print("# HELP node_process_" .. p)
    print("# TYPE node_process_" .. p .. " gauge")
end
for proc in nixio.fs.dir("/proc")
do
    if proc:match("^%d+$") then
        local f = io.open("/proc/" .. proc .. "/cmdline")
        if f then
            if f:read("*a") ~= "" then
                for line in io.lines("/proc/" .. proc .. "/status")
                do
                    local k, v = line:match("^([^:]+):[ \t]+([^ \t]+)")
                    if k and props[k] then
                        if k == "Name" then
                            print('node_process_' .. props[k] .. '{pid="' .. proc .. '",name="' .. v .. '"} 1')
                        else
                            print('node_process_' .. props[k] .. '{pid="' .. proc .. '"} ' .. (1024 * v))
                        end
                    end
                end
            end
            f:close()
        end
    end
end
