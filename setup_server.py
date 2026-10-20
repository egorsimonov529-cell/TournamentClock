import subprocess
import os

password = '4#9inC3%MYZ84F9f'
server_ip = '188.225.81.114'
user = 'root'

# Read public key
with open(r'C:\Users\Lenovo\.ssh\id_rsa.pub', 'r') as f:
    pub_key = f.read().strip()

# Write script to copy key
scp_script = f"""#!/bin/bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '{pub_key}' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "Key copied successfully"
"""

with open('/tmp/copy_key.sh', 'w') as f:
    f.write(scp_script)

# Use sshpass to copy the key
cmd = f'sshpass -p "{password}" ssh -o StrictHostKeyChecking=no {user}@{server_ip} "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo \\"{pub_key}\\" >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo \'Key copied successfully\'"'

print('Copying SSH key...')
result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
print('STDOUT:', result.stdout)
print('STDERR:', result.stderr)
print('Return code:', result.returncode)
