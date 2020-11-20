import os
import subprocess

ipfsContID = subprocess.check_output('docker ps -aqf "name=admin_ipfs_1"', shell=True).decode('utf-8', 'ignore')[:-1]
ipfsClusterContID = subprocess.check_output('docker ps -aqf "name=admin_ipfs-cluster_1"', shell=True).decode('utf-8', 'ignore')[:-1]

os.system("docker exec -it " + ipfsContID + " ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '[\"http://0.0.0.0:5001\", \"http://localhost:3000\", \"http://127.0.0.1:5001\", \"https://webui.ipfs.io\"]'")
os.system("docker exec -it " + ipfsContID + " ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '[\"PUT\", \"POST\"]'")