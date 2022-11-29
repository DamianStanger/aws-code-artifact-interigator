# Summary

This script will use the aws code artifact cli https://docs.aws.amazon.com/cli/latest/reference/codeartifact/index.html#cli-aws-codeartifact

To return all npm packages from a given domain, that is starting with a domain or contained in a scope with the domains name

# usage
./aws_code_artifact.sh namespace aws_account

## example
./aws_code_artifact.sh myorg 123456789012

Would return:
```
@myorg/foobar1
@myorg/foobar2
myorg-foobar3
myorg-foobar4
```

This will output to a file named all_versions.txt and all_package_versions.txt

Other files are kept around so that you can debug your process a little :-)

# Auth
To use this script as is you will need to have used saml2aws https://github.com/Versent/saml2aws
and have logged in to aws code artifact:

`aws codeartifact login --tool npm --domain myorg --domain-owner 123456789012 --repository npm-private --endpoint-url https://vpce-1234567890-1234567890.api.codeartifact.eu-west-1.vpce.amazonaws.com --region eu-west-1 --profile saml`
