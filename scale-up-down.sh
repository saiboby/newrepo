export AWS_DEFAULT_REGION=us-west-2
aws s3 ls

echo "Autoscaling group changes before updating"
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name "prodint3_worker_asg"

export KUBECONFIG=$WORKSPACE/cluster_metadata_config.yml

#kubectl get pods -A

if [[ $Scale == "DOWN" ]]; then
   echo "Scaling down the prodint cluster"
   
   echo "Suspending elasticsearch-curator cronjob"
   kubectl patch cronjobs elasticsearch-curator -p '{"spec" : {"suspend" : true }}' -n logging
   
   echo "Suspending elk-satellite-at-es-curator cronjob"
   kubectl patch cronjobs elk-satellite-at-es-curator -p '{"spec" : {"suspend" : true }}' -n logging
   
   echo "Suspending elk-satellite-at-index-patterns cronjob"
   kubectl patch cronjobs elk-satellite-at-index-patterns -p '{"spec" : {"suspend" : true }}' -n logging
   
   echo "Suspending elk-satellite-ei-es-curator cronjob"
   kubectl patch cronjobs elk-satellite-ei-es-curator -p '{"spec" : {"suspend" : true }}' -n logging
   
   echo "Suspending elk-satellite-ei-index-patterns cronjob"
   kubectl patch cronjobs elk-satellite-ei-index-patterns -p '{"spec" : {"suspend" : true }}' -n logging
   
   echo "Suspending elk-satellite-rainier-es-curator cronjob"
   kubectl patch cronjobs elk-satellite-rainier-es-curator -p '{"spec" : {"suspend" : true }}' -n logging

   echo "Suspending elk-satellite-rainier-index-patterns cronjob"
   kubectl patch cronjobs elk-satellite-rainier-index-patterns -p '{"spec" : {"suspend" : true }}' -n logging
   
   echo "Suspending dynamic-tags-cronjob curator cronjob"
   kubectl patch cronjobs dynamic-tags-cronjob -p '{"spec" : {"suspend" : true }}' -n kube-system
   
   echo "Suspending kute-suite1 curator cronjob"
   kubectl patch cronjobs kute-suite1 -p '{"spec" : {"suspend" : true }}' -n kute
   
   echo "Suspending kibana-kibana-index-patterns cronjob"
   kubectl patch cronjobs kibana-kibana-index-patterns -p '{"spec" : {"suspend" : true }}' -n logging
   
   echo "Suspending rainier-csragent-backup cronjob"
   kubectl patch cronjobs rainier-csragent-backup -p '{"spec" : {"suspend" : true }}' -n rainier
   
   #echo "Suspending elasticsearch-curator-hourly cronjob"
   #kubectl patch cronjobs elasticsearch-curator-hourly -p "{\"spec\" : {\"suspend\" : true }}" -n logging
   
   #echo "Suspending rds-snapshot-create-and-delete cronjob"
   #kubectl patch cronjobs rds-snapshot-create-and-delete -p "{\"spec\" : {\"suspend\" : true }}" -n infra-system
   
   if $include_bastion; then
      aws autoscaling update-auto-scaling-group --auto-scaling-group-name "prodint3_bastion_asg" --desired-capacity 0 --min-size 0
   fi
   aws autoscaling update-auto-scaling-group --auto-scaling-group-name "prodint3_worker_asg" --desired-capacity 0 --min-size 0
else
   echo "Scaling up the prodint cluster"
   
   echo "Enabling elasticsearch-curator cronjob"
   kubectl patch cronjobs elasticsearch-curator -p '{"spec" : {"suspend" : false }}' -n logging
   
   echo "Suspending elk-satellite-at-es-curator cronjob"
   kubectl patch cronjobs elk-satellite-at-es-curator -p '{"spec" : {"suspend" : false }}' -n logging
   
   echo "Suspending elk-satellite-at-index-patterns cronjob"
   kubectl patch cronjobs elk-satellite-at-index-patterns -p '{"spec" : {"suspend" : false }}' -n logging
   
   echo "Suspending elk-satellite-ei-es-curator cronjob"
   kubectl patch cronjobs elk-satellite-ei-es-curator -p '{"spec" : {"suspend" : false }}' -n logging
   
   echo "Suspending elk-satellite-ei-index-patterns cronjob"
   kubectl patch cronjobs elk-satellite-ei-index-patterns -p '{"spec" : {"suspend" : false }}' -n logging
   
   echo "Suspending elk-satellite-rainier-es-curator cronjob"
   kubectl patch cronjobs elk-satellite-rainier-es-curator -p '{"spec" : {"suspend" : false }}' -n logging

   echo "Suspending elk-satellite-rainier-index-patterns cronjob"
   kubectl patch cronjobs elk-satellite-rainier-index-patterns -p '{"spec" : {"suspend" : false }}' -n logging
   
   echo "Enabling dynamic-tags-cronjob curator cronjob"
   kubectl patch cronjobs dynamic-tags-cronjob -p '{"spec" : {"suspend" : false }}' -n kube-system
   
   echo "Enabling kute-suite1 curator cronjob"
   kubectl patch cronjobs kute-suite1 -p '{"spec" : {"suspend" : false }}' -n kute
   
   echo "Enabling kibana-kibana-index-patterns cronjob"
   kubectl patch cronjobs kibana-kibana-index-patterns -p '{"spec" : {"suspend" : false }}' -n logging
   
   echo "Enabling rainier-csragent-backup cronjob"
   kubectl patch cronjobs rainier-csragent-backup -p '{"spec" : {"suspend" : false }}' -n rainier
   
   #echo "Enabling elasticsearch-curator-hourly cronjob"
   #kubectl patch cronjobs elasticsearch-curator-hourly -p "{\"spec\" : {\"suspend\" : false }}" -n logging
   
   #echo "Enabling rds-snapshot-create-and-delete cronjob"
   #kubectl patch cronjobs rds-snapshot-create-and-delete -p "{\"spec\" : {\"suspend\" : false }}" -n infra-system
   
   if $include_bastion; then
      aws autoscaling update-auto-scaling-group --auto-scaling-group-name "prodint3_bastion_asg" --desired-capacity 1 --min-size 1
   fi
   aws autoscaling update-auto-scaling-group --auto-scaling-group-name "prodint3_worker_asg" --desired-capacity $worker_desired --min-size $worker_min
fi


echo "Autoscaling group changes after updating"
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name "prodint3_worker_asg"
