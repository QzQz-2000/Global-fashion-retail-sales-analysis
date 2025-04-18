# Terraform setup

1. Navigate to the `terraform` folder.

2. Open `variables.tf` and edit the variable `region` block so that it matches your preferred region. And edit the variable `project` block to your own project id.

3. Initiate Terraform and download the required dependencies:

   ```bash
   terraform init
   ```

4. View the Terraform plan and make sure that you are creating the following resources

   ```bash
   terraform plan
   ```

   - a Google Cloud Storage bucket
     - We have implemented some lifecycle controls for the bucket. If any object in the bucket has existed for more than one day and is an incomplete multipart upload, Google Cloud will automatically abort these unfinished uploads to prevent unnecessary storage usage.

   - a BigQuery dataset

5. If the plan details are as expected, apply the changes:

   ```bash
   terraform apply
   ```

6. Once you are done with the Project, tear down the infra useing:

   ```bash
   terraform destroy
   ```

You should now have a bucket called `fashion_sales_storage_bucket` in GCS and a dataset called `fashion_sales_dataset` in BigQuery. 

