# MediaWikiCloudInfra
Terraform to create and deploy scalable mediawiki in AWS Cloud.

MediaWiki App has many technical requirements and configurations to be pre-setup to deploy the application in any remote machine/local/cloud environments.

I am creating MediaWiki Deployment with the below process:

  1. MediaWiki AWS base image (ubuntu 20) using Hashicorp packer, ansbile provisioner and shell user_data.
  2. MediaWiki AWS Infrastructure creation using the packer build AMI and terraform.
  3. Terraform to provision a jenkins for CI/CD setup. (This I could not complete due to time constraint)
  4. AWS Code Pipeline/Code Build manual setup for MediaWiki github codes' deployment. 


Features:

  1. MediaWiki App, I have designed has a pre-built AMI which can be used to provision the machine to become available as a MediaWiki App. (db setup failed in the ansible provisioning part which I had to complete using manual configuration after the machine was built).
  2. MediaWiki App is backed by 3 ubuntu aws-ec2 instances viz., 2 from a private subnet of AZ1 under ap-south-1 region and 1 from another private subnet of AZ2 under the same ap-south-1 region.
  3. private subnets are attached to IGW, Route Table configurations to become available and to act as a listener/target pool for the Application Load Balancer.
  4. The instances are autoscaled using AWS Launch configuration and Autoscaling group (ASG) in a Elastic Load Balanced environment (ALB). Thus the app is scalable and available. 
  5. Points 2-5 were launched using terraform scripts which I have attached here under /main branch in this repository.
  6. I planned to perform a CI/CD setup for the infrastructure provisioning using Jenkins. For that terraform scripts have also provisioned, installed and configured Jenkins in an another AWS machine. (I have not setup this fully, due to time constraints).
  7. Instead, there is a manual AWS Code Pipeline and AWS Code Build setup (Code Deploy was not attached) for the Infrastructure one-click integration/build.
  8. MediaWiki Application has been configured and setup fully to server for viewing and file uploading.

Security Suggestion(s):

  I feel Its always a best practise to add a bastion/Citrix (or any third party) jumpbox for the users to sign-in to move in to connect the applications DNS, in case if we need to make this more secured.
  
Improvements:

  1. Fix issues raised on ansible provisioner on packer.
  2. Fix CICD through jenkins or complete the AWS CodeDeploy to deploy the terraform infrastructure in AWS. 
  3. Add a remote terraform state configuration in AWS s3 (most recommended and the one I always use) or Github directory.

Security Add-ons:

There can be many improvements we can add up to this application on the security perspective. I feel any application is complete with the below stuffs:

  1. SSM Patching
  2. Inspector configurations for vulnerability prediction
  3. AWS config for security mandatory/best practises updates
  4. antivirus add-ons. Example - Trend micro security.
  
  Thanks
  Thiru
