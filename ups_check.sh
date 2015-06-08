#!/bin/sh

# How to use this script to shutdown server when power off
# 1. sudo vi /etc/rc.local
# 2. add the absolute path of ups_check.sh above "exit 0". E.g. "/home/oliver/tarantula/bin/ups_check.sh &" (NOTE: use & to run in background)

# halt command
HALT="halt -p"
 
ping_forever_host(){
    IP=$1
    time_out=$2
    count=3
    kernel=`uname -s`
    total_miss=0
    echo "ups check host '${IP}' for (${time_out}) seconds, [forever mode]"
 
    # ping host, if miss recieved packets, then add to total_miss
    while true
    do
        case $kernel in
            VMkernel)            #esxi 5.1
                ret=`ping -c ${count} -W 1 ${IP} 2>&1|grep 'packets transmitted'|sed 's/.*, \(.*\) packets received,.*/\1/'`
                ;;
            Darwin)            #MacOS X 10.7.4
                ret=`ping -c ${count} -W 1 ${IP} 2>&1|grep 'packets transmitted'|sed 's/.*, \(.*\) packets received,.*/\1/'`
                ;;
            Linux)            #ubuntu 12.04
                ret=`ping -c ${count} -W 1 ${IP} 2>&1|grep 'packets transmitted'|sed 's/.*, \(.*\) received,.*/\1/'`
                ;;
            *)
                echo "Unknown Architecture $kernel"
                exit 1
                ;;
        esac
 
        miss=$((count-ret))
        if [ $miss -eq $count ]; then
            total_miss=$((total_miss+miss))
            echo "total_miss: ${total_miss} --> ${time_out}"
        else
            total_miss=0
        fi
         
        # if miss count over limit, then halt the computer!!!
        if [ $total_miss -ge $time_out ]; then
            echo "SYSTEM WILL HALT AT '`date`'!!!"
            ${HALT}
            break;
        fi
    done
}
 
ping_once_host(){
    IP=$1
    count=$2
    time_out=$2
    kernel=`uname -s`
    total_miss=0
    echo "ups check host '${IP}' for (${time_out}) seconds, [once mode]"
 
    # ping host, if miss recieved packets, then add to total_miss
    case $kernel in
        VMkernel)            #esxi 5.1
            ret=`ping -c ${count} -W 1 ${IP} 2>&1|grep 'packets transmitted'|sed 's/.*, \(.*\) packets received,.*/\1/'`
            ;;
        Darwin)            #MacOS X 10.7.4
            ret=`ping -c ${count} -W 1 ${IP} 2>&1|grep 'packets transmitted'|sed 's/.*, \(.*\) packets received,.*/\1/'`
            ;;
        Linux)            #ubuntu 12.04
            ret=`ping -c ${count} -W 1 ${IP} 2>&1|grep 'packets transmitted'|sed 's/.*, \(.*\) received,.*/\1/'`
            ;;
        *)
            echo "Unknown Architecture $kernel"
            exit 1
            ;;
    esac
 
    miss=$((count-ret))
    if [ $miss -eq $count ]; then
        total_miss=$((total_miss+miss))
        echo "total_miss: ${total_miss} --> ${time_out}"
    else
        total_miss=0
    fi
     
    # if miss count over limit, then halt the computer!!!
    if [ $total_miss -ge $time_out ]; then
        echo "SYSTEM WILL HALT AT '`date`'!!!"
        ${HALT}
    fi
}
 
# main(){
#     action=$1;
#     case $action in
#         forever)            #run forever
#             ping_forever_host $2 $3
#             ;;
#         once)               # run once
#             ping_once_host $2 $3
#             ;;
#         *)
#             echo "usage: sudo ./ups_check forever 192.168.2.1 120"
#             echo "usage: sudo ./ups_check once 192.168.2.1 60"
#             exit 1
#             ;;
#     esac
# }
 
# main $1 $2 $3

# echo "ping_forever_host 192.168.0.1 300"
ping_forever_host 192.168.0.1 300

exit 0
