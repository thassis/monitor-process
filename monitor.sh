#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usar: ./monitor [PID]"
else
    if [ $1 == "-h" ]; then
        echo "Dado um PID por parâmetro, ele será monitorado e um arquivo de log é criado, sendo preenchido com a data dos eventos críticos (quando um processo não está sendo executado ou quando o uso da CPU ultrapassa os 50%) e contém um registro do maior uso da CPU durante o processo."
        echo "Usage: ./monitor [PID]"
    else
        while [ true ]; do
            log="$1.txt"
                
            if [ ! -f $log ]; then
                $(touch "$log")
                $(printf "PID = $1\nMaior uso CPU = 0.0" > $log)
            fi

            pid_info=$(ps aux | awk '$2 == "'$1'"')
            if [ -z "$pid_info" ]; then
                dateEnd=$(date)
                $(printf "\n$dateEnd: PID não encontrado" >> $log)
                exit 1
            else
                cpu_usage=$(ps aux | awk '$2 == "'$1'"' | awk '{print $3}')
                
                if (( $(echo "$cpu_usage > 50" | bc -l) )); then
                    dateHigher=$(date)
                    $(printf "\n$dateHigher: PID usou mais que 50%% da CPU" >> $log)
                fi
                higherCpuUsage=$(cat $log | grep "Maior uso" | awk '{print $5}')
                if (( $(echo "$cpu_usage > $higherCpuUsage" | bc -l) )); then
                    $(sed -i 's/= '$higherCpuUsage'/= '$cpu_usage'/' $log)
                fi
                sleep 5
            fi

        done
    fi
fi