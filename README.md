**Project Overview**

This repository is an example implementation of a homegrown SObject Context pattern for Salesforce Apex. It’s intended as a practical, reasonably scalable approach for mid-sized orgs — not a one-size-fits-all or the single "best" solution. Use it as a reference or a starting point for your own Context-based patterns.

**Key Points**
- **Purpose:** Demonstrate how to centralize SObject logic, reduce duplication, and make handlers easier to test.
- **Scope:** Example classes and a trigger for `Opportunity` show the pattern in practice.
- **Dependency:** Some examples rely on Nebula utilities from [Nebula Core](https://github.com/Nebula-Consulting/nebula-core), but the design can be adapted to work without that repo.

**Quick Links**
- **SObject base context:** [force-app/main/default/classes/SObjectContext.cls](force-app/main/default/classes/SObjectContext.cls)
- **Main SObjectContext example:** [force-app/main/default/classes/OpportunityContext.cls](force-app/main/default/classes/OpportunityContext.cls)
- **Opportunity handler example:** [force-app/main/default/classes/Opportunity_ExampleHandler.cls](force-app/main/default/classes/Opportunity_ExampleHandler.cls)
- **Trigger (reset context call):** [force-app/main/default/triggers/OpportunityTrigger.trigger](force-app/main/default/triggers/OpportunityTrigger.trigger)

**Why use an SObject Context?**
- **Single responsibility:** Encapsulates SObject-specific helpers, caching, and common queries.
- **Consistency:** Provides a canonical place for field selectors, default values, and helper methods.
- **Testability:** Handlers and triggers become thinner, delegating heavy work to context classes that are easier to unit test.

**Overview of the main `SObjectContext` class**
- **Initialization & caching:** Lazily loads and caches related records and computed values for the current execution context.
- **Field selectors:** Centralizes the SOQL field lists used across queries to avoid string duplication.
- **Helpers:** Exposes convenience methods for common operations (e.g., safe lookups, related-list fetches, formatted values).
- **Extensibility:** Designed to be subclassed per SObject (see `OpportunityContext`), allowing object-specific logic without bloating the core.

**Opportunity examples**
- `OpportunityContext.cls` shows how to extend `SObjectContext` for Opportunity-specific data and derived properties.
- `Opportunity_ExampleHandler.cls` demonstrates a handler pattern that consumes `OpportunityContext` to implement business rules and bulk-safe operations.

**Important: Reset context in the trigger**
The trigger calls a context reset on each execution to ensure per-transaction state does not leak between operations. See the trigger file for the reset invocation: [force-app/main/default/triggers/OpportunityTrigger.trigger](force-app/main/default/triggers/OpportunityTrigger.trigger). This is critical when using static caches or thread-local state patterns in Apex.

**Getting started**
- Clone the repo.
- If you use Nebula helpers, follow their README to add the dependency or vendor necessary utilities.
- Deploy the `force-app` package to a scratch org or sandbox and run tests.

**Notes & Adaptation**
- The code is intentionally pragmatic: readable, straightforward, and suitable for adaptation. If you prefer a library or framework approach, the same concepts map to other patterns (service layers, domain services, or third-party frameworks).
- You can remove or stub Nebula-specific utilities and replace them with simple equivalents if you don't want that dependency.
- Custom metadata needed for nebula framework to function is not included, example is code only.
