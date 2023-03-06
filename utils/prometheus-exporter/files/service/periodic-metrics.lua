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

local info = require("aredn.info")

local metrics_conf = "/etc/metrics.conf"
local metrics_data = "/tmp/periodic-metrics"
local myhostname = info.get_nvram("node") or "localnode"
local M = {}
local metrics = {}

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

function M.run_metrics(is_daily)

	-- Build a table of my peers on demand
	local peers = nil
	function is_peers(hostname)
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

	for line in io.lines(metrics_conf)
	do
		local freq, type, args = line:match("^%s*(%a*)%s+(%S+)%s+(%S+)%s*$")
		if freq == "hourly" or (freq == "daily" and is_daily) then
			if type == "iperf3" then
				local hostname, protocol = args:match("(%S+)%s+(%S+)")
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

	-- Update metrics data for async retrieval
	f = io.open(metrics_data, "w")
	if f then
		local keys = {}
		for k, _ in pairs(metrics)
		do
			keys[#keys + 1] = k
		end
		table.sort(keys)
		for _, k in ipairs(keys)
		do
			f:write(k .. " " .. metrics[k])
		end
		f:close()
	end
end

function M.periodic_metrics()
	-- Only run if we havw a configuration
	if not nixio.fs.stat(metrics_conf) then
		exit_app()
		return
	end

	-- Run once per hour, but signal each 24 hour period
	local count = 0
	while true
    do
		M.run_metrics(count == 0)
		count = (count + 1) % 24
        wait_for_ticks(60 * 60) -- 1 hour
    end
end

return M.periodic_metrics
