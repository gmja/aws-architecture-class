# Lab 3: Creating a High Availability Environment
In this lab you will build a highly available system that could survive component failures via redudancy. This is accomplished by deploying services across multiple availability zones (protecting against AZ failure), employing Elastic Load Balancing (ELB) and Autoscaling to distribute workloads over many EC2 instances (protecting against EC2 instance failure), and deploying a Database failover replica in a seperate zone (protecting against Primary failure).  This lab builds on the system in Lab 2 (so follow the instructions to build that system first if you haven't completed Lab 2 yet)

## Task 1: Expand VPC to have public and private subnets across two zones
In Lab2 you created a VPC with one public subnet and one private subnet in one availability zone and another private subnet in another availability zone.  In this task you will add another public subnet so that there is a public subnet and private subnet in two availability zones.

1. In **Services->VPC** click **Subnets** in the left-hand pane.  You should see your subnets from Lab2.  Rename your public subnet from Lab 2 from firstname-lastname-public to firstname-lastname-public1 by hovering over the Name and clicking the pencil icon next to it.

2. Click the **Create subnet** button, give it the **Name tag** firstname-lastname-public2 and select your VPC in the **VPC** dropdown selector.  Select the second **Availability Zone** in the dropdown selector list and set the **IPv4 CIDR block** to 10.0.1.0/24.  Then click **Create** and **Close**

3. To make the subnet public we need to associate it with a route table that has a route to the internet gateway.  Click on the checkbox to the left of your new subnet (firstname-lastname-public2, make sure it is the only one selected).  Scroll down and click on the **Route Table** tab.  You should see it is currently associated with your VPC's default route table (which you renamed firstname-lastname-private-rt in lab2).  Click the **Edit route table association** button then in the dropdown select your public route table from lab2 (firstname-lastname-public-rt) then click the **Save** button

## Task 2: Create an Application Load Balancer
In this task you will create an Application Load Balancer that can distribute web traffic to multiple EC2 instances across multiple availability zones.

1. In **Services->EC2** click **Load Balancers** in the left-hand menu, then click the **Create Load Balancer** button

2. Under **Application Load Balancer** click **Create**, set **Name** to firstname-lastname-alb, scroll down to the **Availability Zones** section and make sure the VPC dropdown is set to your VPC (firstname-lastname-vpc), then click the check-boxes next to the two availability zones you used for your subets and select the public subnet (firstname-lastname-public1 and firstname-lastname-public2) in the dropdown for each, then click **Next:Configure Security Settings** (you will see a warning displayed about using HTTPS instead but disregard that and just press the **Next:Configure Security Settings** button again)

3. Leave the radio button set to **Select an existing security group** and then click the checkbox to the left of your app server security group from lab2 (firstname-lastname-app-sg).  This security group allows HTTP requests from anywhere in the internet which is what we want, then click **Next:Configure Routing**

4. Leave the **Target group** dropdown set to **New target group** and set **Name** to firstname-lastname-tg

5. Click on the **Advanced health check settings** to open the section, set the **Health threshold** to **2** and the **Interval** to 10, then click **Next:Register Targets** and then **Next:Review**, then **Create** and then **Close**

## Task 3: Create a NAT gateway and update private subnets to use
In this task we will create a NAT gateway in one of our public subnets of our VPC and configure the route table used by our private subnets to direct internet-bound requests to the NAT gateway.  This will be necessary because we are going to launch our EC2 instances in the private subnet (since we are sending web requests to them via the ELB they no longer need to be in the public subnet).  The EC2 instances will download software from the internet (via a User data script) and so need to be able to make requests to the internet and the NAT gateway will let them do this even though they are in the private subnets.

1. In **Services->VPC** in the left-hand pane click **NAT gateways**, click **Create NAT gateway**, select one of your public subnets, click **Create New EIP** then click **Create NAT gateway**, then click **Edit route tables**, select your private route table (firstname-lastname-private-rt), click on the **Routes** tab, and **Edit routes** and **Add route** and enter 0.0.0.0/0 and select **Target** and select the first id in the list you see (or the only one if you see only one, there may be others that someone else working in the same region as you has already created but it doesn't matter if you select the one you created or they created), click **Save routes** and **Close**

Now whenever resources in the private subnet send traffic to the internet (0.0.0.0/0 bound traffic) they will forward that traffic to the NAT gateway which will forward it into the internet (passing back responses back to the requesting instance)

## Task 4: Create an Auto Scaling Group
In this task you will create an Auto Scaling Group which can automatically create and destroy EC2 instances across multiple availability zones as the workload on existing instances increase or decreases.

1. In the left-hand menu click on **Auto Scaling Groups** then click **Create Auto Scaling group** button then click the **Get started** button

The following process will create a Launch Configuration which is the same process as creating an EC2 instances but this creates a template that the Auto Scaling group will use to create new instances whenever it scales up

2. Click the **Select** button next to the AMI at the top of the list (Amazon Linux 2 AMI), leave the instance type set to **t2.micro** and click **Next:Configure details**, set the **Name** to firstname-lastname-lc, set the **IAM role** to the role you had created in lab2 (firstname-lastname-inventory-role), click on the **Advanced Details** section to open it and then paste the below script into the **User data** section (this is the same User data that was used in lab2, installing the same web application), then click **Next:Add Storage**, and then click **Next:Configure Security Group**

```bash
#!/bin/bash
# Install Apache Web Server and PHP
yum install -y httpd mysql
amazon-linux-extras install -y php7.2
# Download Lab files
wget https://us-west-2-tcprod.s3.amazonaws.com/courses/ILT-TF-100-ARCHIT/v6.5.0/lab-2-webapp/scripts/inventory-app.zip
unzip inventory-app.zip -d /var/www/html/
# Download and install the AWS SDK for PHP
wget https://github.com/aws/aws-sdk-php/releases/download/3.62.3/aws.zip
unzip aws -d /var/www/html
# Turn on web server
chkconfig httpd on
service httpd start
```

3. Click the radio button to the left of **Select an existing security group** then click the checkbox next to your app server security group (firstname-lastname-app-sg), then click **Review**.  You will see a warning dialog, just click the **Continue** button, then click **Create launch configuration**.  A dialog will open, in the dropdown select **Proceed without a keypari** and click the acknowledgement checkbox and then **Create launch configuration**

This will now return you to the **Create Auto Scaling Group** form workflow

4. Set the **Name** field to firstname-lastname-asg and the **Group size** to **2**, set **Network** to your VPC (firstname-lastname-vpc), and then select your 2 private subnets in the **Subnet** field (firstname-lastname-private1 and firstname-lastname-private2)

5. Click on the **Advanced Details** section to open it, click the checkbox next to **Load Balancing** and **Receive traffic from one or more load balancers** and then select your target group in the **Target Groups** field (firstname-lastname-tg), then click the **Next:Configure scaling policies** button

6. Normally you would click the radio button **Use scaling policies to adjust the capacity of this group** to set up a scaling policy but for simplicity we'll just leave the **Keep this group at its initial size** (since we won't be testing scaling up under increasing traffic load in this lab)

7. Click **Next:Configure Notifications** and then **Next:Configure Tags**, add a tag with **Key** set to **Name** and **Value** set to **firstname-lastname-inventory-app** and make sure the checkbox under **Tag New Instances** is checked, then click **Review** and then click **Create Auto Scaling group** and then **Close**

## Task 5: Test the application
In this task you will verify the application is functioning as expected

1. In **Services->EC2** in the left-hand pane click **Load Balancers** and copy the **DNS name** in the **Basic Configuration** section and then open a new browser tab and past the DNS name into the URL bar

2. You should see the same web application as lab2, refresh the page a few times and you should see the instance ID and region at the bottom will periodically alternate between the two instances in the Auto Scaling Group

To simulate a instance or zone failure we'll terminate one of the instances

3. Return to the AWS Management Console browser tab, and in the left-hand menu click **Instances**, then click on the checkbox to the left of one of your running instances in the Auto Scaling group (firstname-lastname-inventory-app) and then click **Actions->Instance State->Terminate**, you will see a warning dialog and click **Yes, Terminate**

4. Return to the browser tab with the web application and refresh the page many times, you should see the web application is still available and now every time it is showing the same instance id and availability zone at the bottom (the one you didn't terminate)

## Task 6: Make the DB and NAT gateway high availability
In this task you will make the Amazon RDS DB high availability by creating a failover replica in the other private subnet and you will make the NAT gateway high availability by creating a second one in the other public subnet

1. In **Services->RDS**, click on **Databases** in the left-hand menu, then click the radio button to the left of your Database from lab2 (firstname-lastname-inventory-db), then click **Modify**, then set the **Multi-AZ deployment** to **Yes**.  You will see a warning but click on the radio button to the left of **Apply Immediately** then click **Modify DB Instance**

2. In **Services->VPC**, click on **NAT Gateways** in the left-hand menu, then click **Create NAT Gateway**. In the **Subnet** dropdown, select your other public subnet (firstname-lastname-public2) and click the **Create New EIP**, then click **Create NAT Gateway**

3. Next click the **Edit Route Tables** button and then **Create route table** button, set **Name** to firstname-lastname-private-rt2 and select your VPC in the **VPC** dropdown, click the **Add route** button, enter **0.0.0.0/0** in the **Destination** field, and the new NAt gateway in the **Target** field, then click **Create** and **Close**

4. In the left-hand menu click on **Subnets**, click the checkbox to the left of your second private subnet (firstname-lastname-private2), scroll down the page and click on the **Route Table** tab and the **Edit route table association** button, select your new route table in the **Route Table ID** dropdown (firstname-lastname-private-rt2), and click **Save**


