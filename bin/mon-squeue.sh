#!/bin/bash

Bin="$(dirname "$(readlink -f "$0")")"
MODE="short";

# Execute getopt
ARGS=`getopt --name "$SCRIPT" \
    --options "r:m:h" \
    --longoptions "remote:,mode:,help" \
    -- "$@"`

#Bad arguments
[ $? -ne 0 ] && exit 1;

# A little magic
eval set -- "$ARGS"

# Now go through all the options
while true; do
    case "$1" in
        -r|--remote)
            [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1);
            REMOTE=$2;
            shift 2;;
        -m|--mode)
            [ ! -n "$2" ] && (echo "$1: value required" 1>&2 && exit 1);
            MODE=$2;
            shift 2;;
        -h|--help)
            show_help && exit 0;;
        --)
            shift
            break;;
        *)
            echo "$1: Unknown option" 1>&2 && exit 1;;
  esac
done

case "$MODE" in
    short)
        SQUE='squeue '$@' -o "%.15j %.8u %.2t %.4C %R"';
        POOL="$Bin"'/pool_rows.pl -i --columns 0,1,2 --sort 2,1,4' ;;
    long)
        SQUE='squeue '$@' -o "%.7i %.9P %.15j %.8u %.2t %.12M %.6D %.4C %R"';
        POOL="$Bin"'/pool_rows.pl -i --columns 1,2,3,4,6,7,8 --sort 4,8,3';;
    top)
        SQUE='top -n1 -b | sed -n "7,100{s/^ \+//;s/ \+/\t/g;p}" | cut -f2,8,9,10,12 | grep -vw root | grep -vw top';
        POOL="$Bin"'/pool_rows.pl -i --columns 0,1 --sort 1,0,2,4';;
    *)
        echo "unknown mode: $MODE" 1>&2;
        exit 1;;
esac;

if [ -n "$REMOTE" ]; then
    ssh $REMOTE $SQUE | grep -v "^CLUSTER:" | $POOL;
else
    $SQUE | grep -v "^CLUSTER:" | $POOL;
fi;
