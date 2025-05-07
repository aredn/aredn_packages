/*
 * Part of AREDN® -- Used for creating Amateur Radio Emergency Data Networks
 * Copyright (C) 2023-2025 Tim Wilkinson
 * See Contributors file for additional contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Additional Terms:
 *
 * Additional use restrictions exist on the AREDN® trademark and logo.
 * See AREDNLicense.txt for more info.
 *
 * Attributions to the AREDN® Project must be retained in the source code.
 * If importing this code into a new or existing project attribution
 * to the AREDN® project must be added to the source code.
 *
 * You must not misrepresent the origin of the material contained within.
 *
 * Modified versions must be modified to attribute to the original source
 * and be marked in reasonable ways as differentiate it from the original
 * version
 */

import * as fs from "fs";
import * as uci from "uci";
import * as radios from "aredn.radios";
import * as hardware from "aredn.hardware";
import * as configuration from "aredn.configuration";

const c = uci.cursor();

function tonumber(v) {
	if (v == "" || v == null) {
		return null;
	}
	return 1 * v;
}

function capture(cmd) {
	const p = fs.popen(cmd);
	if (p) {
		const v = p.read("all");
		p.close();
		return trim(v);
	}
	return null;
}

print('# HELP node_aredn_info Labeled AREDN node information.\n');
print('# TYPE node_aredn_info gauge\n');

print(`node_aredn_info{board_id="${hardware.getBoardId()}",description="${configuration.getSettingAsString("description_node", '')}",firmware_version="${configuration.getFirmwareVersion()}",gridsquare="${c.get("aredn", "@location[0]", "gridsquare")}",lat="${tonumber(c.get("aredn", "@location[0]", "lat"))}",lon="${tonumber(c.get("aredn", "@location[0]", "lon"))}",model="${capture("/usr/local/bin/get_model")}",node="${configuration.getName()}"} 1\n`);

print('# HELP node_aredn_meshrf Labeled AREDN node mesh RF information.\n');
print('# TYPE node_aredn_meshrf gauge\n');

(function () {
	const config = radios.getConfiguration();
	for (let i = 0; i < length(config); i++) {
		const cfg = config[i];
		const mode = cfg.mode;
		let rfmode;
		let ssid;
		switch (mode.mode) {
			case radios.RADIO_MESH:
				rfmode = "adhoc";
				ssid = `${mode.ssid}-v3-${mode.bandwidth}`;
			// Fall throught ...
			case radios.RADIO_MESHSTA:
				rfmode = rfmode || "sta";
			// Fall throught ...
			case radios.RADIO_MESHPTP:
			case radios.RADIO_MESHPTMP:
				rfmode = rfmode || "ap";
				ssid = ssid || `${mode.ssid}-v3-${mode.channel}-${mode.bandwidth}`;
				print(`node_aredn_meshrf{channel="${mode.channel}",chanbw="${mode.bandwidth}",device="${config[i].iface}",frequency="${hardware.getChannelFrequency(config[i].iface, mode.channel)}",ssid="${ssid}"} 1\n`);
				return;
			default:
				break;
		}
	}
	print('node_details_meshrf 0\n');
})();

print('# HELP node_uname_info Minimal Labeled system information as provided by the uname system call.\n');
print('# TYPE node_uname_info gauge\n');
print(`node_uname_info{nodename="${configuration.getName() || ''}"} 1\n`);
