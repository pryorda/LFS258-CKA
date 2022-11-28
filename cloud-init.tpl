#cloud-config

#ssh_authorized_keys:
#  - ${key1}
#  - ${key2}
#users:
#  - name: ubuntu
#    group: 
ssh_import_id:
  - gh:pryorda
final_message: "The system is finally up, after $UPTIME seconds"
