# **Prerequisites**

1. AWS CLI: Installed and configured with access keys.
2. Terraform: Installed and initialized.
3. Node.js: Installed for Lambda function development.

# **Setup Instructions**

1. Clone this repository:

```bash
git clone <repository-url>
```

2. Install Dependencies: Navigate to the src/ directory and install Node.js dependencies:

```bash
cd src
npm install
```

3. Zip the Lambda Function, along with the dependencies (_node_modules/_), while on **_/src_** folder:

```bash
zip -r ../lambda_function.zip .
```

4. Deploy with Terraform:

```bash
cd ../terraform
terraform init
terraform plan ## To catch any errors before "apply"
terraform apply
```

5. Upload JSON File at your S3 bucket that was created with terraform to Test:

```json
{
  "numbers": [1, 2, 3, 4, 5]
}
```

# Clean-Up

To destroy all resources created by Terraform, run:

```bash
terraform destroy
```

# Now Step By Step And "What I learned"

First of all this is a Local Backend and not a Remote Backend which would need more configuration and would have been more challenging ofc.

The heart of a terraform project is the `main.tf` file. You declare / state there what you want, and not how you want, the "how" is smthing terraform will have to figure out.

So in this project these were the steps:

1. choose provider and region
2. declare that you want to create an S3 bucket
3. Create the indetity and Access Management (IAM) role with :

```ruby
  "Action": "sts:AssumeRole",
  "Principal": {
    "Service": "lambda.amazonaws.com"
  },
```

which will give temporary credentials with **Security Token Service(sts)** to the **lambda** service and policies for your Lambda_function so it can have access to the S3 bucket's files and also to create logs to the CloudWatch

4. Now connect | link | attach the policy to the role just created
5. Define the lambda_function
6. Add permission for the S3 to invoke the Lambda_function
7. Define when the invoke will trigger (`events = ["s3:ObjectCreated:*"]`)

# Resources | Links | Tools

- [DevOps Directive](https://www.youtube.com/watch?v=7xngnjfIlK4&ab_channel=DevOpsDirective)
- [Codeium VSC Extension](https://codeium.com/)
- [ChatGPT 4o](https://www.chatgpt.com)
- [Syntax Guide](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
