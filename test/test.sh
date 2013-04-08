cd test

vagrant up

vagrant hostmanager

echo "[server1] /etc/hosts file:"
vagrant ssh server1 -c 'cat /etc/hosts'
echo "[server2] /etc/hosts file:"
vagrant ssh server2 -c 'cat /etc/hosts'

vagrant destroy -f

cd ..
