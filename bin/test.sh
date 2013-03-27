cd test
vagrant up
echo "[server1] /etc/hosts file:"
vagrant ssh server1 -c 'cat /etc/hosts'
echo "[server2] /etc/hosts file:"
vagrant ssh server2 -c 'cat /etc/hosts'
vagrant destroy server1 -f
echo "[server2] /etc/hosts file:"
vagrant ssh server2 -c 'cat /etc/hosts'
vagrant destroy server2 -f
cd ..

