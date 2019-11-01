# Lab 1: Hosting a Static Website

Static websites or web-apps have fixed content. They can contain HTML pages, images, style sheets and javascript, and can interact with back-end services via REST API calls.  Single Page Apps (SPAs) created by frameworks such as React or Angular can be served in this way.

You can easily host a static website or web-app on Amazon S3 by uploading the desired content and making it publicly accessible. No servers are required and you can use Amazon S3 to store and retrieve any amount of data at any time, from anywhere on the web.

## Task 1: Create a bucket in Amazon S3
In this task, you will create an Amazon S3 bucket and configure it for static website hosting.

1. In the **AWS Management Console** on the **Services** menu, select **S3**, then click the **Create Bucket** button

2. For the bucket name use firstname-lastname-bucket (replace firstname and lastname with your first name and last name).  Bucket names must be globally unique

3. Click the **Next** button, under **Tags** enter a tag with key set to **Department** and value set to **Marketing**, then click **Next** again

4. Public access for buckets is disabled by default, however for websites the files will need to be public.  Deselect all of the options and then click **Next** and then click the **Create bucket** button

5. Click on the new bucket then click on the **Properties** tab, and click **Static website hosting**

6. Click on the **Endpoint** link, you should receive a **404 Not Found** error because we haven't placed any files in the bucket yet.  Leave the tab open in your web-browser as we will return to it later

7. Return to the tab that has the **AWS Management Console**, and click the **Use this bucket to host a website** radio button

8. For **Index document** enter **index.html** (you will need to enter this even though it is already displayed)

9. Click the **Save** button

## Task 2: Upload Content to your Bucket
In this task, you will upload the static files to your bucket.

1. In the **S3 Management console** click the **Overview** tab

2. Click the **Upload** button and then the **Add files** button and select the 3 other files in this lab folder (index.html, script.js, style.css) and then click **Upload**

## Task 3: Upload Content to your Bucket
Objects stored in Amazon S3 are private by default. This ensures that your organization's data remains secure. In this task, you will make the uploaded objects publicly accessible.

1. Return to the browser tab that was opened earlier with the **404 Not Found** error and refresh the page.  You should now see a **403 Forbidden** error message.  This is because the files in the bucket are still set to private access (the default).

There are several ways to make Amazon S3 objects public:
- A **Bucket Policy**  can be used to make a whole bucket public, or just a directory within a bucket.
- An **Access Control List (ACL)** can be used to make individual objects public.

It is normally safer to make individual objects public, as this avoids other files in the bucket accidentally being made public, however if you know that all the files in the bucket should always be public then you can safely set the entire bucket public via a **Bucket Policy**

2. Return to the browser tab with the **S3 Management console** and select the checkbox next to all 3 files

3. Click the **Actions** menu and select **Make public** then click the **Make public** button

4. Return to the broswer tab that had the **403 Forbidden** error and refresh the page.  You should now see the website corresponding to the 3 files.

## Task 4: Update the Website
You can make changes to the website by editing the HTML file and uploading it again to the Amazon S3 bucket.

1. On your computer, open the index.html file (in this lab folder) in a text or code editor.  You could use Notepad (Windows) or TextEdit (Mac) or any other tool

2. Find the text **Served from Amazon S3** and replace it with **Created by firstname lastname** (replace firstname and lastname with your own first name and last name)

3. Save the file and then return to the **S3 Management console** tab and upload the modified file to the bucket

4. Click the checkbox next to the index.html file and then the **Actions** menu and make the file public again

5. Return to the browser tab with the website and refresh the page and you should see it updated to show the modified text