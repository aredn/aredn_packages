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

const lqm = json(fs.readfile("/tmp/lqm.info"));

const props = [
    "distance",
    "tx_packets",
    "tx_retries",
    "tx_fail",
    "avg_tx_packets",
    "avg_tx_retries",
    "avg_tx_fail",
    "lat",
    "lon",
    "ping_quality",
    "ping_success_time",
    "lq",
    "quality",
    "snr",
    "rev_snr",
    "routable",
    "rx_bitrate",
    "tx_bitrate",
    "tx_quality",
    "user_blocks",
    "babel_route_count",
    "babel_metric",
    "rxcost",
    "txcost"
];

for (let i = 0; i < length(props); i++) {
    const key = props[i];
    print(`# HELP node_lqm_tracker_${key}\n`);
    print(`# TYPE node_lqm_tracker_${key}${match(key, /_total$'/) ? ' counter' : ' gauge'}\n`);
    for (let mac in lqm.trackers) {
        const tracker = lqm.trackers[mac];
    
        if (tracker.lastseen >= lqm.now) {
            const ip = tracker.ip || "";
            const hostname = tracker.hostname || ip;
            const ltype = tracker.type || "unknown";
            let val = tracker[key];
            if (val != null) {
                if (type(val) == "bool") {
                    val = val ? 1 : 0;
                }
                print(`node_lqm_tracker_${key}{type="${ltype}",hostname="${hostname}",ip="${ip}",mac="${mac}"} ${val}\n`);
            }
        }
    }
}
