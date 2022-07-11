#!/bin/bash
kubeval --strict --schema-location https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master wordpress/*.yaml
if [ $? -eq 0 ]; then
 echo "The manifests syntax is correct"
else
 echo "Need to check  the manifests syntax"
 exit 1
fi