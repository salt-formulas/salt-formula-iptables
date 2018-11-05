#!/bin/bash -xe
# Speedup reverse hostname lookup
sed -i "s/127.0.0.1.*/127.0.0.1 localhost $(hostname)/" /etc/hosts
# Enabling password auth for kitchen user
sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
# Disable sshd NS lookups
echo "UseDNS no" >> /etc/ssh/sshd_config
service ssh restart
# Create user 'kitchen' with password 'kitchen'
useradd -m -G adm,sudo -p '$6$DqOdqb/l$hOpDWFPeC8/45Oo8NbqZyqLZxYd.Vtlujf9A4OdwUKgBjRcETuc9Gd2C7OyI99MY2N/pACrbV8WymqV.H1XZ1.' -s /bin/bash kitchen
# Passwordless sudo for user 'kitchen'
echo "kitchen ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-kitchen
# Secure kitchen home
chown kitchen:root /home/kitchen -R
chmod 0700 /home/kitchen
