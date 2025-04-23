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

const f = fs.popen("/usr/local/bin/arednlink-dump");
if (f) {
    for (let line = f.read("line"); length(line); line = f.read("line")) {
		const m = match(trim(line), /^statistics ([^ \t]+) (.+)$/);
        if (m) {
			const kind = m[1];
			const pair = split(m[2], " ");
			for (let i = 0; i < length(pairs); i += 2) {
				const k = pairs[i];
				const v = pairs[i + 1];
                print(`# HELP node_arednlink_${k}_${kind}_total\n`);
                print(`# TYPE node_arednlink_${k}_${kind}_total counter\n`);
                print(`node_arednlink_${k}_${kind}_total ${v}\n`);
			}
		}
	}
    f.close();
}
