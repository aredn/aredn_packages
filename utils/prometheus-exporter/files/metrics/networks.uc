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

const path = "/sys/class/net/";
function read_val(p, d)
{
    const val = fs.readfile(`${path}${p}`);
    if (val !== null) {
        return trim(val);
    }
    return d;
}

const props = [
    [ "address_assign_type", "addr_assign_type" ],
    [ "carrier", "carrier" ],
    [ "carrier_changes_total", "carrier_changes" ],
    [ "carrier_down_changes_total", "carrier_down_count" ],
    [ "carrier_up_changes_total", "carrier_up_count" ],
    [ "device_id", "/dev_id" ],
    [ "dormant", "dormant" ],
    [ "flags", "/flags" ],
    [ "iface_id", "ifindex" ],
    [ "iface_link", "iflink" ],
    [ "iface_link_mode", "link_mode" ],
    [ "info", function(dev) {
        const address = read_val(`${dev}/address`, "");
        const broadcast = read_val(`${dev}/broadcast`, "");
        const duplex = read_val(`${dev}/duplex`, "");
        const ifalias = read_val(`${dev}/ifalias`, "");
        const operstate = read_val(`${dev}/operstate`);
        return `node_network_info{address="${address}",broadcast="${broadcast}",device="${dev}",duplex="${duplex}",ifalias="${ifalias}",operstate="${operstate}"} 1`;
    } ],
    [ "mtu_bytes", "mtu" ],
    [ "name_assign_type", "name_assign_type" ],
    [ "netdev_group", "netdev_group" ],
    [ "protocol_type", "type" ],
    [ "receive_bytes_total", "statistics/rx_bytes" ],
    [ "receive_compressed_total", "statistics/rx_compressed" ],
    [ "receive_drop_total", "statistics/rx_dropped" ],
    [ "receive_errors_total", "statistics/rx_errors" ],
    [ "receive_fifo_errors_total", "statistics/rx_fifo_errors" ],
    [ "receive_frame_errors_total", "statistics/rx_frame_errors" ],
    [ "receive_multicast_total", "statistics/multicast" ],
    [ "receive_packets_total", "statistics/rx_packets" ],
    [ "speed_bytes", "speed" ],
    [ "transmit_bytes_total", "statistics/tx_bytes" ],
    [ "transmit_carrier_errors_total", "statistics/tx_carrier_errors" ],
    [ "transmit_collision_errors_total", "statistics/collisions" ],
    [ "transmit_compressed_total", "statistics/tx_compressed" ],
    [ "transmit_drop_total", "statistics/tx_dropped" ],
    [ "transmit_errors_total", "statistics/tx_errors" ],
    [ "transmit_fifo_errors_total", "statistics/tx_fifo_errors" ],
    [ "transmit_packets_total", "statistics/tx_packets" ],
    [ "up", function(dev) {
        return `node_network_up{device="${dev}"} ${read_val(dev + "/operstate") == "up" ? 1 : 0}`;
    } ]
];

for (let p = 0; p < length(props); p++) {
    const keys = props[p];
    print(`# HELP node_network_${keys[0]}\n`);
    print(`# TYPE node_network_${keys[0]}${match(keys[0], /_total$/) ? ' counter' : ' gauge'}\n`);
    const d = fs.opendir(path);
    if (d) {
        for (let dev = d.read(); dev; dev = d.read()) {
            if (type(keys[1]) == "string") {
                const val = read_val(`${dev}/${keys[1]}`);
                if (type(val) == "int" || type(val) == "double") {
                    print(`node_network_${keys[0]}{device="${dev}"} ${val}\n`);
                }
            }
            else {
                const str = keys[1](dev);
                if (str) {
                    print(str, "\n");
                }
            }
        }
    }
}
