from pathlib import Path
import json
import os
import shutil
import subprocess

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--hook", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
root = args.output.resolve()
root.mkdir(parents=True, exist_ok=True)
source = args.hook.read_text()

def event(action='add', product='1546/1a7/100', device='1-1', kind='usb_device'):
    return dict(ACTION=action, PRODUCT=product, DEVTYPE=kind,
                DEVPATH='/devices/platform/usb1/' + device)

add = event()
remove = event('remove')
add2 = event(device='1-2')
remove2 = event('remove', device='1-2')
tests = [
    ('no-device', [], 0, False),
    ('vk162', [add], 1, False),
    ('vk172', [event(product='1546/1a7/200')], 1, False),
    ('duplicate-add', [add, add], 1, False),
    ('unplug', [add, remove], 0, False),
    ('duplicate-remove', [add, remove, remove], 0, False),
    ('unrelated-remove', [add, event('remove', '067b/2303/300')], 1, False),
    ('unknown-device-remove', [add, remove2], 1, False),
    ('two-gps-remove-first', [add, add2, remove], 1, False),
    ('two-gps-remove-second', [add, add2, remove2], 1, False),
    ('two-gps-unplug-both', [add, add2, remove, remove2], 0, False),
    ('two-gps-connected', [add, add2], 2, False),
    ('interface-add', [event(kind='usb_interface', device='1-1:1.0')], 0, False),
    ('interface-remove', [add, event('remove', kind='usb_interface', device='1-1:1.0')], 1, False),
    ('pl2303', [event(product='067b/2303/300')], 0, False),
    ('pl2303gc', [event(product='067b/23a3/100')], 0, False),
    ('ftdi', [event(product='403/6001/100')], 0, False),
    ('cp210x', [event(product='10c4/ea60/100')], 0, False),
    ('ch340', [event(product='1a86/7523/100')], 0, False),
    ('other-ublox', [event(product='1546/ffff/100')], 0, False),
    ('unqualified-ublox6', [event(product='1546/1a6/100')], 0, False),
    ('unqualified-ublox8', [event(product='1546/1a8/100')], 0, False),
    ('unknown-action', [event('change')], 0, False),
    ('installed-support', [add], 1, True),
    ('installed-two-gps', [add, add2], 2, True),
    ('boot-add-installed', ['reboot', add], 1, True),
    ('reboot-replug', [add, 'reboot', add], 1, False),
    ('missing-event-identity', [dict(ACTION='add')], 0, False),
]
results = []
for revision in ('original', 'candidate'):
    for name, events, count, installed in tests:
        case = root / 'fixtures' / revision / name
        if case.exists():
            shutil.rmtree(case)
        marker = case / 'tmp/gps-detected'
        gpsd = case / 'usr/sbin/gpsd'
        case.mkdir(parents=True)
        if installed:
            gpsd.parent.mkdir(parents=True)
            gpsd.touch()
        script = case / 'hotplug.sh'
        script.write_text(source.replace('/tmp/gps-detected', str(marker)))
        for entry in events:
            if entry == 'reboot':
                shutil.rmtree(case / 'tmp', ignore_errors=True)
                continue
            env = {k: v for k, v in os.environ.items()
                   if k not in ('ACTION', 'PRODUCT', 'DEVTYPE', 'DEVPATH')}
            env.update(entry)
            command = ['busybox', 'ash', str(script)] if revision == 'candidate' else ['busybox', 'ash', '-c', ':']
            result = subprocess.run(command, env=env, capture_output=True, text=True)
            assert result.returncode == 0, (revision, name, result.stderr)
            assert not result.stdout and not result.stderr, (revision, name, result.stdout, result.stderr)
        expected_count = count if revision == 'candidate' else 0
        actual_count = len(list(marker.iterdir())) if marker.exists() else 0
        assert actual_count == expected_count, (revision, name, actual_count, expected_count)
        assert marker.exists() == bool(expected_count), (revision, name, 'empty parent marker')
        results.append(dict(revision=revision, name=name, root=str(case), detected=bool(expected_count),
                            device_count=actual_count, gpsd_fixture_present=installed))
(root / 'shell-results.json').write_text(json.dumps(results, indent=2) + '\n')
print(f'{len(tests)} lifecycle/device scenarios passed on baseline and candidate ({len(results)} results)')
