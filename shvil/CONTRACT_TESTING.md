# Contract Testing System

## Overview

The Contract Testing System ensures that the frontend and backend APIs are compatible and working correctly. It provides automated testing of API contracts, validation of data models, and monitoring of API performance.

## Architecture

### Core Components

1. **APIModels.swift** - Typed models for all API endpoints
2. **ContractTestingService.swift** - Main service for running contract tests
3. **MockAPIService.swift** - Mock API responses for testing
4. **ContractTestView.swift** - UI for viewing test results

### Test Categories

1. **Authentication Contract** - Tests login, logout, and session management
2. **User Profile Contract** - Tests user profile creation, updates, and retrieval
3. **Adventure Contract** - Tests adventure creation, management, and completion
4. **Route Contract** - Tests route calculation and navigation
5. **Social Contract** - Tests social features and plan management
6. **Error Handling Contract** - Tests error scenarios and recovery
7. **Performance Contract** - Tests response times and resource usage

## Usage

### Running Contract Tests

```swift
// Run all contract tests
let results = await ContractTestingService.shared.runAllTests()

// Run specific test category
let authResult = await ContractTestingService.shared.testAuthenticationContract()
```

### Using Mock API Service

```swift
// Get mock authentication response
let authResponse = MockAPIService.shared.mockAuthentication()

// Get mock user profile
let userProfile = MockAPIService.shared.mockUserProfile()

// Get mock adventure
let adventure = MockAPIService.shared.mockAdventure()
```

### Viewing Test Results

1. Open the app
2. Go to Settings
3. Tap "Contract Tests"
4. View test results and run new tests

## Test Results

### Status Types

- **Not Run** - Test hasn't been executed yet
- **Running** - Test is currently in progress
- **Passed** - All tests passed successfully
- **Partial** - Some tests passed, some failed
- **Failed** - All tests failed

### Metrics

- **Passed/Total** - Number of tests passed vs total tests
- **Success Rate** - Percentage of tests that passed
- **Errors** - List of specific error messages

## API Models

### Authentication

```swift
struct AuthenticationResponse {
    let isSuccess: Bool
    let user: User?
    let session: Session?
    let error: APIError?
}

struct User {
    let id: String
    let email: String
    let displayName: String
    let avatarURL: String?
    let createdAt: Date
    let updatedAt: Date
}
```

### Adventures

```swift
struct Adventure {
    let id: String
    let title: String
    let description: String
    let createdBy: String
    let stops: [AdventureStop]
    let status: AdventureStatus
    let createdAt: Date
    let updatedAt: Date
}
```

### Social Features

```swift
struct Plan {
    let id: String
    let title: String
    let description: String
    let createdBy: String
    let participants: [PlanParticipant]
    let options: [PlanOption]
    let status: PlanStatus
    let votingEndsAt: Date?
    let createdAt: Date
    let updatedAt: Date
}
```

## Error Handling

### API Errors

```swift
struct APIError {
    let code: String
    let message: String
    let details: String?
}
```

### Common Error Codes

- `AUTH_FAILED` - Authentication failed
- `VALIDATION_ERROR` - Input validation failed
- `NETWORK_ERROR` - Network connection failed
- `SERVER_ERROR` - Internal server error
- `NOT_FOUND` - Resource not found
- `PERMISSION_DENIED` - Insufficient permissions

## Performance Monitoring

### Metrics Tracked

- **Response Time** - API response time in milliseconds
- **Memory Usage** - Memory consumption in bytes
- **CPU Usage** - CPU utilization percentage
- **Timestamp** - When metrics were collected

### Performance Thresholds

- Response Time: < 500ms (good), < 1000ms (acceptable), > 1000ms (poor)
- Memory Usage: < 100MB (good), < 200MB (acceptable), > 200MB (poor)
- CPU Usage: < 50% (good), < 80% (acceptable), > 80% (poor)

## Testing Strategy

### Unit Tests

- Test individual API models
- Test contract testing service methods
- Test mock API service responses
- Test error handling scenarios

### Integration Tests

- Test full API contract validation
- Test end-to-end data flow
- Test performance under load
- Test error recovery

### Contract Tests

- Validate API request/response formats
- Test data type compatibility
- Verify required fields are present
- Check optional fields are handled correctly

## Best Practices

### Model Design

1. Use strongly typed models for all API responses
2. Include all required fields as non-optional
3. Mark optional fields as optional
4. Use enums for status fields
5. Include timestamps for audit trails

### Error Handling

1. Always handle API errors gracefully
2. Provide meaningful error messages
3. Implement retry logic for transient errors
4. Log errors for debugging
5. Show user-friendly error messages

### Performance

1. Monitor API response times
2. Cache frequently accessed data
3. Implement pagination for large datasets
4. Use background queues for heavy operations
5. Optimize data models for efficiency

### Testing

1. Write tests for all API models
2. Test both success and failure scenarios
3. Use mock data for consistent testing
4. Test performance under various conditions
5. Automate contract testing in CI/CD

## Troubleshooting

### Common Issues

1. **Test Failures** - Check API endpoints and data models
2. **Performance Issues** - Monitor response times and resource usage
3. **Authentication Errors** - Verify credentials and session management
4. **Data Validation Errors** - Check required fields and data types

### Debugging

1. Enable detailed logging in contract tests
2. Check network connectivity and API availability
3. Verify data model compatibility
4. Test with mock data first
5. Use the contract test UI to monitor results

## Future Enhancements

1. **Automated Testing** - Run contract tests in CI/CD pipeline
2. **Performance Alerts** - Notify when performance thresholds are exceeded
3. **API Versioning** - Support multiple API versions
4. **Custom Tests** - Allow custom contract test definitions
5. **Reporting** - Generate detailed test reports and analytics

## Contributing

When adding new API endpoints:

1. Add typed models to `APIModels.swift`
2. Add mock responses to `MockAPIService.swift`
3. Add contract tests to `ContractTestingService.swift`
4. Update the contract test UI if needed
5. Add unit tests for new models and services
6. Update this documentation

## Support

For questions or issues with the contract testing system:

1. Check the test results in the app
2. Review the error messages and logs
3. Verify API endpoint availability
4. Test with mock data first
5. Contact the development team for assistance
