# Verified Opinion Network

SwiftUI iOS client for a Node.js + Express backend using JWT authentication.

## Backend

Default API base URL:

```text
http://127.0.0.1:3001/api
```

Override with environment variables if needed:

- `DEV_API_BASE_URL`
- `STAGING_API_BASE_URL`
- `PROD_API_BASE_URL`

## Implemented API Contract

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/profile`
- `PUT /auth/profile`
- `GET /survey`
- `GET /survey/:id`
- `POST /survey/submit`
- `GET /wallet`

## Architecture

- SwiftUI + MVVM
- Clean Architecture boundaries
- Async/await networking with `URLSession`
- Generic `APIClient`
- `RequestInterceptor` injects `Authorization: Bearer <JWT>` automatically
- `KeychainService` stores JWT securely
- Dependency injection through `DependencyContainer`
- Codable request/response models for every endpoint

## Structure

- `App` entry: `CommunitySurveyApp.swift`
- `Core/Network`: API client, endpoint, request builder, interceptor, errors, network monitor, SSL pinning hook
- `Core/Keychain`: `KeychainService`
- `Core/DI`: dependency graph
- `Features/Auth`: register/login view model and register screen
- `Features/Profile`: profile view and view model
- `Features/Survey`: survey list/detail and legacy survey question screen
- `Features/Wallet`: wallet view and view model
- `Models`: API request/response models
- `Utilities`: reserved for app-wide helpers

## Security

- JWT is never stored in `UserDefaults`.
- `KeychainService.save(token:)`, `getToken()`, and `deleteToken()` are the only JWT persistence APIs.
- Protected requests are marked with `requiresAuthentication: true` and receive the bearer token through `RequestInterceptor`.
- No hardcoded token is present in source.

## Notes

The older Aadhaar/OTP mock files are still present so the previous UI previews and experimental flow continue to compile, but the primary app route now uses the Node-backed login/register, survey, profile, and wallet screens.
