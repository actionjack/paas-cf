# Pingdom checks

## Setting up the checks

The checks are defined in terraform configuration file `terraform/pingdom/pingdom.tf`.

The IDs of the contacts to be notified are stored as a comma-delimited string in variable `$PINGDOM_CONTACT_IDS` in the Makefile.

### Requirements

* [Terraform](https://www.terraform.io/downloads.html) must be installed. We currently support version `0.6.*`
* Make sure you have access to the PaaS credential store, this is required for Pingdom credentials.
* Load the AWS credentials for the environment you are setting up checks for. These are required as the Terraform state file for the Pingdom checks is stored in an S3 bucket.

### Usage
Run `make <ENV> pingdom` to set up the Pingdom checks.


## Build from source

#### Requirements
You must have a [golang environment](https://golang.org/doc/install) configured. We currently test with Go 1.6.
 
#### Download
Download the provider and its dependencies:

```
go get github.com/russellcardullo/terraform-provider-pingdom
```

#### Custom provider
For bleeding-edge features, it may be necessary to build the provider from our fork.

```
# go-pingdom library
cd $GOPATH/src/github.com/russellcardullo/go-pingdom
git remote add alphagov https://github.com/russellcardullo/go-pingdom.git

# terraform-provider-pingdom
cd $GOPATH/src/github.com/russellcardullo/terraform-provider-pingdom
git remote add alphagov https://github.com/russellcardullo/terraform-provider-pingdom.git
```

#### Terraform version
You may need to ensure your Terraform version is compatible with the terraform library used to compile the provider. You can run `terraform -v` to get your version of Terraform and find the corresponding git tag for this version in `$GOPATH/src/github.com/hashicorp/terraform`. Use the tag to checkout that version of the terraform library prior to installing the provider.

#### Install
Run `go install github.com/russellcardullo/terraform-provider-pingdom`. This will build and install the binary in `$GOPATH/bin`. Make sure `$GOPATH/bin` is in your `$PATH`.

Add the content of `terraform/providers/terraformrc` to `$HOME/.terraformrc`.

The binary should now be installed and Terraform knows where to find it.

## Publishing the custom provider
Build from inside directory `$GOPATH/src/github.com/russellcardullo/terraform-provider-pingdom`.

### Build for Linux

```
GOOS=linux GOARCH=amd64 go build -v -o terraform-provider-pingdom-Linux-x86_64
```

### Build for MacOS
```
GOOS=darwin GOARCH=amd64 go build -v -o terraform-provider-pingdom-Darwin-x86_64
```

### Publish
The binary is published as a release in our [paas-terraform-provider-pingdom repository](https://github.com/alphagov/paas-terraform-provider-pingdom/releases). When code is merged into the `gds_master` branch, tag the merge commit and upload the binaries as a GitHub release.