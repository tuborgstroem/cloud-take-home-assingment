# DR Cloud Engineer Take Home Assignment

The assignment is split into three sections. You'll be asked to solve a bug, build a feature, and answer written questions. For each section, please share your thinking and document your changes, including any additional instructions on how to run and test your solution.

We expect your solution to be version-controlled and appreciate a clean commit history. Documentation can be added to the existing README as you progress.

We've started you off with a simple containerized application and kubernetes manifest. Follow the setup below to get it running on your machine.

## Setup

### Requirements

- bash
- [git](https://git-scm.com/downloads)
- [docker](https://docs.docker.com/engine/install/), ~> 25.0.3
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl), Client Version: ~> 1.29.1 
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation), ~> 0.22.0

You are welcome to use other versions of the above tools. Document these changes if it affects how we run your solution. 

### Development

Initialize this project as a Git repository, create a private repository in GitHub, and push your assignment there. We'll instruct you via email who to add to the assignment when you're ready to submit.

To initialize your local environment, you can use the `setup.sh` script:

```
Usage: setup.sh [command]

Commands:
  bootstrap  Create a local kind cluster, build the Docker image, load the image into the cluster, and deploy the contents of /k8s.
```

This will create a local `kind` cluster, build the docker image, load the image into the cluster, and deploy the contents of `/k8s`.

## Solve a Bug

The initial deployment of the application should be failing. Your goal is to get this application deployed successfully
in whatever way you think is best. Document the issue you find and how you solved it.

## Build a Feature

The api URL our app uses is hardcoded in the application code. Your goal is to decouple this detail from the application in the way you think is best. Please document your thinking and solution.

Additionally, we'd love to see you update the existing project to better align with best Kubernetes best practices. Make any change you think would improve this project and document the changes you introduce.

## Questions & Answers

1. What else should we think about when making the application production-ready?

2. What resources could we introduce to enable another application to speak with this one? What if we wanted to reach it outside of the cluster?

3. How can we secure communication between applications within the cluster?

4. In an ideal world, how would a deployment pipeline look for this application?

5. We'd love your feedback. What did you think of the assignment?