#!/system/bin/sh
# harness.sh - Control total del celular via Shizuku
# Uso: harness.sh <comando> [args]
# Ejecutar desde /data/local/tmp/androidharness-scratch

SCRATCH=/data/local/tmp/androidharness-scratch
INPUT=/system/bin/input
PM=/system/bin/pm
AM=/system/bin/am

run_input() { cd "$SCRATCH" && "$INPUT" "$@"; }

cmd="${1:-help}"

case "$cmd" in

# --- NAVEGACIÓN ---
home)       run_input keyevent 224 ;;
back)       run_input keyevent 4 ;;
menu)       run_input keyevent 82 ;;
power)      run_input keyevent 26 ;;
lock)       run_input keyevent 223 ;;
unlock)     run_input keyevent 224 ;;
sleep)      run_input keyevent 223 ;;
wake)       run_input keyevent 224 ;;
recent)    run_input keyevent 187 ;;
assistant) run_input keyevent 222 ;;

# --- INPUT ---
click)      run_input tap "${2:-500}" "${3:-500}" ;;
double)     run_input tap "${2:-500}" "${3:-500}"; sleep 0.1; run_input tap "${2:-500}" "${3:-500}" ;;
longpress)  run_input longpress "${2:-500}" "${3:-500}" "${4:-1000}" ;;
swipe)      run_input swipe "${2:-0}" "${3:-0}" "${4:-1080}" "${5:-1920}" "${6:-300}" ;;
drag)       run_input drag "${2:-100}" "${3:-100}" "${4:-500}" "${5:-500}" "${6:-300}" ;;
pinch)      run_input pinch "${2:-200}" "${3:-200}" "${4:-800}" "${5:-800}" "${6:-300}" ;;
type)       run_input text "${2}" ;;
key)        run_input keyevent "${2}" ;;
clear)      run_input keyevent 28 ; run_input keyevent 28 ;;

# --- PANTALLA ---
screencap)  /system/bin/screencap -p "${2:-/sdcard/harness.png}"; echo "Screenshot: ${2:-/sdcard/harness.png}" ;;
brightness) /system/bin/settings get system screen_brightness "${2:-}" ;;
setbright)  /system/bin/settings put system screen_brightness "${2:-204}" ;;
rotate)     /system/bin/settings put system acceleration_sensor_rotation "${2:-0}" ;;
dimoff)     /system/bin/settings put system screen_off_timeout 1 ;;
dimon)      /system/bin/settings put system screen_off_timeout 300000 ;;

# --- APPS ---
open)       "$AM" start -n "${2}/.MainActivity" 2>/dev/null || "$AM" start -a android.intent.action.MAIN -n "${2}" 2>/dev/null || "$AM" start -a android.intent.action.VIEW -d "${2}" 2>/dev/null || echo "No se pudo abrir $2" ;;
openurl)    "$AM" start -a android.intent.action.VIEW -d "${2}" ;;
forcestop)  "$AM" force-stop "${2}" ;;
clear)      "$PM" clear "${2}" ;;
uninstall)  "$PM" uninstall "${2}" ;;
disable)    "$PM" disable "${2}" ;;
enable)     "$PM" enable "${2}" ;;
hide)       "$PM" hide-package "${2}" 2>/dev/null || "$PM" disable-user "${2}" 2>/dev/null || echo "No se pudo ocultar" ;;
show)       "$PM" unhide-package "${2}" 2>/dev/null || "$PM" enable-user "${2}" 2>/dev/null || echo "No se pudo mostrar" ;;
list)       "$PM" list packages 2>/dev/null | sed 's/package://' | sort ;;
list3)      "$PM" list packages 2>/dev/null | sed 's/package://' | sort | grep -v -E "^android\.|^com\.android\.|^com\.google\." ;;
running)    "$PM" list -3 2>/dev/null | sed 's/package://' | sort ;;
info)       "$PM" list packages -f "${2}" 2>/dev/null ;;

# --- SISTEMA ---
volumeup)   run_input keyevent 24 ;;
volumedown) run_input keyevent 25 ;;
volumemute) run_input keyevent 164 ;;
wifi)       /system/bin/settings put wifi_wifi_on 1 ;;
nowifi)     /system/bin/settings put wifi_wifi_on 0 ;;
bt)         /system/bin/settings put bluetooth_bluez_on 1 ;;
nobt)       /system/bin/settings put bluetooth_bluez_on 0 ;;
flash)      /system/bin/settings put system flashlight 1 ;;
noflash)    /system/bin/settings put system flashlight 0 ;;
reboot)     /system/bin/reboot ;;
shutdown)   /system/bin/reboot -p ;;
sudc)       run_input keyevent 26; sleep 1; run_input keyevent 224; sleep 0.5; run_input keyevent 224 ;;

# --- UTILIDADES ---
wait)       sleep "${2:-1}" ;;
notify)     "$AM" broadcast -a com.android.harness.NOTIFY -e msg "${2}" -e title "${3:-H}" ;;
echo)       echo "$2" ;;
esac
