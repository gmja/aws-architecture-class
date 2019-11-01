# Lab 2: Creating a VPC and deploying a Web App
In this lab you will create a VPC in a region and then proceed to create some subnets, an internet gateway, route tables, security groups, and a web-app (an app server and a database).  Wherever instructed to put the text firstname-lastname-x you should replace firstname with your first-name and lastname with your last-name

## Task 1: Create a VPC
You'll begin by creating a VPC.  You could use the wizard to make it as simple as possible but here we'll do it with
a more manual approach for practice.

1. In **Services->VPC** click **Your VPCs** on the left, and then click on **Create VPC**.

2.  For **Name tag** give it the name firstname-lastname-vpc (replace firstname with your firstname in lowercase and lastname with your lastname in lowercase).  For **IPv4 CIDR block** put 10.0.0.0/16.  Then click **Create** and **Close**

3.  Click the checkbox next to the VPC you just created in the last (make sure it is the only one selected and deselect any other if they are also selected).  Click on the **Actions** button and click **Edit DNS hostnames**.  Click the checkbox next to **enable** and click
**Save** and then **Close**

This will assign friendly dns names to your instances when they are added to the vpc.  The names will have a format that looks like
ec2-52-42-133-255.us-west-2.compute.amazonaws.com where us-west-2 is the region that your VPC is in and the first portion matches the 
public IP address of your instance.  You could change this to a more meaningful name by using Route 53 (the AWS DNS service)

## Task 2: Create subnets
Now you'll add some subnets to the VPC.  One public and one private subnet.

1. In the left-hand pane click **Subnets**, then click **Create subnet**.  Give it the **Name tag** firstname-lastname-public and select your VPC in the **VPC** dropdown selector.  Select the first **Availability Zone** in the dropdown selector list and set the **IPv4 CIDR block** to 10.0.0.0/24.  Then click **Create** and **Close**

Note: you have to select a CIDR range for the subnet that is inside the CIDR range of the VPC it is in.  and 10.0.0.0/24 is within 10.0.0.0/16.

2. Select the subnet you just created via the checkbox to the left of it in the list and click **Actions** and **Modify auto-assign IP settings**.  Click the checkbox next to **Auto-assign IPv4** and click **Save**.

