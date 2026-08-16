# Testing Principles

## Test Levels

### Unit Tests
- Test a single function or class in isolation
- Mock external dependencies (AWS SDK, database, HTTP clients)
- Fast — entire suite runs in seconds
- Use for: business logic, utility functions, data transformations, validation

### Contract Tests
- Verify that our code and a third-party dependency agree on their interface
- Import the REAL dependency code — do not mock the framework being tested
- No running infrastructure needed (databases, APIs) — just verify config/wiring
- Use for: anywhere we produce configuration consumed by a framework we don't own

**When to write a contract test:** If our code produces output (config objects, options, payloads) that feeds into a third-party framework (Medusa, MikroORM, Knex, Sharp, Strapi), and we cannot control how they consume it, write a contract test that exercises the real framework code with our produced output.

**Example pattern:**
```typescript
// Contract test: verify Medusa can use our database config
import { buildRdsIamDriverOptions } from "../build-pg-pool-config"
import { ModulesSdkUtils } from "@medusajs/utils"  // REAL, not mocked

it("runtime pool: password function survives pg resolution", () => {
  const driverOptions = buildRdsIamDriverOptions()
  const knexPool = ModulesSdkUtils.createPgConnection({
    clientUrl: PASSWORDLESS_URL,
    driverOptions: driverOptions,
  })
  // Verify the REAL framework kept our password function intact
  expect(typeof knexPool.client.config.connection.password).toBe("function")
})
```

### Property-Based Tests
- Verify invariants hold across a wide range of random inputs
- Use fast-check for TypeScript
- Minimum 100 iterations per property
- Use for: path derivation, encoding/decoding, data transformations where correctness depends on handling edge cases (special characters, empty strings, boundary values)

### Integration Tests
- Test components working together with real infrastructure (database, Redis, S3)
- Slower — acceptable for CI but not for rapid local iteration
- Use for: API endpoint behaviour, database migrations, end-to-end workflows

## When to Mock

**Mock these:**
- AWS SDK clients (S3, DynamoDB, Batch, Lambda) in unit tests
- Network calls (HTTP, FTP, SFTP)
- Time/dates when testing time-dependent logic
- Expensive or slow operations (image processing in handler tests)

**Do NOT mock these:**
- The framework that consumes your output (that's what contract tests are for)
- Simple utility functions in your own codebase — just call them
- Data structures or config objects — use the real ones

**The mock boundary rule:** If you're mocking a dependency to verify your code produces the right shape, ask: "does the real dependency actually work with this shape?" If you can't answer yes with confidence, you need a contract test.

## Test Organisation

### CDK Infrastructure (root project)
- Framework: Jest
- Location: `src/**/*.test.ts` or `test/**/*.test.ts`
- Assertion tests verify intent (security policies, resource configuration)
- Snapshot tests detect unintended changes

### Application Code (application/*)
- Framework: Vitest (image-optimiser) or Jest (backend)
- Unit tests: co-located with source in `__tests__/` directories or `*.spec.ts` / `*.test.ts` alongside the module
- Integration tests: `integration-tests/` directory
- Contract tests: in `__tests__/` alongside the code that produces the interface

## Test Naming

Use descriptive names that state what is being verified, not how:

```typescript
// Good — states the contract/requirement
it("migrations: db:migrate's ORM connection must carry a live credential")
it("non-image keys are skipped")
it("existing variants are not regenerated")

// Bad — describes implementation mechanics
it("should call getAuthToken")
it("should return an array")
it("works correctly")
```

## What to Test

### Always test:
- Error handling paths (what happens when things fail)
- Boundary conditions (empty inputs, maximum sizes, special characters)
- Security-relevant behaviour (auth, authorization, input validation)
- Integration points with third-party frameworks (contract tests)
- Idempotency where claimed

### Don't test:
- Third-party library internals (sharp resizes correctly, AWS SDK serialises correctly)
- Simple pass-through code with no logic
- Private implementation details that may change — test the public interface

## Coverage

- Coverage is a tool for finding gaps, not a target to hit
- A function with 100% line coverage but no contract test can still fail in production
- Focus on testing behaviour and contracts, not achieving a coverage number
- When adding coverage thresholds, set them slightly below current levels to prevent regressions without creating pressure to write meaningless tests
