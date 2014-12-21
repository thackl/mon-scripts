#!/bin/bash
watch -n 5 '
squeue -o "%.7i %.9P %.15j %.8u %.2t %.12M %.6D %.4C %R" '$1';
echo "\n\n";
sinfo -e -p ngsgrid -n r5n01 -o "%.11P %.5a %.10l %.5D %6t %8N %C";
sinfo -h -e -p genomics -n r5n02 -o "%.11P %.5a %.10l %.5D %6t %8N %C";
sinfo -h -e -p genomics -n r5n03 -o "%.11P %.5a %.10l %.5D %6t %8N %C";
sinfo -h -e -p genomics -n r5n04 -o "%.11P %.5a %.10l %.5D %6t %8N %C";
sinfo -h -e -p genomics -n r5n05 -o "%.11P %.5a %.10l %.5D %6t %8N %C";
echo "\n\n";
df -h | grep -P "Filesystem|shelf|storage";'
