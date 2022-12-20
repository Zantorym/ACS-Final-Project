#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
sudo aws s3 cp s3://dev-s3-acsgroup13/images/photo.jpg /var/www/html
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>Welcome to Group 13 ACS Project! My private IP is $myip</h1><img src="photo.jpg" alt="TestImage" border=3 height=200 width=300></img>"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd