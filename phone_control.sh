#!/system/bin/sh
# phone_control.sh - Controla el celular desde la terminal via Shizuku
# Uso: bash phone_control.sh <comando> [args]
# Comandos:
#   home, back, menu, power, lock, unlock, sleep, wake
#   click <x> <y>
#   swipe <x1> <y1> <x2> <y2> [duration_ms]
#   type <texto>
#   key <codigo>
#   screencap [outfile]
#   open <package>
#   broadcast <action>

SCRATCH=/data/local/tmp/androidharness-scratch
INPUT=/system/bin/input

run_input() {
    cd "$SCRATCH" && "$INPUT" "$@"
}

case "${1:-help}" in
    home)      run_input keyevent 224 ;;
    back)      run_input keyevent 4 ;;
    menu)      run_input keyevent 82 ;;
    power)     run_input keyevent 26 ;;
    lock)      run_input keyevent 223 ;;
    unlock)    run_input keyevent 224; run_input keyevent 224 ;;
    sleep)     run_input keyevent 223 ;;
    wake)      run_input keyevent 224 ;;
    
    click)
        run_input tap "${2:-500}" "${3:-500}"
        ;;
    swipe)
        run_input swipe "${2:-0}" "${3:-0}" "${4:-1080}" "${5:-1920}" "${6:-300}"
        ;;
    type)
        run_input text "${2}"
        ;;
    key)
        run_input keyevent "${2}"
        ;;
    screencap)
        run_input keyevent 223
        /system/bin/screencap -p "${2:-/sdcard/screenshot.png}"
        echo "Screenshot guardado: ${2:-/sdcard/screenshot.png}"
        ;;
    open)
        am start -n "${2}/.MainActivity" 2>/dev/null || am start -a android.intent.action.MAIN -n "${2}" 2>/dev/null || echo "No se pudo abrir $2"
        ;;
    broadcast)
        am broadcast -a "${2}" "${3:-}"
        ;;
    *)
        echo "Uso: bash phone_control.sh <comando> [args]"
        echo ""
        echo "Comandos:"
        echo "  home|back|menu|power|lock|unlock|sleep|wake"
        echo "  click <x> <y>"
        echo "  swipe <x1> <y1> <x2> <y4> [duration]"
        echo "  type <texto>"
        echo "  key <codigo>"
        echo "  screencap [outfile]"
        echo "  open <package>"
        echo "  broadcast <action>"
        ;;
esac
