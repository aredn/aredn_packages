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

const f = fs.popen("/usr/sbin/babel-dump");
if (f) {
    let interfaces = 0;
    let neighbors = 0;
    let routes = 0;
    let xroutes = 0;
    for (let line = f.read("line"); length(line); line = f.read("line")) {
        if (match(line, /interface/)) {
            interfaces++;
        }
        else if (match(line, /neighbour/)) {
            neighbors++;
        }
        else if (match(line, /xroute/)) {
            xroutes++;
        }
        else if (match(line, /route/)) {
            routes++;
        }
    }
    f.close();
    print("# HELP node_babel_interface_total\n");
    print("# HELP node_babel_interface_total counter\n");
    print("# HELP node_babel_neighbor_total\n");
    print("# HELP node_babel_neighbor_total counter\n");
    print("# HELP node_babel_routes_total\n");
    print("# HELP node_babel_routes_total counter\n");
    print("# HELP node_babel_xroutes_total\n");
    print("# HELP node_babel_xroutes_total counter\n");
    print("node_babel_interface_total ", interfaces, "\n");
    print("node_babel_neighbor_total ", neighbors, "\n");
    print("node_babel_xroute_total ", xroutes, "\n");
    print("node_babel_route_total ", routes, "\n");
}
