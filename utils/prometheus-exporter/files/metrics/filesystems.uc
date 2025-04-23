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

const f = fs.popen("/bin/df -T");
if (f) {
	for (let line = f.read("line"); length(line); line = f.read("line")) {
		// filesytem type size used available used% mount
		const m = match(line, /^([^ \t]+)[ \t]+([^ \t]+)[ \t]+([^ \t]+)[ \t]+([^ \t]+)[ \t]+([^ \t]+)[ \t]+([^ \t]+)[ \t]+([^ \t]+)/);
		if (m) {
			const dev = m[1];
			const mp = m[7];
			const fstype = m[2];
			print('# HELP node_filesystem_avail_bytes Filesystem space available in bytes.\n');
			print('# TYPE node_filesystem_avail_bytes gauge\n');
			print(`node_filesystem_avail_bytes{device="${dev}",fstype="${fstype}",mountpoint="${mp}"} ${1024 * m[5]}\n`);
			print('# HELP node_filesystem_size_bytes Filesystem size in bytes.\n');
			print('# TYPE node_filesystem_size_bytes gauge\n');
			print(`node_filesystem_size_bytes{device="${dev}",fstype="${fstype}",mountpoint="${mp}"} ${1024 * m[3]}\n`);
		}
	}
	f.close();
}
