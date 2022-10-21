#!/usr/bin/bash
#########################################################################################################
#
#       Created by:
#               Raúl De Armas Rodríguez   
#
#########################################################################################################
#       This scripts is build for slurm 21.08.1.
#
#       Purpose: Obtain information about CPU and memory use and availability in an easy display format.
#       Requirements:
#               -Slurm 21.08.1
#       Input:
#               None ( use the command "scontrol show node" and parse the information on the out)
#       Output example:
#             NodeName  CPU[use/tot/%]     Mem[use/tot/%]    MemLimit
#             nodo01        0/64/0,00%       0/185/0,00% Gb   4 Gb
#             nodo02        0/32/0,00%       0/250/0,00% Gb   4 Gb
#             nodo03        0/32/0,00%       0/250/0,00% Gb   4 Gb
#             nodo04        0/32/0,00%       0/250/0,00% Gb   4 Gb
#             nodo05        0/40/0,00%       0/92/0,00% Gb    4 Gb
#             nodo06        0/32/0,00%       0/250/0,00% Gb   4 Gb
#
#########################################################################################################
TXT=$(scontrol show node)

# separating by \n
oIFS=$IFS
IFS=$'\n'
table_header="NodeName|CPU[use/tot/%]| |Mem[use/tot/%]|MemLimit\n"
table="${table_header}"
for i in $TXT
do
        if [[ $i = NodeName* ]];then
                nodeName=$(echo $i | awk -F " " '{print $1}' | awk -F "=" '{print$2}')
        fi
        if [[ "$i" == *CPUAlloc* ]]; then
                CPUAlloc=$(echo $i | awk -F " " '{print $1}' | awk -F "=" '{print$2}')
                CPUTot=$(echo $i | awk -F " " '{print $2}' | awk -F "=" '{print$2i}')
                CPUperc=$(printf %.2f%% "$((10**3 * 100 * $CPUAlloc/$CPUTot))e-3")

        fi

        if [[ "$i" == *RealMemory* ]]; then
                REALmem=$(echo $i | awk -F " " '{print $1}' | awk -F "=" '{print$2}')
                ALLocmem=$(echo $i | awk -F " " '{print $2}' | awk -F "=" '{print$2i}')
                # converting to Gb 
                percmem=$(printf %.2f%% "$((10**3 * 100 * $ALLocmem/$REALmem))e-3")
                # Converting to GB
                let ALLocmem=$(($ALLocmem))/1024
                let REALmem=$(($REALmem))/1024
        fi

        if [[ "$i" == *MemSpecLimit* ]]; then
                MEMlim=$(echo $i | awk -F " " '{print $1}' | awk -F "=" '{print$2}')
                let MEMlim=$(($MEMlim))/1024
                table+="$nodeName|    $CPUAlloc/$CPUTot/$CPUperc| |  $ALLocmem/$REALmem/$percmem Gb| $MEMlim Gb\n"
        fi
done
echo -e ${table} | column -t -s "|"
IFS=$oIFS
