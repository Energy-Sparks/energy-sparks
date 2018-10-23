#!/bin/bash
echo `date -u` "Getting any files"

cd amr_files_bucket

echo "connecting to: $BANES_SFTP_SERVER as $BANES_SFTP_USER"

# Get and then delete files
lftp sftp://$BANES_SFTP_USER:$BANES_SFTP_PASSWORD@$BANES_SFTP_SERVER:22 <<EOF
set xfer:log 1
set xfer:log-file ../log/lftp.log
get 30days.zip
get 30days.csv
EOF

shopt -s nullglob dotglob     # To include hidden files
files=(./*)
if [ ${#files[@]} -gt 0 ]
then
  echo `date -u` "Got files"
  if [ -e 30days.zip ]
  then
    echo `date -u` "Got a zip file, unzip it"
    unzip 30days.zip
  fi

  if [ "$(uname)" == "Darwin" ]
  then
    filename=30days-$(date -v-1d +%d-%m-%Y).csv
  else
    filename=30days-$(date -d yesterday +%d-%m-%Y).csv
  fi

  mv 30days.csv $filename
  aws s3 cp $filename s3://$AWS_S3_AMR_DATA_FEEDS_BUCKET/banes/
else
  echo `date -u` "No files"
fi
