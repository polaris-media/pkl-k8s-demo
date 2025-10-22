#!/usr/bin/env bash

environments=("acc")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

function usage {
    echo
    echo "This script creates a new app which runs in kubernetes"
    echo "You will be prompted for a team name (eg. polarx, abo, inno etc. ) and an app name"
    echo "This creates the app in src/<team_name>/<app_name> and will contain the following environment: ${environments[*]}"
    echo
    echo "However you can do more complex behaviour out of the box with flags"
    echo "if you miss functionality out of the box, they can be added as flags to this script"
    echo
    echo "$0 usage:" && grep "[[:space:]].)\ #" $0 | sed 's/#//' | sed -r 's/([a-z])\)/-\1/';
    echo
}

while getopts "e:h" opt; do
  case $opt in
    e) # Add dditional environments. For multiple split the argument by spaces, example: "prod pr"
        IFS=' ' read -r -a extra_envs <<< "$OPTARG"
        environments+=("${extra_envs[@]}")
        ;;
    h) # halp
        usage
        exit 0
        ;;
  esac
done

echo -e "\nCreating new app, you will be prompted"
echo -e "For usage, help and advanced usage: $0 -h" 

# Get team name from user until input is valid, it should only contain lowercase letters, numbers and dashes
while read -p "Enter team name: " team_name; do
  if [[ $team_name =~ [^a-z0-9-] ]]; then
    echo -e "\n${RED}Team name should only contain lowercase letters, numbers and dashes${NC}"
  else
    break
  fi
done

# Get app name from user until input is valid, it should also check if the folder already exists
while read -p "Enter app name: " app_name; do
  if [[ $app_name =~ [^a-z0-9-] ]]; then
    echo -e "\n${RED}App name should only contain lowercase letters, numbers and dashes${NC}"
    continue
  fi
  
  matches=$(find src/ -maxdepth 2 -type d -name "$app_name")
    if [[ -n "$matches" ]]; then
      echo "App '$app_name' already exists at: $matches"
      echo -e "${YELLOW}Please choose a different app name, using the same app name as a different team is not allowed as it will destroy routing${NC}"
      continue
  else
    break
  fi
done

#Create new app
mkdir -p src/"$team_name"/"$app_name"

#Interate over environments and create the necessary directories
for env in "${environments[@]}"
do
  mkdir -p src/"$team_name"/"$app_name"/"$env"
done



#Create override for app
  cat <<EOF > src/$team_name/$app_name/overrides.pkl
amends "..."

// Overrides for the application, file is optional


EOF


#Create files for each environment

for env in "${environments[@]}"
do
  cat <<EOF > src/$team_name/$app_name/$env/overrides.pkl
amends "..."

// Overrides for the environment

images {
  [module.app] {
    image = "polarisit/$app_name:v1.0.0"
  }
}

EOF

done

echo -e "\nApp $app_name created for team $team_name in folders src/$team_name/$app_name"
echo -e "\nDeveloper level is now over 9000"
echo -e "glhf!"

