# Kandula Project Application

## What Is Kandula?
Kandula is the a flask based Python web application that will be used in the mid and final project of the course.

The Kandula application has a UI (that will not be part of this course) and backend code which provides data and capabilities to the UI

You main coding tasks throughout the course will be to implement the backend code that is needed to run Kandula properly in production

Kandula will also be the application you will build & deploy (CI & CD) in your mid and final project

> For an introduction to Kandula we recommend you see [this video](https://drive.google.com/file/d/130FJG422J3M5OuEi84byE9VBU_wDUy0S/view?usp=sharing)

# How Can I Run It?

## Prerequisites
- Terraform 
- AWS cli configured with administrative access to your account. (credentials/ IAM role)

## Infrastructure
1. Go over the default variables in the following directories and change them to suit your needs and account:
./terraform/  
./terraform/vpc-module
./terraform-eks/

2. Run terraforn init in the ./terraform/ directory. 

3. Run terraform apply. 

4. Copy the output to a text file- we'll use them soon. You'll need the consul_name value right now.

5. Run cd ../terraform-eks/

6. Change the local variable in variables.tf to the cluster_name you copied. 

7. Run terraform init and terraform apply. 

### Jenkins Configuration 
*** Make sure your own Jenkins AMI has 
- kubectl
- java 11
- jenkins
- jenkins EC2 Plugin 
- jenkins Pipeline Plugin

1. Go to Manage Jenkins> Nodes and Cloud > Cloud
2. Configure Security Groups: insert the ID of the jenkins-sg-kandula you have created. 
3. Advanced> enter the private subnet ids you have created
4. Go to Kandula-Pipeline-MidProject > Configure
5. Enter you default values (in section "this project is parameterized")

Thats it! 
push your code and see how branch 'main' gets built via Webhook.

### WebHook Configuration 
Use your pre-configured route 53 A record (was created in terraform/ directory)
In Git repository settings > Webhook 
Enter this in Payload URL section:
http://<yourjenkinsURL>/github-webhook/
Trigger when "push" option.




