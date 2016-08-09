# kubernetes_petset

###This is to deploy cassandra, scylla cluster on GCE, AWS using kubernetes petset.

##1. Cassandra
To create cassandra petset clusters

###1) Not Using PV
 When you delete your pods, the volumes also remove

#####a) to edit cassandra-petset.yaml
* you can edit yaml file 
	
<https://github.com/jooyeong/kubernetes_petset/blob/master/yaml/cassandra/cassandra-petset-local.yaml>


#####b) to create cassandra petset cluster

	$ kubectl create -f yaml/cassandra-petset-local.yaml

#####c) to check cassandra cluster status

	$ kubectl exec -it cassandra-0 nodetool status

#####d) to delete cassandra petset cluster 
	$ kubectl delete petset cassandra
	$ kubectl delete service cassandra
	$ kubectl delete pod cassandra-0

#####e) to scale out cassandra petset cluster
	$ kubectl edit petset cassandra

Then you can edit replicas count on petset yaml.  
After editing replicas, cassandra nodes will change immediately. 


###2) Using PV

Even though you delete your pods, the volumes remain.

I've used google container image but it has bug  
(this bug affect only when you create petset cluster with persistent volume)  
For avoiding the bug, I use another image.

####2-1) Using dynamic Persistent Volume
Most steps are same with "Not using PV" steps.  
but you should refer to this file for Using PV  
<https://github.com/jooyeong/kubernetes_petset/blob/master/yaml/cassandra/cassandra-petset-pv.yaml>

	$ kubectl create -f yaml/cassandra-petset-pv.yaml

In this case, the volume create automatically.(Dynamic volume)  
But you cannot choose the volume type and filesystem. (volume default : standard persistent volume(gce), gp2(aws))

Even though you delete pods and petset , the volumes remain.    
Also you can find your volume on your GCE disks

	$ kubectl get pv
	$ kubectl get pvc
	$ gcloud compute disks list
	$ aws ec2 describe-volumes


####2-2) Using SSD persistent disk as PV

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
	$ ./create_volume.sh
	$ ./create_volume.sh gce 3 50 pd-ssd us-central1-b ext4 test
	$ ./create_volume.sh aws 3 50 gp2 us-west-2a ext4


Generally pvc_nm is volumeClaimTemplates's name and cluster name 

	Syntax> ./pvc_generator.sh pvc_nm vol_count vol_size "
	$ ./pvc_generator.sh
	$ ./pvc_generator.sh cassandra-data-cassandra 3 50"


After checking the yaml file, you can create PV, PVC.


	$ kubectl create -f yaml/pv_result.yaml
	$ kubectl create -f yaml/pvc_result.yaml

	
Then, you can create petset cluster.

	$ kubectl create -f yaml/cassandra-petset-pv.yaml
	
	
In this case, When you delete petset cluster, the PV, PVC remains.  
So if you want to delete all about the petset cluster and volume, you should delete PV and PVC.

	$ kubectl delete pv $pv_name
	$ kubectl delete pvc $pvc_name


##2. Scylla

To create scylla petset clusters

###1) Not Using PV
 When you delete your pods, the volumes also remove

It has almost same steps with cassandra.

#####a) to edit scylla-petset-local.yaml
* you can edit yaml file 
	
<https://github.com/jooyeong/kubernetes_petset/blob/master/yaml/scylla/scylla-petset-local.yaml>


#####b) to create cassandra petset cluster

	$ kubectl create -f yaml/scylla-petset-local.yaml

#####c) to check cassandra cluster status

	$ kubectl exec -it scylla-0 nodetool status

#####d) to delete scylla petset cluster 
	$ kubectl delete petset scylla
	$ kubectl delete service scylla
	$ kubectl delete pod scylla-0

#####e) to scale out cassandra petset cluster
	$ kubectl edit petset scylla

Then you can edit replicas count on petset yaml.  
After editing replicas, scylla nodes will change immediately. 


###2) Using PV

Even though you delete your pods, the volumes remain.

####2-1) Using dynamic Persistent Volume
Most steps are same with "Not using PV" steps.  
but you should refer to this file for Using PV  
<https://github.com/jooyeong/kubernetes_petset/blob/master/yaml/scylla/scylla-petset-pv.yaml>

	$ kubectl create -f yaml/scylla-petset-pv.yaml

In this case, the volume create automatically.(Dynamic volume)  
But you cannot choose the volume type and filesystem. (volume default : standard persistent volume(gce), gp2(aws))

Even though you delete pods and petset , the volumes remain.    
Also you can find your volume on your GCE disks

	$ kubectl get pv
	$ kubectl get pvc
	$ gcloud compute disks list
	$ aws ec2 describe-volumes


####2-2) Using SSD persistent disk as PV

Scylla recommend to use SSD and xfs filesystem. 

As I said before, you cannot choose the volume type and filesystem.  
So when you want to use SSD persistent disks and xfs filesystem as PV, you should create disks in advance.    
Also, AWS support xfs filesystem by default but GCE doesn't do that.  
Therefore when you deploy the scylla cluster on GCE, you should install xfsprogs on GCE nodes.  

	Syntax> ./xfs_install.sh zone instance_group_name   
	$ ./xfs_install.sh asia-east1-c  gke-cassandra-test01-default-pool-56c12390d-grp  

And then you can create volume and generate persistent volume yaml using create_volume.sh      
This shell is not completed. You should check the result files  
Also, Don't forget that there is naming rule when you create PVC(persistent volume claim)  

	Syntax> ./create_volume.sh cloudtype volume_count volume_size volume_type volume_zone fs_type prefix"
	$ ./create_volume.sh
	$ ./create_volume.sh gce 3 50 pd-ssd us-central1-b ext4 test
	$ ./create_volume.sh aws 3 50 gp2 us-west-2a ext4


Generally pvc_nm is volumeClaimTemplates's name and cluster name 

	Syntax> ./pvc_generator.sh pvc_nm vol_count vol_size "
	$ ./pvc_generator.sh
	$ ./pvc_generator.sh cassandra-data-cassandra 3 50"


After checking the yaml file, you can create PV, PVC.

	$ kubectl create -f yaml/pv_result.yaml
	$ kubectl create -f yaml/pvc_result.yaml

	
Then, you can create petset cluster.

	$ kubectl create -f yaml/scylla-petset-pv.yaml
	
In this case, When you delete petset cluster, the PV, PVC remains.  
So if you want to delete all about the petset cluster and volume, you should delete PV and PVC.

	$ kubectl delete pv $pv_name
	$ kubectl delete pvc $pvc_name
