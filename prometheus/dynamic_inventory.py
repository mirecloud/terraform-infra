import sys
import boto3
import json

# Fix encoding for Windows compatibility
sys.stdout.reconfigure(encoding='utf-8')

# Create EC2 client
ec2 = boto3.client("ec2", region_name="us-east-1")

# Retrieve the instance with tag "Name=Prometheus"
response = ec2.describe_instances(Filters=[{"Name": "tag:Name", "Values": ["Prometheus"]}])

# Debugging: Print response
print(json.dumps(response, indent=4, default=str))

# Ensure at least one instance is found
if not response["Reservations"]:
    print("❌ Aucune instance trouvée avec le tag 'Name=Prometheus'")
    exit(1)

# Get the first instance
instance = response["Reservations"][0]["Instances"][0]

# Try to get PublicIpAddress directly
public_ip = instance.get("PublicIpAddress")

# If not found, try getting it from NetworkInterfaces
if not public_ip and "NetworkInterfaces" in instance:
    for interface in instance["NetworkInterfaces"]:
        if "Association" in interface and "PublicIp" in interface["Association"]:
            public_ip = interface["Association"]["PublicIp"]
            break  # Stop after finding the first public IP

if not public_ip:
    print("❌ L'instance n'a pas d'IP publique attribuée ! Vérifiez si elle est dans une subnet publique.")
    exit(1)

# Generate the Ansible inventory
inventory = {
    "all": {
        "hosts": {
            "prometheus": {
                "ansible_host": public_ip,
                "ansible_user": "ubuntu",
                "ansible_ssh_private_key_file": "/home/asd/.ssh/github"
            }
        }
    }
}

# Save the inventory to JSON
with open("inventory.json", "w") as f:
    json.dump(inventory, f, indent=4)

print(f"✅ Inventory updated: Prometheus -> {public_ip}")
