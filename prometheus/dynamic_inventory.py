import sys
import boto3
import json

# Forcer l'encodage en UTF-8 (Windows fix)
sys.stdout.reconfigure(encoding='utf-8')

# Créer un client EC2
ec2 = boto3.client("ec2", region_name="us-east-1")

# Récupérer les instances avec un tag "Name=Prometheus"
response = ec2.describe_instances(Filters=[{"Name": "tag:Name", "Values": ["Prometheus"]}])

# Vérifier s'il y a une instance qui correspond
if not response["Reservations"]:
    print("Aucune instance trouvée avec le tag 'Name=Prometheus'")
    exit(1)

# Extraire la première instance trouvée
instance = response["Reservations"][0]["Instances"][0]

# Récupérer l'IP publique
public_ip = instance.get("PublicIpAddress", "")

if not public_ip:
    print("L'instance n'a pas d'IP publique attribuée !")
    exit(1)

# Générer l'inventaire Ansible en JSON
inventory = {
    "all": {
        "hosts": {
            "prometheus": {
                "ansible_host": public_ip,
                "ansible_user": "ubuntu",
                "ansible_ssh_private_key_file": "C:/Users/emman/Documents/Keys_gitub/github"
            }
        }
    }
}

# Sauvegarder l'inventaire
with open("inventory.json", "w") as f:
    json.dump(inventory, f, indent=4)

# ✅ Supprimer les emojis pour éviter le bug Windows
print(f"Inventory updated: Prometheus -> {public_ip}")
