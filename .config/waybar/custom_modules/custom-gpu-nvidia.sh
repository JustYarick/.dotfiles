#!/bin/bash
stats=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits | sed 's/, / /g')
read -r temp util <<< "$stats"
echo "{\"text\": \" ${temp}°C ${util}%\", \"tooltip\": \"GPU Temp: ${temp}°C\nGPU Utilization: ${util}%\"}"
