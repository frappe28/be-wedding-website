# Admin Delete User function
Given an email, this function queries a Cognito user pool by email to retrieve the user's accounts and, if there are any, it deletes each one of them.

## Production dependencies
This function doesn't have any production dependencies.

## Lambda layers
This function uses the following lambda layers:

  * `aws-sdk`: used to work with the AWS services
  * `@aws-lambda-powertools/logger`: used for function logs

## Possible improvements
Since this function sends requests only to the Cognito service, the `aws-sdk`, which is a heavy package, may be replaced with the `@aws-sdk/client-cognito-identity-provider` package. This improvement would require the developer to update the source code and the dependencies/layers.

## Problems
No problems have been found so far.