# aws-ptfe-perf-testing

Quick Terraform code to do some basic back-of-the-envelope perf testing

## Steps

* Setup your AWS credentials in a profile

```
cat ~/.aws/credentials
[acme]
aws_access_key_id = AKI232fdfQG3JL5DPGQ
aws_secret_access_key = 2SijAagsdfgsdfgsazzd2fn4zp/54
export AWS_PROFILE=acme
```

* Plan

```
terraform plan
```

* Apply

```
terraform apply
```

* SSH using the key and the output of the IP address:

```
ssh ubuntu@$(terraform output ptfe_instance_ip) -i ./keys/aws-ptfe-keypair.pem
```

* Install PTFE

```
curl -o install.sh https://install.terraform.io/ptfe/stable
```

* Install Certbot for LetsEncrypt certs

```
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install certbot
$ sudo certbot certonly
```

* Give the PTFE install privkey.pem and fullchain.pem in the cert configuration

* Create an API Token (https://www.terraform.io/docs/enterprise/users-teams-organizations/users.html#api-tokens)

* Add it to your Terraform configuration (https://www.terraform.io/docs/enterprise/registry/using.html#configuration)

* cd into `tfe-terraform-setup/` and run Terraform plan (Note: Run with Parralelism set lower if you experience 500 errors)

* Get 500 workspaces tied to my petems/arbitary-terraform-code repo

* Do what you want to see if your system can handle your required similtanious runs and workspace sizes
