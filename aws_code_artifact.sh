#! /bin/bash

rm -f aws_code_artifact.txt
rm -f aws_code_artifact_1.txt
rm -f aws_code_artifact_2.txt
rm -f package_versions.txt
rm -f this_versions.txt
rm -f all_versions.txt

domain=$1
domain_owner=$2

aws codeartifact list-packages --domain $domain --domain-owner $domain_owner --repository npm-private --profile saml >> aws_code_artifact.txt

grep -A 1 -Pe "\"namespace\": \"$domain\"," aws_code_artifact.txt >> aws_code_artifact_1.txt
sed -i -E '/.*("namespace"|--).*/d' aws_code_artifact_1.txt
sed -i -E 's/.*": "//' aws_code_artifact_1.txt
sed -i -E 's/"//' aws_code_artifact_1.txt

grep -Pe "\"($domain|@$domain)[^\"]+\"" aws_code_artifact.txt >> aws_code_artifact_2.txt
sed -i -E 's/.*": "//' aws_code_artifact_2.txt
sed -i -E 's/"//' aws_code_artifact_2.txt

exit 0

cat aws_code_artifact_1.txt | while read line
do
  echo "@$domain/$line"
  rm -f package_versions.txt
  rm -f this_versions.txt
  aws codeartifact list-package-versions --package "$line" --namespace $domain --format npm --domain $domain --domain-owner $domain_owner --repository npm-private --profile saml >> package_versions.txt
  latest1=$(grep -oPe '"defaultDisplayVersion": "([0-9\.]+)",' package_versions.txt)
  latest1=$(echo "$latest1" | grep -oPe "[0-9\.]+")

  grep -Pe '"version": "([0-9\.]+)",' package_versions.txt | grep -oPe "[0-9\.]+" >> this_versions.txt

  latest2=$(cat this_versions.txt | sort -V | tail -n 1)

  if [ "$latest1" = "$latest2" ]; then
    echo "@$domain/$line:$latest1 == $latest2" >> all_versions.txt
  else
    echo "@$domain/$line:$latest1 != $latest2   -------------   :-("
    echo "@$domain/$line:$latest1 != $latest2   -------------   :-(" >> all_versions.txt
  fi

  cat this_versions.txt | xargs echo "@$domain/$line" >> all_versions.txt
done


cat aws_code_artifact_2.txt | while read line
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
