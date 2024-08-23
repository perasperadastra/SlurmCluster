#!/usr/bin/bash
##########################################################################################################
##
## created by:
##               Raúl De Armas Rodríguez   
##
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
table_header="NodeName|CPU[use/tot/%]| |Mem[tot/free/%]|GPu[use/tot/%]\n"
table="${table_header}"
for i in $TXT
do
        # start node reading and clean vars
        if [[ $i = NodeName* ]];then
                nodeName=$(echo $i | awk -F " " '{print $1}' | awk -F "=" '{print$2}')
                CPUAlloc=""
                CPUTot=""
                CPUperc=""
                REALmem=""
                ALLocmem=""
                percmem=""
                REALmem=""
                MEMlim=""
                GPUoccu=""
                GPUperc=""
                GPUTot=""
        fi
        if [[ "$i" == *CPUAlloc* ]]; then
                CPUAlloc=$(echo $i | awk -F " " '{print $1}' | awk -F "=" '{print$2}')
                CPUTot=$(echo $i | awk -F " " '{print $2}' | awk -F "=" '{print$2i}')
                CPUperc=$(printf %.2f%% "$((10**3 * 100 * $CPUAlloc/$CPUTot))e-3")

        fi
        # memory stuff
        if [[ "$i" == *RealMemory* ]]; then
                REALmem=$(echo $i | awk -F " " '{print $1}' | awk -F "=" '{print$2}')
                FreeMem=$(echo $i | awk -F " " '{print $3}' | awk -F "=" '{print$2i}')
                # converting to Gb 
                percmem=$(printf %.2f%% "$((10**3 * 100 * $FreeMem/$REALmem))e-3")
                # Converting to GB
                let FreeMem=$(($ALLocmem))/1024
                let REALmem=$(($REALmem))/1024
        fi
        # Gpu tot
        if [[ "$i" == *CfgTRES* && "$i" == *gpu* ]]; then
                        GPUTot=$(echo $i | awk -F "," '{print $4}' | awk -F "=" '{print$2i}')
        fi
        # gpu ocupation
        if [[ "$i" == *AllocTRES* ]]; then
                GPUoccu=$(echo $i | awk -F "," '{print $2}' | awk -F "=" '{print$2i}')
                GPUperc=$(printf %.2f%% "$((10**3 * 100 * $GPUoccu/$GPUTot))e-3")
                table+="$nodeName|    $CPUAlloc/$CPUTot/$CPUperc| |  $REALmem/$FreeMem/$percmem Gb| $GPUoccu/$GPUTot/$GPUperc %\n"
        fi
done
echo -e ${table} | column -t -s "|"
