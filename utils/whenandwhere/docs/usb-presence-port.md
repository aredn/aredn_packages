# Package-owned USB GPS presence

Ports the 11-line hotplug handler from [AREDN #3022](https://github.com/aredn/aredn/pull/3022)
into the maintained `whenandwhere` package. The handler is unchanged from
`4b707ae49e9bfcaf71561b24f415cd645b9cbc2b`.

- Only USB-device events with ID `1546:01a7` (qualified VK-162/VK-172) match.
  Generic serial-bridge IDs do not establish GPS identity and are excluded.
- `/tmp/gps-detected/<device>` records each connected receiver. Removing one
  receiver preserves another; the parent disappears after the last removal.
- The package owns USB support. Nothing is added to the base firmware image,
  source-selection policy, clock/location synchronization or GUI.
- This is a RAM-backed presence interface only. No GUI consumer is added, and
  presence is not satellite lock or evidence of the source that last set time.
  There is no scan, daemon, new timer, driver load or package query in the hook.

## Installation boundaries

The original base-firmware PR is closed: stock firmware without USB core and
controller support cannot enumerate a receiver before support is installed.
Moving this hook does not change that prerequisite.

The original message, "GPS detected. Install whenandwhere", is intentionally
omitted. This package already depends on GPSD, so installing the package cannot
usefully display a prompt to install itself. The time-area GPS/NTP display is a
separate firmware change, not part of this package port.

Installing a hook after a device has already enumerated does not replay an old
event. A replug or the next normal coldplug/add event is required; this patch
does not add a startup scan. State is volatile and is reconstructed only from
qualifying events while the hook is installed.

## Isolated validation

From the repository root, with Python 3 and BusyBox providing `ash`:

```sh
python3 utils/whenandwhere/tests/usb-presence.py \
  --hook utils/whenandwhere/files/10-gps-detect \
  --output /tmp/whenandwhere-presence-check
```

The exact hook is executed with only its marker root redirected. The no-hook
baseline and candidate run 28 lifecycle/device scenarios, including duplicates,
multiple receivers, last unplug, interface events, excluded IDs and simulated
boot/replug. A synthetic GPSD file is not a package-manager installation test.

The package's actual Makefile install recipe was separately exercised with an
isolated staging root and no-op SDK includes; the executable hook and existing
`/tmp/whenandwhere` marker were verified. This is not a full OpenWrt/APK build.
No physical receiver, real cold boot or package-manager qualification is claimed.
