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

local M = {}
local peers = nil
local myhostname = info.get_nvram("node") or "localnode"

-- Build a table of my peers on demand
function M.is_peer(hostname)
    if not peers then
        local f = io.open("/tmp/lqm.info")
        if not f then
            return false
        end
        local lqm = luci.jsonc.parse(f:read("*a"))
        f:close()
        peers = {}
        for _, tracker in pairs(lqm.trackers)
        do
            if tracker.hostname then
                peers[tracker.hostname] = true
            end
        end
    end
    return peers[hostname]
end

function M.run_iperf3_metric(from, to, protocol)
	local bitrate = nil
	local retry = 3
	while not bitrate and retry > 0
	do
		local f = io.popen("wget -q -O - 'http://" .. from .. ":8080/cgi-bin/iperf?server=" .. to .. "&protocol=" .. protocol .. "'")
		if f then
			for line in f:lines()
			do
				if line:match("iperf is disabled") then
					break
				end
				if line:match("<title>BUSY</title>") then
					f:close()
					f = nil
					retry = retry - 1
					wait_for_ticks(math.floor(20 + 20 * math.random()))
					break
				end
				local bitrate, bu = line:match("[%d%.]+-[%d%.]+%s+sec%s+[%d%.]+ [KM]Bytes%s+([%d%.]+) ([MK])bits/sec%s+receiver")
				if bitrate then
					bitrate = tonumber(bitrate) / (bu == "K" and 1024 or 1)
					break
				end
				local bitrate, bu = line:match("[%d%.]+-[%d%.]+%s+sec%s+[%d%.]+ [KM]Bytes%s+([%d%.]+) ([MK])bits/sec%s+[%d%.]+ ms%s+%d+/%d+ %(([%d%.]+)%%%)%s+receiver")
				if bitrate then
					bitrate = tonumber(bitrate) / (bu == "K" and 1024 or 1)
					break
				end
			end
			if f then
				f:close()
			end
		end
	end
	return bitrate
end

function M.task(conf, metrics, opt)

	peers = nil

	for _, c in ipairs(conf)
	do
		if c.name == "iperf3" and (c.frequency == "hourly" or (c.frequency == "daily" and opt.is_daily)) then
            local hostname, protocol = c.arg:match("(%S+)%s+(%S+)")
            if hostname and is_peer(hostname) then
                if protocol ~= "udp" then
                    protocol = "tcp"
                end
                local rx = M.run_iperf3_metric(myhostname, hostname, protocol)
                local tx = nil
                if myhostname ~= "localnode" then
                    wait_for_ticks(1)
                    tx = M.run_iperf3_metric(hostname, myhostname, protocol)
                end
                metrics['node_periodic_iperf3_rx_bitrate{hostname="' .. hostname .. '"}'] = rx
                metrics['node_periodic_iperf3_tx_bitrate{hostname="' .. hostname .. '"}'] = tx
            end
		end
	end

end

return M.task
