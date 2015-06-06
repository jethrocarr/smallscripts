# CFN Templates

These are example Cloudformation Templates that can be used to build resources
in Amazon AWS.


# cfn_yas3fs_example.template

Sets up an S3 bucket, SNS topic and IAM user with suitable permissions to
provide complete configuration for the Yas3fs filesystem.

See https://github.com/danilop/yas3fs for more details about Yas3fs.

Generally create the stack in the usual fashion, however you will want an
alphanumeric-only S3 bucket name, otherwise the auto-generated SQS IAM perms
will not work right with Yas3fs, which strips any dashes.

    aws cloudformation create-stack \
      --capabilities CAPABILITY_IAM \
      --template-body file://cfn_yas3fs_example.template \
      --stack-name yas3fs-example \
      --parameters ParameterKey=S3BucketName,ParameterValue=yas3fsexample

You can fetch the outputs of a running stack (inc IAM credentials) with:

    aws cloudformation describe-stacks \
      --stack-name yas3fs-example \
      --query "Stacks[*].Outputs[*]"


# Debugging

You can check a stack for syntax correctness with:

    aws cloudformation validate-template --template-body file://


