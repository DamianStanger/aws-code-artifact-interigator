#! /bin/bash

rm -f aws_code_artifact.txt
rm -f aws_code_artifact_eg1.txt
rm -f aws_code_artifact_eg2.txt
rm -f wrong_latest.txt
rm -f all_versions.txt

domain=$1
domain_owner=$2

aws codeartifact list-packages --domain $domain --domain-owner $domain_owner --repository npm-private --profile saml >> aws_code_artifact.txt

grep -A 1 -Pe '"namespace": "eg",' aws_code_artifact.txt >> aws_code_artifact_eg1.txt
sed -i -E '/.*("namespace"|--).*/d' aws_code_artifact_eg1.txt
sed -i -E 's/.*": "//' aws_code_artifact_eg1.txt
sed -i -E 's/"//' aws_code_artifact_eg1.txt
# sed -i -E 's|^|@eg/|' aws_code_artifact_eg1.txt

grep -Pe '"(eg|@eg)[^"]+"' aws_code_artifact.txt >> aws_code_artifact_eg2.txt
sed -i -E 's/.*": "//' aws_code_artifact_eg2.txt
sed -i -E 's/"//' aws_code_artifact_eg2.txt


cat aws_code_artifact_eg1.txt | while read line
do
  echo "@eg/$line"
  rm -f package_versions.txt
  rm -f this_versions.txt
  aws codeartifact list-package-versions --package "$line" --namespace eg --format npm --domain $domain --domain-owner $domain_owner --repository npm-private --profile saml >> package_versions.txt
  latest1=$(grep -oPe '"defaultDisplayVersion": "([0-9\.]+)",' package_versions.txt)
  latest1=$(echo "$latest1" | grep -oPe "[0-9\.]+")

  grep -Pe '"version": "([0-9\.]+)",' package_versions.txt | grep -oPe "[0-9\.]+" >> this_versions.txt

  latest2=$(cat this_versions.txt | sort -V | tail -n 1)

  if [ "$latest1" = "$latest2" ]; then
    echo "@eg/$line:$latest1 == $latest2" >> all_versions.txt
  else
    echo "@eg/$line:$latest1 != $latest2   -------------   :-("
    echo "@eg/$line:$latest1 != $latest2   -------------   :-(" >> all_versions.txt
  fi

  cat this_versions.txt | xargs echo "@eg/$line" >> all_versions.txt
done


cat aws_code_artifact_eg2.txt | while read line
do
  echo $line
  rm -f package_versions.txt
  rm -f this_versions.txt
  aws codeartifact list-package-versions --package "$line" --format npm --domain $domain --domain-owner $domain_owner --repository npm-private --profile saml >> package_versions.txt
  latest1=$(grep -oPe '"defaultDisplayVersion": "([0-9\.]+)",' package_versions.txt)
  latest1=$(echo "$latest1" | grep -oPe "[0-9\.]+")

  grep -Pe '"version": "([0-9\.]+)",' package_versions.txt | grep -oPe "[0-9\.]+" >> this_versions.txt

  latest2=$(cat this_versions.txt | sort -V | tail -n 1)

  if [ "$latest1" = "$latest2" ]; then
    echo "$line:$latest1 == $latest2" >> all_versions.txt
  else
    echo "$line:$latest1 != $latest2   -------------   :-("
    echo "$line:$latest1 != $latest2   -------------   :-(" >> all_versions.txt
  fi

  cat this_versions.txt | xargs echo "$line" >> all_versions.txt
done
