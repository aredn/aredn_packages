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

if (!fs.access("/tmp/wireless_monitor.info")) {
    return;
}
const info = json(fs.readfile("/tmp/wireless_monitor.info"));

print('# HELP node_wifimon_action\n');
print('# TYPE node_wifimon_action gauge\n');
for (let k in info.action_state) {
    print(`node_wifimon_action{action="${k}"} ${info.action_state[k] ? 1 : 0}\n`);
}

print('# HELP node_wifimon_stations\n');
print('# TYPE node_wifimon_stations gauge\n');
print('node_wifimon_stations ', length(info.unresponsive.stations), '\n');

print('# HELP node_wifimon_unresponsive_station\n');
print('# TYPE node_wifimon_unresponsive_station gauge\n');
let c = 0;
for (let ip in info.unresponsive.stations) {
    const v = info.unresponsive.stations[ip];
    if (v >= 1) {
        c++;
    }
    print(`node_wifimon_unresponsive_station{remote_ip="${ip}"} ${v}\n`);
}
print('# HELP node_wifimon_unresponsive_stations\n');
print('# TYPE node_wifimon_unresponsive_stations gauge\n');
print(`node_wifimon_unresponsive_stations ${c}\n`);
