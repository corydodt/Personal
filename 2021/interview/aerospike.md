The purpose here is to identify the architecture and infrastructure components
of a typical web application like a REST API and hear the implementation
considerations.

## Typical web application

video game store sale notifications, a la dekudeals

#### Requirements

- The solution should be designed for high availability in AWS (ECS)
- Automatically scales to meet demand (ECS)
- Automatically replaces bad instances (ALB + application code)
- Encrypts all data in transit between the end-user and the REST endpoints (API Gateway endpoints)
- Exposes CRUD operations to a back-end database (RDS, postgres)
- Infrastructure is supported by a 24x7 operations team (AWS gold level support; + optional third party monitoring team?)
- The application instances should allow secure SSH access to application
  instances for troubleshooting as part of an access escalation request (ECS permits)

- The application code should be deployed as part of a CI/CD pipeline (github
  actions -> ECR)
- Cloud resources will be tagged to be used for reporting (tf tags on resources)
- Persists HTTP access logs for 90 days (cloudwatch log group)

#### Solutions discussion

- Tools: terraform, docker, AWS services

    - AWS offers an absurd number of overlapping services, and
      I haven't used all of them. A lot of what I'm going to say
      could be done with a different configuration of services;
      I'll note when something similar seems to exist but I haven't
      touched it myself.

- High-level: browser | API Gateway + Cognito | ALB | ECS service instance | RDS

- Open questions: how important is this app, actually? A large number of decisions
  here are truly informed by how much the organization is willing to invest in its
  longterm success. More robust solutions tend to trade higher initial
  investment cost for lower TCO.

- We will host our database in RDS. I'll choose their Postgres option; nobody
  ever got fired for choosing postgres.  (Also most databases are suitable for
  a wide variety of applications; without any other specific considerations,
  let's just use one of the most common and best-supported ones.)

  We can build RDS instances with terraform, even storing access passwords
  securely and making them available to our other components.

- First considered AWS Lambda + API Gateway. This approach covers almost all of
  these requirements: (1) high availability w/ 24x7 team, (2) autoscaling, (3)
  auto replacement, and (4) encrypted end user transport. It permits access to RDS.
  But it's effectively impossible to SSH into a Lambda runtime, so we have to
  discard this one.

    - Notes: In future projects, we should consider what we're trying to
      accomplish by requiring SSH, as it is possible to debug lambda functions
      locally, and they are required to be stateless so they tend to be
      simpler. (python-lambda-local)

    - Notes: Lambda also wouldn't be my pick if very low latency was required. There
      are techniques to reduce lambda's latency and keep instances hot but
      there's still a limit to how low latency they can be.

- We can still use API Gateway; mainly doing this for auth.

- We'll choose Amazon Cognito for user control, but there are big caveats here.

    - Cognito does not have robust user backup, a big problem.

    - Cognito is also not a good choice for headless services and command-line tools
      that need to remain logged-in, or need to log in with preshared secrets.

- We should also consider EKS: If we aren't choosing AWS lambda, then we would
  containerize our app anyway. K8s has a lot of complexity but in a
  sufficiently large/robust app it pays you back with reliability, modularity,
  and the ability to migrate the same solution to other platforms.

  - Notes: I am going to choose a different direction, mostly because my
    experience with EKS in production is limited so I won't have as much to say
    about it. In a scenario where I had more time to experiment and research,
    and assuming the workload was appropriate, I would strongly favor a
    K8s-based approach.

  - Also looked at AWS App Runner because I have some familiarity with Google Cloud
    Run, but AWS' version doesn't seem to cover all the bases.

  - The solution I am actually suggesting seems very similar to
    everything that Fargate offers, but I haven't personally
    used Fargate.

- We're going to use ECS, with an ALB pointing in to it:

    - autoscaling up and down
    - works from container registry so integrates well with CI/CD
    - ALB healthcheck will allow it to avoid bad instances

- Build the app with best practices WRT security (i.e. secure language choice
  like Python or Rust, pass parameters to a database with an API that quotes
  them).

    - Counterintuitively, ignore the auth/auth layer! In an API gateway
      setup we can build all access control outside of the app: Cognito and APIGW.
      The app should receive a token that contains all the user context it needs,
      already authenticated. Our app ends up both simpler and more secure this way,
      and it's easier to develop by maintainers, as well.

    - One app requirement: if the healthcheck URL isn't being hit for e.g. 90s,
      shut down. This allows us to prevent instances getting wedged during high demand.

    - ASGI

- Virtually all Terraform AWS resources have a simple way to tag. When you run tf,
  if you pass in things like code version or git tag, plus a region, the deployment
  can automatically tag resources appropriately using only tf syntax.

- Use a cloudwatch log group with a retention policy of 90 days. The app may
  write events to it manually through the API.

- CI/CD: github actions for test automation. With a particular tag regex, github
  actions can also build and deliver our container images to ECR.


-----

- Kubernetes: pod, node, cluster, service, deployment, ingress, helm, tiller, pod autoscaler

- terraform: provider, terraform block, resource, variables, outputs

- ansible: inventory config (ansible.cfg), hosts file, playbook, play, module, tasks
