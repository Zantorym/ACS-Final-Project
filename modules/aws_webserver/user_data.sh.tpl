#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
sudo aws s3 cp s3://${lower(env)}-s3-acsgroup13/images/Jass.jpeg /var/www/html
sudo aws s3 cp s3://${lower(env)}-s3-acsgroup13/images/jaishreej.jpeg /var/www/html
sudo aws s3 cp s3://${lower(env)}-s3-acsgroup13/images/harsh.jpeg /var/www/html
sudo aws s3 cp s3://${lower(env)}-s3-acsgroup13/images/neil.jpeg /var/www/html
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
sudo systemctl start httpd
sudo systemctl enable httpd
echo "
<html>
<head>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
</head>
<body>
<section class="team text-center py-5">
   <div class="container">
     <div class="header my-5">
       <h1>Meet our Team </h1>
       <h3>Welcome to ACS Project Web Page! The private IP is $myip! The environment is ${env}</h3>
       <p class="text-muted">Group 13</p>
     </div>
     <div class="row">
       <div class="col-md-6 col-lg-3">
         <div class="img-block mb-5">
           <img src="jaishreej.jpeg" class="img-fluid  img-thumbnail rounded-circle" alt="image1">
           <div class="content mt-2">
             <h4>Jaishree Jaishankar</h4>
           </div>
         </div>
       </div>
       <div class="col-md-6 col-lg-3 ">
         <div class="img-block mb-5">
           <img src="Jass.jpeg" class="img-fluid  img-thumbnail rounded-circle" alt="image1">
           <div class="content mt-2">
             <h4>Jaspreet Singh Marwah</h4>
           </div>
         </div>
       </div>
       <div class="col-md-6 col-lg-3">
         <div class="img-block mb-5">
           <img src="harsh.jpeg" class="img-fluid  img-thumbnail rounded-circle" alt="image1">
           <div class="content mt-2">
             <h4>Harsh Alkesh Shah</h4>
           </div>
         </div>
       </div>
       <div class="col-md-6 col-lg-3">
         <div class="img-block mb-5">
           <img src="neil.jpeg" class="img-fluid  img-thumbnail rounded-circle" alt="image1">
           <div class="content mt-2">
             <h4>Neil Suryanarayanan</h4>
           </div>
         </div>
       </div>
     </div>
   </div>
 </section>
 </body>
 </html>
 
 "  >  /var/www/html/index.html 