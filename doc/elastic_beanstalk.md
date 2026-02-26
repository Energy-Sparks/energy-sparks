# Elastic Beanstalk

Energy Sparks runs on Elastic Beanstalk.

# Platform Version Upgrades

This can be achieved by the AWS environment page using the "Change version" button.  Elastic Beanstalk will create a
second instance, build the app and then remove the old instance.

# Platform Upgrade (major ruby version upgrade)

The "Clone Environment" option from the Actions drop box on the environment page is usually the easiest way to achieve
this if available.  This creates a new environment so DNS needs to be updated to actually switch over.

# Changing architecture

As of Jan 2026 this was not easily possible via the web interface but works via the CLI in a similar way to the version
upgrade:

`aws elasticbeanstalk update-environment --environment-id <YOUR_ENV_ID> --option-settings Namespace=aws:ec2:instances,OptionName=InstanceTypes,Value=t4g.medium`
