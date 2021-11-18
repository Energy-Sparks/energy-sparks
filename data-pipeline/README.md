# Energy Sparks data pipeline

Data can be imported into Energy Sparks via files sent to specific email
addresses. Attached files will be unzipped where required and added to
an AMR data bucket prefixed by the local part of the email address they
were sent to.

## For developers

The pipleline works by adding emails received using Amazon's SES to a
specified bucket. An AWS lambda function is triggered by the addition of
the file to the bucket which then processes the file and moves it onto
another bucket which in turn triggers more lambdas where required.

The setup of the buckets, lambdas and associated permissions is managed
by the [serverless](https://serverless.com/) framework which creates and
updates a CloudFormation stack on AWS.

Serverless allows us to set a 'stage' and run multiple environments
(e.g. test, production).

Serverless automatically creates the S3 buckets that are directly attached to lambda
functions in the `functions:` definitions. S3 buckets that are not
directly attached to lambda functions are specified in the `resources:`
section along with an S3 policy that allows SES to add to the `inbox` bucket.


The following instructions assume you are working from the
`data-pipeline` directory. Note, the region is set manually in the
serverless.yml file so deploying to different regions would require a
change to the configuration.

### Installation and configuration

Install serverless using homebrew (`brew install serverless`) or using
[npm](https://serverless.com/framework/docs/getting-started/). The
serverless AWS credentials should be in a profile called `serverless` in
your `~/.aws/credentials` file:

```
[serverless]
aws_access_key_id = YOURKEYHERE123
aws_secret_access_key = YOURSECRETHERE123
```

The functions log some errors in Rollbar. You need to add the following files:

```
.env.development
.env.test
.env.production
```

In each one add a `ROLLBAR_ACCESS_TOKEN` environment variable with the right token.
These should be the same as the live environment.

Run `bundle install` to install the required gems.

### Testing

Run `bundle exec rspec spec` to run the test suite. The tests stub calls
to the S3 service to monitor requests made and to fake responses.

### Deployment

Run `rake deploy:ENVIRONMENT` to deploy the pipeline to AWS. e.g. `rake
deploy:development`. Running `sls deploy` manually will deploy the
`development` stage by default but will skip the bundler tasks from the
rake tasks.

### Adding a new school area

The email rule for SES is a catch-all and will use the local part of the
email address to prefix the S3 object key. e.g. a file called
`import.csv` sent to `sheffield@test.com` will have the S3 key
`sheffield/import.csv`. Changes will need to be made to the main
application to process files from previously unseen prefixes.

### Adding a stage
To start receiving emails to a new stage a new SES rule will have to be
added to move the email to the `es-STAGE-data-pipeline-inbox` bucket.

### File expiry
File expiry is managed manually through the S3 web interface and will
need setting up for new buckets.


### Monitoring

Logs and usage stats found via the `Monitoring` tab on the individual
lambda AWS page.
