#!/usr/bin/bash
#####################################################################
#
#       Created by:
#               Raúl De Armas Rodríguez   
#
####################################################################
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
