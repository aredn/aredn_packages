/*
 * Part of AREDN® -- Used for creating Amateur Radio Emergency Data Networks
 * Copyright (C) 2022-2026 Tim Wilkinson
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
import * as socket from "socket";
import * as babel from "aredn.babel";

const GPSD = "/usr/sbin/gpsd";
const GPS_TTYS = [
    "/dev/ttyACM0",
    "/dev/ttyUSB0"
];

export function GPSFind()
{
    if (fs.access(GPSD)) {
        for (let i = 0; i < length(GPS_TTYS); i++) {
            const tty = GPS_TTYS[i];
            if (fs.access(tty)) {
                return tty;
            }
        }
    }
    const neighbors = babel.getRoutableNeighbors();
    for (let i = 0; i < length(neighbors); i++) {
        const n = neighbors[i];
        if (n.interface === "br-dtdlink") {
            const ip = `${n.ipv6address}%${n.interface}`;
            const s = socket.connect(ip, 2947, null, 500);
            if (s) {
                if (s.send("\n") === 1) {
                    s.close();
                    return ip;
                }
                s.close();
            }
        }
    }
    return null;
};

export function GPSReadLLT(gps, maxlines)
{
    const info = {
        lat: null,
        lon: null,
        time: null
    };
    if (match(gps, /^\/dev\//)) {
        gps = "127.0.0.1";
    }
    const s = socket.connect(gps, 2947, null, 500);
    if (!s) {
        return null;
    }
    s.send('?WATCH={"enable":true,"json":true}\n');
    if (!maxlines) {
        maxlines = 10;
    }
    for (; maxlines > 0; maxlines--) {
        let str = "";
        let j = null;
        for (;;) {
            const c = s.recv(1);
            if (!c || !length(c)) {
                maxlines = 0;
                break;
            }
            if (c == "\n") {
                j = json(str);
                break;
            }
            str += c;
        }
        if (j && j.class == "TPV") {
            info.time = replace(replace(j.time, "T", " "), ".000Z", "");
            if (j.lat && j.lon) {
                info.lat = 1 * sprintf("%.5f", j.lat);
                info.lon = 1 * sprintf("%.5f", j.lon);
            }
            break;
        }
    }
    s.close();
    return info;
};
