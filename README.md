# kubernetes_petset

###This is to deploy cassandra, scylla cluster on GCE, AWS using kubernetes petset.

#1. Cassandra
To create cassandra petset clusters

##1) Not Using PV
 When you delete your pods, the volumes also remove

####a) to edit cassandra-petset.yaml
* you can edit yaml file 
	
<https://github.com/jooyeong/joo/edit/master/kubernetes_petset/cassandra/yaml/cassandra-petset-local.yaml>


####b) to create cassandra petset cluster

	$ kubectl create -f cassandra-petset-local.yaml

####c) to check cassandra cluster status

	$ kubectl exec -it cassandra-0 nodetool status

####d) to delete cassandra petset cluster 
	$ kubectl delete petset cassandra
	$ kubectl delete service cassandra
	$ kubectl delete pod cassandra-0

####e) to scale out cassandra petset cluster
	$ kubectl edit petset cassandra

Then you can edit replicas count on petset yaml.  
After editing replicas, cassandra nodes will change immediately. 


##2) Using PV

Even though you delete your pods, the volumes remain.

I've used google container image but it has bug  
(this bug affect only when you create petset cluster with persistent volume)  
For avoiding the bug, I use another image.

###2-1) Using dynamic Persistent Volume
Most steps are same with "Not using PV" steps.  
but you should refer to this file for Using PV  
<https://github.com/jooyeong/joo/edit/master/kubernetes_petset/cassandra/yaml/cassandra-petset-pv.yaml>

In this case, the volume create automatically.(Dynamic volume)  
But you cannot choose the volume type and filesystem. (volume default : standard persistent volume(gce), gp2(aws))

Even though you delete pods and petset , the volumes remain.    
Also you can find your volume on your GCE disks

	$ kubectl get pv
	$ kubectl get pvc
	$ gcloud compute disks list
	$ aws ec2 describe-volumes


###2-2) Using SSD persistent disk as PV

As I said before, when you use the persistent volume, you cannot choose the volume type, filesystem.  
There is a way to modify volume type  
You should refer this link.(https://github.com/kubernetes/kubernetes/issues/23525)  

After do this, you can just create petset cluster.  
Even though modifying the code , you cannot choose the volume type.  
It is just updated default volume type. 


Otherwise when you want to use SSD persistent disks as PV, you should create SSD disks in advance.  
(Cassandra recommend to use SSD)

You can create volume and generate persistent volume yaml using create_volume.sh  
This shell is not completed. You should check the result files  
Also, Don't forget that there is naming rule when you create PVC(persistent volume claim)  

	Syntax> ./create_volume.sh cloudtype volume_count volume_size volume_type volume_zone fs_type prefix"
	$ ./create_volume.sh gce 3 50 pd-ssd us-central1-b xfs test"


Generally pvc_nm is volumeClaimTemplates's name and cluster name 

	Syntax> ./pvc_yaml_generator.sh pvc_nm vol_count vol_size "
	$ ./pvc_yaml_generator.sh cassandra-data-cassandra 3 50"


After checking the yaml file, you can create PV, PVC.


	$ kubectl create -f pv_result.yaml
	$ kubectl create -f pvc_result.yaml

	
Then, you can create petset cluster.

	$ kubectl create -f cassandra-petset-pv.yaml
	
	
In this case, When you delete petset cluster, the PV, PVC remains.  
So if you want to delete all about the petset cluster and volume, you should delete PV and PVC.

	$ kubectl delete pv $pv_name
	$ kubectl delete pvc $pvc_name


