sudo mkdir /mnt/cassandra
sudo mkdir /mnt/cassandra/data

sudo apt-get update
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9
sudo apt-get install -y python-pip
sudo apt-get install -y jq
sudo pip install --upgrade pip
sudo chown -R ops:ops /usr/local/lib/python2.7/dist-packages/
pip install cassandra-driver

echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-key A278B781FE4B2BDA
sudo apt-get update
sudo apt-get install -y cassandra
sudo service cassandra stop
sudo apt-get install -y cassandra-tools
sudo rm -rf /var/lib/cassandra/data/system/*
sudo sed -i "s/cluster_name: 'Test Cluster'/cluster_name: 'cassandra_cluster'/g" /etc/cassandra/cassandra.yaml

export PRIVATEIP=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')

sudo sed -i "s/\/var\/lib\/cassandra\/data/\/mnt\/cassandra\/data/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/\/var\/lib\/cassandra\/commitlog/\/mnt\/cassandra\/commitlog/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/\/var\/lib\/cassandra\/saved_caches/\/mnt\/cassandra\/saved_caches/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/seeds: \"127.0.0.1\"/seeds: \"10.1.0.10,10.1.0.11,10.1.0.12\"/g" /etc/cassandra/cassandra.yaml
#sudo sed -i "s/incremental_backups: false/incremental_backups: true/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/listen_address: localhost/listen_address:/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/rpc_address: localhost/rpc_address: 0.0.0.0/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/endpoint_snitch: SimpleSnitch/endpoint_snitch: GossipingPropertyFileSnitch/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: $PRIVATEIP/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/authenticator: AllowAllAuthenticator/authenticator: PasswordAuthenticator/g" /etc/cassandra/cassandra.yaml

export FD=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/platformFaultDomain?api-version=2017-04-02&format=text")
#export LOCATION=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-07-01&format=text")
export LOCATION=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-04-02" | jq -r '.compute.location')

sudo rm -f /etc/cassandra/cassandra-rackdc.properties
sudo touch /etc/cassandra/cassandra-rackdc.properties
sudo chown -R ops:ops /etc/cassandra
sudo chown -R cassandra:cassandra /mnt/cassandra

sudo echo dc=dc-$LOCATION > /etc/cassandra/cassandra-rackdc.properties
sudo echo rack=rack-$FD >> /etc/cassandra/cassandra-rackdc.properties
export CASSANDRA_RACK=rack-$FD
echo set env CASSANDRA_RACK=$CASSANDRA_RACK
export CASSANDRA_DC=dc-$LOCATION
echo set env CASSANDRA_DC=dc-$LOCATION

sudo service cassandra start
