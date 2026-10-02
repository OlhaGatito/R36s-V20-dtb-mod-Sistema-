#!/bin/sh
# R36S / ROCKNIX input + ADC diagnostic collector
# READ-ONLY: does not modify DTS, GPIO, input, audio, or system configuration.

set +e
OUT_BASE="/storage/roms"
[ -d "$OUT_BASE" ] || OUT_BASE="/tmp"
TS="$(date '+%Y%m%d-%H%M%S' 2>/dev/null)"
OUT="$OUT_BASE/r36s-input-diagnostics-$TS.log"
exec >"$OUT" 2>&1

section() {
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

section "SYSTEM"
date 2>/dev/null
uname -a
cat /etc/os-release 2>/dev/null
echo "Command line:"
cat /proc/cmdline 2>/dev/null

section "DEVICE TREE / MODEL"
echo "Model:"
cat /proc/device-tree/model 2>/dev/null
echo
echo "Compatible:"
tr '\000' '\n' </proc/device-tree/compatible 2>/dev/null
echo
echo "Boot files:"
ls -la /boot 2>/dev/null
ls -la /boot/dtb 2>/dev/null

section "INPUT DEVICES"
cat /proc/bus/input/devices 2>/dev/null

echo
echo "--- /sys/class/input ---"
for d in /sys/class/input/event*; do
    [ -e "$d" ] || continue
    ev="$(basename "$d")"
    echo
    echo "[$ev]"
    echo "name: $(cat "$d/device/name" 2>/dev/null)"
    echo "phys: $(cat "$d/device/phys" 2>/dev/null)"
    echo "uniq: $(cat "$d/device/uniq" 2>/dev/null)"
    echo "modalias: $(cat "$d/device/modalias" 2>/dev/null)"
    echo "capabilities/key:"
    cat "$d/device/capabilities/key" 2>/dev/null
    echo "capabilities/abs:"
    cat "$d/device/capabilities/abs" 2>/dev/null
    echo "capabilities/rel:"
    cat "$d/device/capabilities/rel" 2>/dev/null
done

section "INPUT EVENT NODES"
for d in /dev/input/event*; do
    [ -e "$d" ] || continue
    echo "$(ls -l "$d" 2>/dev/null)  $(cat "/sys/class/input/$(basename "$d")/device/name" 2>/dev/null)"
done

section "RETROGAME JOYPAD SYSFS"
for d in /sys/class/input/event*; do
    [ -e "$d" ] || continue
    name="$(cat "$d/device/name" 2>/dev/null)"
    case "$name" in
        *retrogame*|*joypad*|*Joypad*)
            echo "Found: $d ($name)"
            find "$d/device" -maxdepth 2 -type f -readable 2>/dev/null | sort |
            while read -r f; do
                case "$f" in
                    */uevent|*/name|*/phys|*/uniq|*/modalias|*/capabilities/*)
                        echo "--- $f ---"
                        cat "$f" 2>/dev/null
                        ;;
                esac
            done
            ;;
    esac
done

section "IIO / ADC"
if [ -d /sys/bus/iio/devices ]; then
    for d in /sys/bus/iio/devices/iio:device*; do
        [ -d "$d" ] || continue
        echo
        echo "DEVICE: $d"
        echo "name: $(cat "$d/name" 2>/dev/null)"
        echo "dev: $(cat "$d/dev" 2>/dev/null)"
        echo "modalias: $(cat "$d/modalias" 2>/dev/null)"
        echo "files:"
        ls -1 "$d" 2>/dev/null
        for f in "$d"/in_*_raw "$d"/in_*_input "$d"/in_*_scale "$d"/in_*_offset "$d"/in_*_label "$d"/in_*_index; do
            [ -e "$f" ] || continue
            echo "--- $f ---"
            cat "$f" 2>/dev/null
        done
    done
else
    echo "/sys/bus/iio/devices unavailable"
fi

section "GPIO CHIPS"
for d in /sys/class/gpio/gpiochip*; do
    [ -e "$d" ] || continue
    echo
    echo "$(basename "$d")"
    echo "base: $(cat "$d/base" 2>/dev/null)"
    echo "ngpio: $(cat "$d/ngpio" 2>/dev/null)"
    echo "label: $(cat "$d/label" 2>/dev/null)"
    echo "device: $(readlink -f "$d/device" 2>/dev/null)"
done

section "GPIO DEBUGFS"
cat /sys/kernel/debug/gpio 2>/dev/null || echo "unavailable"

section "KERNEL MODULES"
cat /proc/modules 2>/dev/null |
grep -Ei 'joy|input|adc|iio|gpio|pwm|sound|snd|rockchip|rk817' || true

section "DMESG - INPUT / ADC / JOYPAD"
dmesg 2>/dev/null |
grep -Ei 'joypad|joystick|retrogame|singleadc|adc|iio|gpio|input' || true

section "DMESG - AUDIO"
dmesg 2>/dev/null |
grep -Ei 'snd|sound|audio|rk817|codec|i2s|simple-audio|multicodecs|spk|speaker|headphone|jack' || true

section "SOUND DEVICES"
ls -la /dev/snd 2>/dev/null
cat /proc/asound/cards 2>/dev/null
cat /proc/asound/devices 2>/dev/null
cat /proc/asound/pcm 2>/dev/null

section "LIVE DEVICE TREE - RELEVANT NODES"
find /proc/device-tree -type d 2>/dev/null |
grep -Ei 'singleadc|joypad|joystick|play_joystick|rocker|sound|audio|rk817|i2s|adc' |
head -300

section "PLAY_JOYSTICK PROPERTIES"
find /proc/device-tree -type d -name 'play_joystick*' -print 2>/dev/null |
while read -r d; do
    echo "NODE: $d"
    for f in "$d"/*; do
        [ -f "$f" ] || continue
        echo "PROPERTY: $f"
        if strings "$f" 2>/dev/null | grep -q .; then
            strings "$f" 2>/dev/null
        else
            od -An -tx4 "$f" 2>/dev/null
        fi
    done
done

section "DEVICE TREE JOYPAD PROPERTIES"
find /proc/device-tree -type d 2>/dev/null |
grep -Ei 'singleadc|joypad|joystick' |
while read -r d; do
    echo "NODE: $d"
    ls -la "$d" 2>/dev/null
done

section "USB / HID"
lsusb 2>/dev/null || true

section "CPU / MEMORY"
head -80 /proc/cpuinfo 2>/dev/null
free -h 2>/dev/null
head -30 /proc/meminfo 2>/dev/null

section "END"
echo "Report saved to: $OUT"
echo "READ-ONLY diagnostic. No DTS/GPIO/input/audio configuration was changed."
exit 0
