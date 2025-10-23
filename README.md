# How Polaris Media Teknologi uses Pkl to generate kubernetes manifests
We use Pkl (https://pkl-lang.org/main/current/introduction/index.html) to generate Kubernetes manifests for our applications.
Pkl enables us to let the developers focus on writing code instead of indenting YAML files correctly.
This repository contains examples of how we use Pkl to generate manifests for our applications.

## Prerequisites:
- Install Pkl by following the instructions at https://pkl-lang.org/main/current/tools.html


## How it works
At the base of the src folder there are a couple of pkl files which make up the base setup for all of our applications.
Additionally, each team has their own folders under ```src/TEAM_NAME/APP_NAME/ENV_NAME/PR_ID``` where they can override everything from the base setup.
If a team wants to add a new application, they can just create a new folder under their team folder and add the necessary pkl files. (Or run the script [create_new_app.sh](create_new_app.sh)).
To deploy an app, you need to add a docker image tag to deploy the application.
Generate the manifests by [running generate_manifest.sh](generate_manifest.sh) and let your favorite Argocd instance pick up the changes.

## How does a team update their app version?
When a new version of an application is ready to be released in a specific environment, the team creates a pull request to update the version in the respective pkl file.
This can be done manually or by using the [update-app-version](.github/workflows/update_app_version.yml) workflow.
The workflow can be triggered from the Actions tab in GitHub or by using the following snippet in your own workflow file in your application repository:

```yaml
  update-app-version:
    uses: polaris-media/pkl-k8s-demo/.github/workflows/update_app_version.yml@main
    with:
      app_name: your-app-name
      environment: acc
      version: "v1.0.0"
      team: your-team-name
      dockerImage: "your-docker-image"
    secrets: inherit
```

