#!/bin/bash
# Script: los_pollos_abren.sh
# Añade una línea al log con la fecha y hora del arranque

LOGFILE="/home/fring/los_pollos_abren.log"

echo "Los Pollos Hermanos abre sus puertas el día $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOGFILE"
