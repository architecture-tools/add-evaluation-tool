# Sprint 6 Retrospective

## What went well?

1. Authorization Implementation Completed: Successfully implemented both frontend and backend authorization components.

2. Proactive Customer Communication: Despite scheduling challenges, we maintained effective asynchronous communication
 with the client by providing progress updates with proof of demo recording.

3. Bug Identification and Resolution: Successfully identified and resolved a critical usability bug related to
 email/password handling with spaces.

4. Team Adaptability: Demonstrated flexibility in maintaining productivity despite team availability challenges.

## What problems did we encounter?

### Problem 1: Customer Meeting Cancellation

- Description: Could not schedule a meeting with the customer as all team members were unavailable due to sick leave
 or corporate events.
- Root Cause: Unforeseen circumstances including illness and external corporate commitments that overlapped with planned
 meeting time.
- Solution: We sent the customer a written update covering all progress and decisions, maintaining communication
 asynchronously. This ensured transparency despite the scheduling challenge.

### Problem 2: Usability Bug in Authentication

- Description: Encountered a bug where spaces in email or password fields caused confusion and unexpected behavior for users.
- Root Cause: Inadequate input validation and sanitization in the authentication forms,
 leading to inconsistent handling of whitespace characters.
- Solution: Implemented proper input trimming and validation on both frontend and backend to ensure consistent behavior
 regardless of leading/trailing spaces in user input.

## Plan for Improvement

### High Impact

1. Establish Communication Protocols: Create a clear protocol for asynchronous customer updates when meetings aren't possible.

2. Debugging Workflow Enhancement: Develop a more systematic approach to identifying and resolving usability issues
 during development.

### Medium Impact

1. Schedule Buffer Planning: Plan for potential scheduling conflicts by identifying alternative meeting times in
 advance during sprint planning.

2. Automated Testing for Edge Cases: Add automated tests for common edge cases
 (spaces, special characters, boundary values) in form inputs.

### Low Impact

1. Improve Error Messaging: Enhance user feedback for input validation to provide clearer guidance when users
 enter invalid data.
