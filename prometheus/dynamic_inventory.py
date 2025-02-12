import sys
import boto3
import json

# Fix encoding for Windows compatibility
sys.stdout.reconfigure(encoding="utf-8")

# Create EC2 client
ec2 = boto3.client("ec2", region_name="us-east-1")

# Retrieve all running instances
response = ec2.describe_instances(Filters=[{"Name": "instance-state-name", "Values": ["running"]}])

# Debugging: Print raw AWS response (optional)
# print(json.dumps(response, indent=4, default=str))

# Ensure instances are found
if not response["Reservations"]:
    print("❌ No running instances found.")
    exit(1)

# Initialize inventory
inventory = {"all": {"hosts": {}}}

# Loop through all instances
for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        instance_id = instance["InstanceId"]
        tags = {tag["Key"]: tag["Value"] for tag in instance.get("Tags", [])}
        instance_name = tags.get("Name", instance_id)  # Use tag Name or fallback to Instance ID
        
        # Get Public IP
        public_ip = instance.get("PublicIpAddress")

        # If no Public IP, check NetworkInterfaces
        if not public_ip and "NetworkInterfaces" in instance:
            for interface in instance["NetworkInterfaces"]:
                if "Association" in interface and "PublicIp" in interface["Association"]:
                    public_ip = interface["Association"]["PublicIp"]
                    break

        # Skip instances without public IPs
        if not public_ip:
            print(f"⚠️ Skipping {instance_name} ({instance_id}) - No Public IP")
            continue

        # Add instance to inventory
        inventory["all"]["hosts"][instance_name] = {
            "ansible_host": public_ip,
            "ansible_user": "ubuntu",  # Change if needed (e.g., 'ec2-user' for Amazon Linux)
            "ansible_ssh_private_key_file": "/home/asd/.ssh/github"
        }

# Save inventory to JSON
with open("inventory.json", "w") as f:
    json.dump(inventory, f, indent=4)

print(f"✅ Inventory updated with {len(inventory['all']['hosts'])} hosts!")
