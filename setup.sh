#!/bin/bash

# install pip3, python3, wget
sudo yum update
sudo yum install python3
sudo yum install python3-pip
sudo yum install wget


git clone https://github.com/mmdcloud/aws-kinesis-to-s3/

# Unzip the files
cd aws-kinesis-to-s3

# Install the required libraries
pip3 install -r requirements.txt

# Execute the Python script
sudo chmod +x data_streams.py
python3 data_streams.py --stream_name kinesis_stream --interval 2 --max_rows 60