#!/bin/sh
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

mkdir -p /opt/setup
cd /opt/setup/
touch Dockerfile

echo "FROM ubuntu:16.04" > Dockerfile
echo " " >> Dockerfile
echo "# Install dependencies" >> Dockerfile
echo "RUN apt-get update" >> Dockerfile
echo "RUN apt-get -y install apache2" >> Dockerfile
echo " " >> Dockerfile
echo "# Install apache and write hello world message" >> Dockerfile
echo "RUN echo 'Hello World!' > /var/www/html/index.html" >> Dockerfile
echo " " >> Dockerfile
echo "# Configure apache" >> Dockerfile
echo "RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh" >> Dockerfile
echo "RUN echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh" >> Dockerfile
echo "RUN echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh" >> Dockerfile
echo "RUN echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh" >> Dockerfile
echo "RUN chmod 755 /root/run_apache.sh" >> Dockerfile
echo " " >> Dockerfile
echo "EXPOSE 80" >> Dockerfile
echo " " >> Dockerfile
echo "CMD /root/run_apache.sh" >> Dockerfile
echo "" >> Dockerfile
echo "" >> Dockerfile

docker build -t hello-world -f /opt/setup/Dockerfile .

docker images --filter reference=hello-world

##info : docker run test
#docker run -p 80:80 -d hello-world

##info : write crt
echo "[default]"  > ~/.aws/config
echo "output = json"  >> ~/.aws/config
echo "region = us-west-2"  >> ~/.aws/config

##info : push image
repositoryUri=$(aws ecr create-repository --repository-name hello-world | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["repository"]["repositoryUri"]')
docker tag hello-world $repositoryUri
ECRloginCommand=$(aws ecr get-login --no-include-email)
eval " $ECRloginCommand"
docker push $repositoryUri
