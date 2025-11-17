#!/bin/bash

trap exit SIGINT

# Verificar que se proporcionó un parámetro
if [ $# -ne 1 ]; then
    echo "Uso: $0 <IP>"
    echo "Ejemplo: $0 192.168.1.50"
    exit 1
fi

IP="$1"

# Validar formato de IP
if ! echo "$IP" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Error: Formato de IP inválido"
    exit 1
fi

# Extraer los primeros tres octetos de la IP
NETWORK=$(echo "$IP" | cut -d. -f1-3)

echo "Escaneando la red: $NETWORK.0/24"
echo "Hosts activos:"
echo "---------------"

# Contador de hosts activos
COUNT=0

# Escanear todas las IPs de la red (1-254)
for i in {1..254}; do
    TARGET="$NETWORK.$i"
    
    # Usar ping para verificar si el host está activo
    if ping -c 1 -W 1 "$TARGET" &> /dev/null; then
        echo "✅ $TARGET - ACTIVO" >> /tmp/temporalscan.txt
        COUNT=$((COUNT + 1))
    fi
    
    # Mostrar progreso cada IPs
    if [ $((i % 1)) -eq 0 ]; then
        echo -ne "\rProgreso: $i/254 IPs escaneadas..."
    fi
done

echo "---------------"
echo "Escaneo completado. Total de hosts activos: $COUNT"
cat /tmp/temporalscan.txt
rm -rf /tmp/temporalscan.txt
