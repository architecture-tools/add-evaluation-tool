# Sprint 3 Retrospective

## What went well?

1. Successful Test-Driven Development Implementation: The team effectively applied TDD for the update NFR list feature.

2. Comprehensive CI/CD Pipeline Establishment: We successfully built a robust automation pipeline with parallel test execution,
 static analysis (ruff, mypy), and coverage enforcement (backend >= 80%, frontend >= 30%).

3. Communication about Deployment Issues: When we faced a problem with deployment, we were able to communicate the
problem well with the customer and reached a solution of using Docker for deployment for now.

### What problems did we encounter?

1. Problem: External Deployment Platform Limitations
   - Description: Unable to find suitable hosting platforms for full-stack application deployment due to
    restrictions in Russia, and resource limits.
   - Root Cause: Most free tiers of cloud platforms are either restricted in Russia or provide insufficient
   resources for backend services with database requirements.
   - Solution: After discussing the problem with the client, we received approval to use Docker Compose as our deployment
    solution for now and documented this as our staging environment.

2. Problem: TDD Adoption
   - Description: We faced a problem of spending more time in the development phase using TDD.
   - Root Cause: It was unusual for the team to write tests first as we were accustomed to implementation first strategy.
   - Solution: We realized it was a matter of adaptation and a skill that needs time and it proved efficiency later.

## Plan for Improvement

### High Impact

1. Implement MVP Analytics: Design and integrate analytics to track core user interactions (page views, feature usage)
 within the Docker environment, enabling data-driven validation of product hypotheses.
2. Implement Analytics Foundation Early: Begin planning and implementing basic usage analytics from the start of next
 sprint to track user behavior and support product hypothesis validation.

### Medium Impact

1. Establish Feature Completion Criteria: Define clear "done" criteria for features that include not just backend
implementation but also frontend integration and testing coverage.

### Low Impact

1. Create Client-Friendly Docker Guide: Develop Docker instructions and troubleshooting guide for client to easily
run and evaluate the MVP.
