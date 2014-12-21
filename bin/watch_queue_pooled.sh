#!/bin/bash

if [ $# -gt 0 ]; then
    STRING=$1;
else
    STRING=`whoami`;
fi;

watch --color -n 5 '
squeue -o "%.7i %.9P %.15j %.8u %.2t %.12M %.6D %.4C %R" | /storage/genomics/scripts/bin/pool_rows.pl -i --columns 1,2,3,4,6,7,8 | perl /storage/genomics/scripts/bin/write_color.pl '$STRING'
echo ""
sinfo -e -p ngsgrid -n r5n01 -o "%.11P %.5a %.10l %.5D %6t %8N %C"
sinfo -h -e -p ngsgrid -n r5n04 -o "%.11P %.5a %.10l %.5D %6t %8N %C"
sinfo -h -e -p genomics -n r5n02 -o "%.11P %.5a %.10l %.5D %6t %8N %C"
sinfo -h -e -p genomics -n r5n03 -o "%.11P %.5a %.10l %.5D %6t %8N %C"
#sinfo -h -e -p genomics -n r5n04 -o "%.11P %.5a %.10l %.5D %6t %8N %C"
sinfo -h -e -p genomics -n r5n05 -o "%.11P %.5a %.10l %.5D %6t %8N %C"
echo ""
df -h | grep -P "Filesystem|shelf|storage"'