This will automatically assign a public IPv4 address to all EC2 instances as they are added to the subnet.  However this subnet is not truly public yet until we add an Internet Gateway to connect it to the internet (which you'll do in the next task).

3. Repeat the steps again two more times to make two private subnets named firstname-lastname-private1 with IP range 10.0.2.0/23 and firstname-lastname-private2 with IP range 10.0.4.0/23 in the first and second availability zones in the list (each private subnet in a seperate availability zone)

Note this range is also within the VPC range and it is twice as large as the public range.  This is typical as most of your resources shoudl be in private subnets and so they need larger IP spaces to be able to assign IP addresses to larger numbers of resources.

## Task 3: Create an internet gateway
Now you will add an internet gateway to add internet connectivity to VPC and then you'll set up that internet gateway to provide the connectivity to the public subnet your created.  An internet gateway is a horizontally scaled redundant high capacity service.  It 
does not place any availability risk (due to failure) or bandwith limits on traffic between the internet and your VPC.

The internet gateway provides a target for your route tables to connect to the internet and also provides the NAT (network address translation) for instances with public IP addresses.

1. In the left-hand pane click **Internet gateways** then click **Create internet gateway**.  Give it the name firstname-lastname-igw then click **Create** and **Close**

2. Select the newly create internet gatway (make sure its the only one selected) and click **Action** then **Attach to VPC**. Select your VPC and click **Attach**

Your VPC is now connected to the internet but you will need to update the route table for your public subnet to use it to connect to the internet.

## Task 4: Configure route tables
A route table includes a set of routes which are rules for where to send traffic which destination IP addresses that match the routes.  Each subnet must be connected to a subnet which controls where traffic from that subnet can be routed.  A subnet can only be associated with one route table at a time, but multiple subnets can be associated with the same route table.

For a subnet to use the internet gateway it needs to have a route in its route table that points internet-bound traffic at the internet gateway.  Subnets that have such routes are known as *Public subnets*

1. In the left-hand pane click **Route Tables**.  In the list look for the one that is currently in use for your vpc.  You can tell by looking at the **Summary** tab below and you'll see the **VPC** field will have the name of your VPC in it.  If you click on the **Routes** tab you will see it has a single route and the **Target** is local (so this is a private route table that does not connect to the internet).

2. Click on the pencil icon in the **Name** column for this route table and give it the **Name** firstname-lastname-private-rt

3. Click **Create route table** and set **Name tag** to firstname-lastname-public-rt and **VPC** to your create VPC.  Click **Create** and **Close**

4. Select the newly created route table in the list via the checkbox to the left (make sure it is the only one selected).  Click on the **Routes** tab, and click the **Edit routes** button and **Add route** button.  Put 0.0.0.0/0 in **Destination** and the select **Internet gateway** in the **Target** selector and then click on your internet gateway, and then click **Save routes** and **Close**

Now we have to associate this new public route table with the public subnet

5. Click the **Subnet associations** tab and click the **Edit subnet associations** button, select your public subnet via the checkbox to the left of it, and click **Save**

Now your public subnet is truly public as it can send and receive traffic into the internet.  To summarize, to make a subnet public requires creating (or already having) an internet gateway in your VPC, creating a route table (or adding a route to an existing route table) that points 0.0.0.0/0 destinatation traffic to that internet gateway, and associating that route table with the subnet which you want to be public (which then becomes public)

## Task 5: Create Security groups
In this task you will create Security groups to lock down the type of traffic that can flow into your App server and Database (to be added later)

1. In **Services->EC2** click on **Security Groups** in the left-hand navigation panel

2. Click the **Create Security Group** button and then set the **Security group name** to **firstname-lastname-app-sg**, **Description** to **Allow HTTP traffic**, and **VPC** to your created VPC (firstname-lastname-vpc), then click **Create**.  This security group will be used to allow HTTP traffic into your app server

3. Select the security group you just created (via checkbox to the left of it in the list), and click the **Actions->Edit inbound rules** option and then click the **Add Rule** button, set **Type** to **HTTP** and **Source** to **Anywhere** and click **Save rules**

4. Select the security group you just created and copy the **Group ID** displayed in the **Description** tab in the lower half of the page

5. Click the **Create Security Group** button and then set the **Security group name** to **firstname-lastname-db-sg**, **Description** to **Allow DB access**, and **VPC** to your created VPC (firstname-lastname-vpc), then click **Create**.  This security group will be used to allow DB traffic to come from your app server to your database

6. Select the security group you just created (via checkbox to the left of it in the list), and click the **Actions->Edit inbound rules** option and then click the **Add Rule** button, set **Type** to **MYSQL/Aurora** and **Source** to the **Group ID** you copied in step 4, then click **Create**

## Task 6: Create a Database
In this task you will create an Amazon RDS MySQL Database

1. In **Services->RDS** in the left-hand menu, click **Subnet groups**, then click the **Create DB subnet group** button. Set **Name** to firstname-lastname-subnet-group, set **Description** to **inventory-db subnet group**, set the **VPC** to your created VPC (firstname-lastname-vpc)

2. In the **Add Subnets** section, for **Availability zone** dropdown, select the top one in the list, for the **Subnet** dropdown, select your first private subnet (10.0.2.0/23) and click the **Add subnet** button, then set **Availability zone** dropdown to the second one in the list and **Subnet** to your second private subnet (10.0.4.0/23) and click the **Add subnet** button, then click the **Create** button

2. Then click on **Dashboard** in the left-hand menu, and then click **Create Database**

2. Leave the **Choose a database creation method** as is (it should be set to **Standard Create**).  For **Engine Type** select **MySQL** and leave the **Version** as is

3. In the **Templates** section, select **Dev/Test** and under **Settings** set the **DB instance identifier** to firstname-lastname-inventory-db.  Set the **Master username** to **master**, and the **Master password** and **Confirm password** to **lab-password**

4. In the **DB instance size** section, set the **DB instance class** to **Burstable classes**, and the dropdown to **db.t2.micro**

5. In the **Connectivity** section, set the **Virtual Private Cloud (VPC)** dropdown to be the VPC you created earlier (firstname-lastname-vpc), then click on the **Additional connectivity configuration**, and for **Subnet group** select the one you created (firstname-lastname-subnet-group), set **Publicly accessible** to **No**, leave **VPC security group** set to **Choose existing**.  click on the **default X** button to remove that and select the db security group you created (firstname-lastname-db-sg)

6. Click on the **Additional configuration** section to open it, and for **Initial database name** set it to **inventory**, then click the **Create databse** button at the bottom

## Task 7: Create an App Server
In this task you will create a IAM role and then use that IAM role as the Instance profile when creating an EC2 instance that will be the App Server

1.  In **Services->IAM**, in the left-hand menu select **Policies**, then click **Create policy**

2.  Switch to the JSON tab and copy and paste the following JSON into the editor adn then click **Review policy**

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ssm:*",
            "Resource": "arn:aws:ssm:*:*:parameter/inventory-app/*",
            "Effect": "Allow"
        }
    ]
}
```

This policy allows reading/writing into the Systems Manager Paramter store (which the code that will run on our App Server requires)

3. For the **Name** use **firstname-lastname-inventory-policy**, then click **Create policy**

4. Next, click on **Roles** in the left-hand menu, then click **Create role**

5. Leave the **Select type of trusted entity** to **AWS Service** and click on **EC2** in the **Choose the service that will use this role** section, then click **Next:Permissions**

6. In the search bar enter the policy you had created earlier (firstname-lastname-policy), it should appear in the list below, select the checkbox to the left of it and click **Next:Tags** and then click **Next:Review**

7. For **Role name** put firstname-lastname-inventory-role and click **Create role**

8. In **Services->EC2**, click **Launch instance**, and click **Select** to the right of the AMI at the top of the list (Amazon Linux 2 AMI (HVM), SSD Volume Type)

9. Leave instance as-is (t2.micro) and click **Next:Configure Instance Details**, set **Network** to your created vpc (firstname-lastname-vpc) and set the **Subnet** to your public subnet (firstname-lastname-public), set **Auto-assign Public IP** to **Enable**, set **IAM role** to the role you created above (firstname-lastname-inventory-role)

10. Scroll down and click on the **Advanced Details** section to open it, then paste the following script text into the **User data** editor pane

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

This script will run at instance start-up, it will install a mysql client, php, and an apache web-server, it will then download and install some php code for an application and the AWS SDK for php and will start the apache web server

11. Click **Next:Add Storage** and then click **Next:Add Tags**, click **Add Tag** and set **Key** to **Name** and **Value** to firstname-lastname-app-server, then click **Next:Configure Security Group**

12. Click **Select an existing security group** and click the checkbox to the left of your app server security group (firstname-lastname-app-sg), then click **Review and launch**,  click **Continue** in the warning dialog, then click **Launch**

13. In the dialog in the top dropdown, select **Proceed without a keypair**, click on the acknolwedgement checkbox, and click **Launch Instances**, then click **View Instances**

## Task 8: Test the application
In this task you will verify that the web application is working correctly

1. In the Instances page click on the checkbox to the left of your app server instance (firstname-lastname-app-server), scroll down to the bottom panel and copy the **IPv4 Public IP** and open a new browser tab with URL set to that IP address

2. You should see a web-app open in the browser tab and you should see a **Settings** button, click on it

3. In the form, put **inventory** for the **Database**, **master** for the **Username**, and **lab-password** for the **Password**

4. In the browser tab with your AWS management console, click on **Services->RDS** and then **Databases** in the left-hand menu

5. Click on the the database you had created (firstname-lastname-inventory-db), you should click on the name itself, not the radio button to the left.  

6. Look for the **Endpoint** in the **Connectivity & security** section and copy it

7. Return to the browser tab open to your web application and paste the endpoint into the **Endpoint** field and click **Save**.

You should now see a list of pre-created data, you can go ahead and delete that and create new entries (these will be created in the database from the app server web application).
