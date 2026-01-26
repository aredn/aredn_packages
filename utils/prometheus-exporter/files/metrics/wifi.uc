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

import * as nl80211 from "nl80211";
import * as hardware from "aredn.hardware";

if (hardware.getRadioCount() == 0) {
    return;
}
 
const wlans = [ "wlan0", "wlan1" ];

print(`# HELP node_wifi_station_receive_mcs\n`);
print(`# TYPE node_wifi_station_receive_mcs gauge\n`);
print(`# HELP node_wifi_station_receive_packets_total\n`);
print(`# TYPE node_wifi_station_receive_packets_total counter\n`);
print(`# HELP node_wifi_station_receive_rate_bits_per_second\n`);
print(`# TYPE node_wifi_station_receive_rate_bits_per_second gauge\n`);
print(`# HELP node_wifi_station_signal\n`);
print(`# TYPE node_wifi_station_signal gauge\n`);
print(`# HELP node_wifi_station_transmit_mcs\n`);
print(`# TYPE node_wifi_station_transmit_mcs gauge\n`);
print(`# HELP node_wifi_station_transmit_packets_total\n`);
print(`# TYPE node_wifi_station_transmit_packets_total counter\n`);
print(`# HELP node_wifi_station_transmit_rate_bits_per_second\n`);
print(`# TYPE node_wifi_station_transmit_rate_bits_per_second gauge\n`);
for (let w = 0; w < length(wlans); w++) {
    const stations = nl80211.request(nl80211.const.NL80211_CMD_GET_STATION, nl80211.const.NLM_F_DUMP, { dev: wlans[w] });
    for (let s = 0; s < length(stations); s++) {
        const station = stations[s];
        print(`node_wifi_station_receive_mcs{device="${wlans[w]}",mac="${station.mac}"} ${station.sta_info.rx_bitrate.mcs}\n`);
        print(`node_wifi_station_receive_packets_total{device="${wlans[w]}",mac="${station.mac}"} ${station.sta_info.rx_packets}\n`);
        print(`node_wifi_station_receive_rate_bits_per_second{device="${wlans[w]}",mac="${station.mac}"} ${station.sta_info.rx_bitrate.bitrate32 * 100000}\n`);
        print(`node_wifi_station_signal{device="${wlans[w]}",mac="${station.mac}"} ${station.sta_info.signal}\n`);
        print(`node_wifi_station_transmit_mcs{device="${wlans[w]}",mac="${station.mac}"} ${station.sta_info.tx_bitrate.mcs}\n`);
        print(`node_wifi_station_transmit_packets_total{device="${wlans[w]}",mac="${station.mac}"} ${station.sta_info.tx_packets}\n`);
        print(`node_wifi_station_transmit_rate_bits_per_second{device="${wlans[w]}",mac="${station.mac}"} ${station.sta_info.tx_bitrate.bitrate32 * 100000}\n`);
    }
}
