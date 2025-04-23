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

function extract_and_print_single_metric_from_string(line, match_pattern, name, type, description)
{
    const m = match(line, regexp(match_pattern));
    if (m) {
        if (description) {
            print(`# HELP ${name} ${description}\n`);
        }
        print(`# TYPE ${name} ${type}\n`);
        print(`${name} ${m[1]}\n`);
    }
}

const lavg = split(fs.readfile("/proc/loadavg"), " ");
print("# HELP node_load1 1m load average.\n");
print("# TYPE node_load1 gauge\n");
print(`node_load1 ${lavg[0]}\n`);
print("# HELP node_load5 5m load average.\n");
print("# TYPE node_load5 gauge\n");
print(`node_load5 ${lavg[1]}\n`);
print("# HELP node_load15 15m load average.\n");
print("# TYPE node_load15 gauge\n");
print(`node_load15 ${lavg[2]}\n`);

const f = fs.open("/proc/stat");
if (f) {
    for (let line = f.read("line"); length(line); line = f.read("line")) {
        // cpunr, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice
        const m = match(line, /^cpu(\d+) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+)/);
        if (m) {
            print("# HELP node_cpu Seconds the cpus spent in each mode.\n");
            print("# TYPE node_cpu counter\n");
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="guest"} ${guest / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="guest_nice"} ${guest_nice / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="idle"} ${idle / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="iowait"} ${iowait / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="irq"} ${irq / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="nice"} ${nice / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="softirq"} ${softirq / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="steal"} ${steal / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="system"} ${system / 100}\n`);
            print(`node_cpu_seconds_total{cpu="${cpunr}",mode="user"} ${user / 100}\n`);
        }
        extract_and_print_single_metric_from_string(line, "btime (%d+)", "node_boot_time_seconds", "counter", "Node boot time, in unixtime.");
        extract_and_print_single_metric_from_string(line, "ctxt (%d+)", "node_context_switches_total", "counter", "Total number of context switches.");
        extract_and_print_single_metric_from_string(line, "intr (%d+)", "node_intr_total", "counter", "Total number of interrupts serviced.");
        extract_and_print_single_metric_from_string(line, "processes (%d+)", "node_forks_total", "counter");
        extract_and_print_single_metric_from_string(line, "procs_running  (%d+)", "node_procs_running", "gauge");
        extract_and_print_single_metric_from_string(line, "procs_blocked (%d+)", "node_procs_blocked", "gauge");
    }
    f.close();
}
