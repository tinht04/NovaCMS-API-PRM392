// This file previously attempted to implement the production ApiClient interface for tests.
// That approach is fragile and unnecessary because tests inject a `postDataFn` into
// `AuthRepository` or use lightweight fakes. Keep this file intentionally empty to
// avoid analyzer issues.

// NOTE: If you need to adapt the production ApiClient surface for tests, prefer
// creating a small adapter that implements only the methods you actually call,
// or use dependency injection on the repository to avoid mocking the full ApiClient.

