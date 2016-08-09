#!/bin/sh

pvc_nm=$1
vol_cnt=$2
vol_size=$3"Gi"
dt=`date +"%Y%m%d%H"`

FILE1=yaml/pvc_result_$dt.yaml

if [ -f $FILE1 ];
then
   mv $FILE1 $FILE1.bak
fi

if [ "$vol_cnt" == "" ];
then
   vol_cnt='0'
fi


if [ "$1" == "" ]
then 
	echo "** This is for generating pv, pvc yaml"
	echo "** How to use this shell"
	echo "** You should know your volume name prefix and size"
	echo "** Also you should know pvc(persistent volume claim) name prefix"
	echo "** Generally pvc_nm is volumeClaimTemplates's name and cluster name"
	echo "=============================================="
	echo "Syntax> ./pvc_generator.sh pvc_nm vol_count vol_size "
	echo "Example> ./pvc_generator.sh cassandra-data-cassandra 3 10"
	echo "=============================================="
else
	for ((i=0; i<$vol_cnt; i++)); do
    		sed -e "s;%pvc_nm%;$pvc_nm"-"$i;g" -e "s;%vol_size%;$vol_size;g" template/pvc_template.yaml >> yaml/pvc_result_$dt.yaml
	done

	echo "done! \nGo to yaml directory and check!"
fi
