
# Cloud take home assignment.
## Author: Tobias Borgstrøm

## Solve a bug.
Diagnosis what goes wrong?

`$ kubectl get pods
NAME                             READY   STATUS                       RESTARTS   AGE
cat-facts-app-5fc888646c-5m6zh   0/1     CreateContainerConfigError   0          9m33s`

```
$kubectl describe pod cat-facts-app-5fc888646c-5m6zh
{...}
Events:
Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
Normal   Scheduled  27m                  default-scheduler  Successfully assigned default/cat-facts-app-5fc888646c-5m6zh to drdk-cloud-assignment-control-plane
Warning  Failed     25m (x12 over 27m)   kubelet            Error: container has runAsNonRoot and image will run as root (pod: "cat-facts-app-5fc888646c-5m6zh_default(a34cc5d4-023d-42a0-8f60-9873719c6fe8)", container: app)    
Normal   Pulled     86s (x117 over 27m)  kubelet            Container image "cat-app:v1" already present on machine
```
This shows that an error occurs because "container has runAsNonRoot and image will run as root" So either pod should not be run as non root or image should be set up to not run as root.

As the application doesn't require root privileges I modified the security context of the app and gave a non-root user id 1000. This removes root privileges from the app as it is not needed and will limit damage that can be done if an attacker gains access to container.

Now Kubernetes does not give root access to the app.
The Dockerfile does not specify user. So by default it would run as root user. By setting runAsUser: 1000 in k8s /deployment.yaml Kubernetes will override default behaviour and force container to run as UID 1000.

added following lines to Dockerfile

```
# Change ownership of /app to the 'node' user
RUN chown -R node:node /app

# Set the user to the existing 'node' user for the rest of the container lifecycle
USER node
```
_______________________________
Then i build docker container with
```
$ docker build -t cat-app:v1
```

and load the updated image to kind

`$ kind load docker-image cat-app:v1`

```
$ kubectl rollout restart deployment
deployment.apps/cat-facts-app restarted
```
And with 
```
$ kubectl get pods
NAME                             READY   STATUS        RESTARTS   AGE
cat-facts-app-6cdf655d65-htnrn   1/1     Terminating   0          48m
cat-facts-app-b6bb6cfc5-824cx    1/1     Running       0          8s
```
we can see that now bug has been fixed!

______________________________________________________________________________________________

## Build a Feature

The hardcoded URL should not be defined in the code. Environment variables makes more sense to use here as it externalizes the configuration and can be modified without changing source code.

I create a configmap to create variable cat-facts-config. In this i detail the necessary key-value pairs for the app config. this includes CAT_API_URL which uses the hardcoded url. Then i update deployment to include the new cat-facts-config with valuefrom CAT_API-URL.

This i then use in the code getting as process.env.CAT_API_URL;

Then I now try to portforward my service so i can use it with
$ kubectl port-forward pod/cat-facts-app-6fbd5b5df-lb687 8000:8000

when going to localhost:8000/random-cat-fact i get
{"error":"An error occurred while fetching the cat fact"}

i try to visit the url to find out it doesn't work...
Application error
An error occurred in the application and your page could not be served. If you are the application owner, check your logs for details. You can do this from the Heroku CLI with the command
heroku logs --tail

I replace the url with https://catfact.ninja/fact? as this also provides cat facts.
Now the hardcoded url has been made into an environment variable. And it works.

_____________________________________________________________________________
# Questions & Answers
## 1. What else should we think about when making the application production-ready?

We will need to setup testing and make them park of the CI/CD pipeline. So a unit test to ensure the service works as intended with a mock server. handling one or more mock responses to ensure that the layout doesn't cause errors in the service.
Other integration can be to verify that the external API works as intended so sending a request and verifying that the link works and having one or more links that can be contacted in the case that one does not work, and minimize disruptions.
We will need a deployment pipeline for our service so we can automate and don't have to build, deploy and test manually.

With the tests some parameters to use a metrics for raise incidents for when the service fails, and alerting eg. by sending a message in slack.

## 2. What resources could we introduce to enable another application to speak with this one? What if we wanted to reach it outside of the cluster?

We will also have to expose or endpoint for internat and explore external use.

for internal use Kubernetes can be used to define the service in other services in the cluster. So we can define the cat-facts-service name and kubernetes allows us to use is as a DNS entry, within the same namespace as http://cat-facts-service and other namespaces http://cat-facts-service.<namespace>.svc.cluster.local.

For external use we can set up an Ingress that provides HTTP and HTTPS routing to services in the cluster

```
{
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: cat-facts-ingress
annotations:
nginx.ingress.kubernetes.io/rewrite-target: /
spec:
rules:
- host: cat-facts.example.com
http:
paths:
- path: /
pathType: Prefix
backend:
service:
name: cat-facts-service
port:
number: 80
}
```

## 3. How can we secure communication between applications within the cluster?

We should set up Kubernetes network policies to restrict access to the server to choose which service should be able to access the cat-facts-service while blocking access from other services that should not be able to communicate
In the ingress we can enable TLS to encrypt traffic from external users and be compatible with Https so when going to the endpoint, search engines will not report the endpoint as not safe.

## 4. In an ideal world, how would a deployment pipeline look for this application?

First we need a build stage to compile the code. Here unit tests should be run and ensure that they pass, thus validating functionality.
This is also a place that can be used to scan Dependencies to check for vulnerabilities.

Then we will need to package the build. This include building the Docker container and creating the unique version tag.

Now we can run or integration tests. If these pass deploying the service to a test environment where we can do End-to-end testing to validate the service work with the other services in the system.

If all is working in test enviroment the service can be deployed to production environment.


## 5. We'd love your feedback. What did you think of the assignment?

I really liked the assingment. It was fun to setup a service and actually use kubernetes to complete the Assingment and being able to play around with Kubernetes overall a fun assingment.  





