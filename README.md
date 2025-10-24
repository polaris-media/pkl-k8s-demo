# How Polaris Media Teknologi uses Pkl to generate kubernetes manifests
We use [Pkl](https://pkl-lang.org/main/current/introduction/index.html)to generate Kubernetes manifests for our applications.
Our setup enables developers to focus on writing code instead of indenting YAML files correctly.
This repository contains examples of how we use Pkl to generate manifests for our applications.

## Prerequisites:
- Install Pkl by following the instructions at https://pkl-lang.org/main/current/tools.html


## How it works
At the root of the `src` folder are four files that define shared configuration for all applications.
- `TeamAppEnv.pkl`: Defines the template for the configuration for each application, including team, application name, environment, and pull request ID. This is based on the file structure in the `src` folder.
- `vars.pkl`: Defines common variables to simplify the configuration of each application.
- `defaults.pkl`: Defines the default configuration for all applications, including resource limits, replica counts, and common labels.
- `overrides.pkl`: Initiates the most common resources for the app and uses the default values. Each team amends this file and overrides the necessary values.

Each team has a dedicated directory at `src/TEAM_NAME` for its applications.
Which is organized as `src/TEAM_NAME/APP_NAME/ENV_NAME/PR_ID`.
Each folder can contain a `override.pkl` file that overrides the default configuration for that specific team, application, environment, or pull request.

## How does a team add a new application?
When the team wants to add a new application, they can create a new folder under their team folder and add the necessary pkl files. (Or run the script [create_new_app.sh](create_new_app.sh)).
A GitHub workflow will pick up the PR with the new application and generate the initial manifests for the application.
When the PR is merged, the manifests will be deployed to the cluster using ArgoCD.


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

