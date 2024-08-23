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
#      Partition       NodeName  CPU[use/tot/%]     Mem[tot/free/%]    Gpu[use/tot/%]
#      dual-12         nodo01        0/64/0,00%       0/185/0,00% Gb   0/4/0%
#      dual-12         nodo02        0/32/0,00%       0/250/0,00% Gb   0/4/0%
#      dual-13         nodo03        0/32/0,00%       0/250/0,00% Gb   0/4/0%
#      gpu-node        nodo04        0/32/0,00%       0/250/0,00% Gb   0/4/0%
#      gpu-node        nodo05        0/40/0,00%       0/92/0,00% Gb    0/4/0%
#      dual-43         nodo06        0/32/0,00%       0/250/0,00% Gb   0/4/0%
#
#########################################################################################################
TXT=$(scontrol show node)

# separating by \n
oIFS=$IFS
IFS=$'\n'
table_header="Partition|NodeName|CPU[use/tot/%]| |Mem[free/tot/%]|GPu[use/tot/%]\n"
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
                if [[ "$CPUperc" == "" ]]; then
                        CPUperc="0"
                fi

        fi
        # memory stuff
        if [[ "$i" == *RealMemory* ]]; then
                REALmem=$(echo $i | awk -F " " '{print $1}' | awk -F "=" '{print$2}')
                FreeMem=$(echo $i | awk -F " " '{print $3}' | awk -F "=" '{print$2i}')
                # converting to Gb 
                #if 
                percmem=$(printf %.2f%% "$((10**3 * 100 * $FreeMem/$REALmem))e-3")
                # Converting to GB
                let FreeMem=$(($ALLocmem))/1024
                let REALmem=$(($REALmem))/1024
        fi
        if [[ "$i" == *Partitions* ]]; then
                PartitionName=$(echo $i | awk -F "=" '{print $2}')
        fi
        # Gpu tot
        if [[ "$i" == *CfgTRES* ]]; then
                if [[ "$i" == *gres/gpu* ]]; then
                        GPUTot=$(echo $i | awk -F "gpu" '{print $2}' | awk -F "=" '{print $2}' )
                else
                        GPUTot="0"
                fi
        fi
        # gpu ocupation
        if [[ "$i" == *AllocTRES* ]]; then
                if [[ "$i" == *gres/gpu* ]]; then
                        GPUoccu=$(echo $i | awk -F "gres/gpu" '{print $2}' | awk -F "=" '{print $2}' )
                        GPUperc=$(printf %.2f%% "$((10**3 * 100 * $GPUoccu/$GPUTot))e-3")
                else
                        GPUoccu="0"
                        GPUperc="0"
                fi
                table+="$PartitionName  |  $nodeName|    $CPUAlloc/$CPUTot/$CPUperc| | $REALmem/$FreeMem/$percmem Gb| $GPUoccu/$GPUTot/$GPUperc %\n"
        fi
done
echo -e ${table} | column -t -s "|"
