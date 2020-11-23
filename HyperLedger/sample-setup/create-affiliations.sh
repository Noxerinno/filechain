#!/bin/bash
#SPDX-License-Identifier: Apache-2.0
#Author: kehm

#Create affiliations in the Fabric CAs

set -e
echo "Adding affiliations to the CAs:Start"
fabric-ca-client enroll -u http://admin:adminpw@localhost:7054
fabric-ca-client affiliation add hospital1
fabric-ca-client affiliation add hospital1.surgery
fabric-ca-client affiliation add hospital1.lab
fabric-ca-client affiliation add pharmacy1
fabric-ca-client affiliation add pharmacy1.sales
fabric-ca-client affiliation add pharmacy1.purchase
fabric-ca-client affiliation add practitioner1
fabric-ca-client affiliation add practitioner1.practitioner
fabric-ca-client affiliation add practitioner1.office
echo "Adding affiliations to the CAs:Done"
