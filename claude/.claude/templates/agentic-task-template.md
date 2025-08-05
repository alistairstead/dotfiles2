# Implementation Tasks: [Feature Name]

## Task Dependency Graph
```mermaid
[task-id-1] → [task-id-2] → [task-id-3]
[task-id-1] → [task-id-4] → [task-id-5]
```

## Foundation Tasks

### [task-id-1]: Database Schema Design
- **Description**: Design and implement database schema changes for [feature]
- **Agent**: database-engineer
- **Dependencies**: []

**PRD Context:**
- **User Story**: [User-Story]
- **Acceptance Criteria**: [Acceptance-Criteria]
- **Business Rules**: [Business-Rules]

**Implementation Guidance:**
- **Database Schema**: [DB-Schema]
- **Migration Strategy**: [Code-Examples]
- **Performance Considerations**: [Performance-Targets]

**Code Examples:**
```sql
[Code-Examples for schema definition and migration]
```

**Architecture Context:**
- **Existing Patterns**: [Reference to current database patterns]
- **Data Relationships**: [How this connects to existing tables]
- **Indexing Strategy**: [Performance optimization approach]
- **Constraints & Validation**: [Data integrity requirements]

- **Deliverables**: 
  - `db/migrations/[timestamp]_[feature]_schema.sql`
  - `docs/database/[feature]-schema.md`
- **TDD Tests**:
  - **Unit**: `test/db/schema_validation_test.[ext]` - Schema constraints and relationships
  - **Integration**: `test/db/migration_test.[ext]` - Migration success and rollback
- **Completion Criteria**:
  - Migration runs successfully in test environment
  - All schema constraints properly enforced
  - Rollback migration tested and working
- **Status**: pending

### [task-id-2]: API Endpoint Implementation  
- **Description**: Create RESTful API endpoints with authentication and validation
- **Agent**: backend-engineer
- **Dependencies**: [task-id-1]

**PRD Context:**
- **User Story**: [User-Story]
- **Acceptance Criteria**: [Acceptance-Criteria]
- **Business Rules**: [Business-Rules]

**Implementation Guidance:**
- **API Schema**: [API-Schema]
- **Authentication Pattern**: [Code-Examples for auth implementation]
- **Validation Rules**: [Business-Rules with examples]

**Code Examples:**
```javascript
[Code-Examples for API routes, middleware, and validation]
```

**Architecture Context:**
- **Existing API Patterns**: [Reference to current API structure]
- **Authentication Flow**: [How auth integrates with existing system]
- **Error Handling**: [Standard error response format]
- **Rate Limiting**: [API protection and throttling approach]

- **Deliverables**:
  - `src/api/[feature]/routes.[ext]`
  - `src/api/[feature]/validators.[ext]`
  - `docs/api/[feature]-endpoints.md`
- **TDD Tests**:
  - **Unit**: `test/api/[feature]_routes_test.[ext]` - Route handling and validation
  - **Integration**: `test/api/[feature]_integration_test.[ext]` - Database interaction
  - **Acceptance**: `test/e2e/[feature]_api_test.[ext]` - End-to-end API flows
- **Completion Criteria**:
  - All endpoints return proper HTTP status codes
  - Authentication/authorization working
  - Request validation prevents invalid data
  - API documentation updated
- **Status**: pending

## Core Implementation Tasks

### [task-id-3]: Business Logic Implementation
- **Description**: Implement core feature business logic and rules
- **Agent**: backend-engineer
- **Dependencies**: [task-id-2]

**PRD Context:**
- **User Story**: [User-Story]
- **Acceptance Criteria**: [Acceptance-Criteria]
- **Business Rules**: [Business-Rules with specific validation logic]

**Implementation Guidance:**
- **Service Architecture**: [Code-Examples for service layer patterns]
- **Data Models**: [Specific model definitions and relationships]
- **Validation Logic**: [Business rule enforcement and error handling]
- **Performance**: [Performance-Targets for business operations]

**Code Examples:**
```javascript
[Code-Examples for services, models, and business logic implementation]
```

**Architecture Context:**
- **Service Patterns**: [Reference to existing service layer architecture]
- **Data Access**: [How services interact with database layer]
- **Business Rules**: [Specific validation and constraint enforcement]
- **Error Handling**: [Business exception patterns and error responses]

- **Deliverables**:
  - `src/services/[feature]Service.[ext]`
  - `src/models/[feature]Model.[ext]`
- **TDD Tests**:
  - **Unit**: `test/services/[feature]_service_test.[ext]` - Business rule validation
  - **Unit**: `test/models/[feature]_model_test.[ext]` - Data model validation
- **Completion Criteria**:
  - All business rules properly enforced
  - Edge cases handled gracefully
  - Error conditions return meaningful messages
  - Code coverage >90% for business logic
- **Status**: pending

### [task-id-4]: Frontend Component Implementation
- **Description**: Build user interface components following design system
- **Agent**: frontend-engineer
- **Dependencies**: [task-id-1]

**PRD Context:**
- **User Story**: [User-Story]
- **Acceptance Criteria**: [Acceptance-Criteria]
- **Business Rules**: [Business-Rules for UI validation and behavior]

**Implementation Guidance:**
- **Component Structure**: [Component-Structure]
- **Props Interface**: [Code-Examples for component props and types]
- **State Management**: [Integration with existing state patterns]
- **Styling Approach**: [Design system integration and responsive patterns]

**Code Examples:**
```tsx
[Code-Examples for component implementation, props, and styling]
```

**Architecture Context:**
- **Design System Patterns**: [Reference to existing component patterns]
- **State Management**: [How component integrates with app state]
- **Event Handling**: [User interaction patterns and data flow]
- **Accessibility**: [WCAG compliance patterns and ARIA implementation]

- **Deliverables**:
  - `src/components/[Feature]/[Feature].tsx`
  - `src/components/[Feature]/[Feature].test.tsx`
  - `src/components/[Feature]/[Feature].stories.tsx`
- **TDD Tests**:
  - **Unit**: Component rendering and prop handling
  - **Integration**: User interaction testing
  - **Acceptance**: Accessibility compliance testing
- **Completion Criteria**:
  - Components render correctly across browsers
  - WCAG AA accessibility standards met
  - Design system patterns followed
  - Responsive design working on all breakpoints
- **Status**: pending

### [task-id-5]: Feature Integration
- **Description**: Connect frontend to backend with proper error handling
- **Agent**: fullstack-engineer
- **Dependencies**: [task-id-3, task-id-4]

**PRD Context:**
- **User Story**: [User-Story for complete feature flow]
- **Acceptance Criteria**: [Acceptance-Criteria for end-to-end functionality]
- **Business Rules**: [Business-Rules for data flow and error handling]

**Implementation Guidance:**
- **Data Flow**: [Code-Examples for API integration and state management]
- **Error Handling**: [Specific error conditions and user feedback patterns]
- **Loading States**: [UI patterns for async operations]
- **Performance**: [Performance-Targets for API calls and rendering]

**Code Examples:**
```typescript
[Code-Examples for hooks, API services, and integration patterns]
```

**Architecture Context:**
- **API Integration**: [How frontend connects to backend services]
- **State Synchronization**: [Data consistency across UI components]
- **Error Boundaries**: [React error handling and recovery patterns]
- **Caching Strategy**: [Data caching and invalidation approach]

- **Deliverables**:
  - `src/hooks/use[Feature].[ext]`
  - `src/services/[feature]Api.[ext]`
- **TDD Tests**:
  - **Integration**: `test/integration/[feature]_flow_test.[ext]` - Complete user flows
  - **Acceptance**: `test/e2e/[feature]_complete_test.[ext]` - End-to-end scenarios
- **Completion Criteria**:
  - All user stories from PRD working
  - Error states properly handled and displayed
  - Loading states implemented
  - Data persistence working correctly
- **Status**: pending

## Quality Assurance Tasks

### [task-id-6]: Performance Testing
- **Description**: Ensure feature meets performance requirements
- **Agent**: performance-engineer
- **Dependencies**: [task-id-5]
- **Deliverables**:
  - `test/performance/[feature]_load_test.[ext]`
  - `docs/performance/[feature]-metrics.md`
- **TDD Tests**:
  - **Performance**: API response time <500ms for 95th percentile
  - **Load**: Handle expected concurrent users
- **Completion Criteria**:
  - Performance benchmarks met
  - Load testing completed successfully
  - Performance monitoring configured
- **Status**: pending

### [task-id-7]: Security Review
- **Description**: Security validation and hardening
- **Agent**: security-engineer
- **Dependencies**: [task-id-5]
- **Deliverables**:
  - `docs/security/[feature]-review.md`
  - Security scan results
- **TDD Tests**:
  - **Security**: Input validation and sanitization
  - **Authorization**: Access control verification
- **Completion Criteria**:
  - Security scan shows no critical issues
  - Authorization rules properly enforced
  - Input validation prevents common attacks
- **Status**: pending

## Task Status Tracking

**Legend**: 
- `pending` - Not started
- `in_progress` - Currently being worked on
- `completed` - Finished and validated
- `blocked` - Waiting for dependencies or resolution

**Agent Assignment and Handoff Notes**:
- **Agent field**: Specifies which type of agent should handle this task
- **PRD Context sections**: Provide specific implementation guidance from PRD analysis
- **Implementation Guidance**: Contains extracted technical specifications and patterns
- **Code Examples**: Include concrete implementation patterns and templates
- **Architecture Context**: References existing patterns and integration approaches
- Update task status when starting/completing work
- Document any blockers or issues encountered  
- Include relevant file paths and commit references
- Note any deviations from original specifications
- If assigned agent unavailable, task can be handled by general-purpose agent

## Example: Enhanced Task with PRD Context

### auth-001: User Authentication Database Schema
- **Description**: Create database tables for user authentication with email/password and OAuth support
- **Agent**: database-engineer
- **Dependencies**: []

**PRD Context:**
- **User Story**: As a new user, I want to register with email/password so that I can access the platform securely
- **Acceptance Criteria**: 
  - Email must be unique and validated
  - Password must meet complexity requirements (8+ chars, special chars)
  - Support for OAuth providers (Google, GitHub)
  - Account activation via email verification
- **Business Rules**: 
  - Users can have multiple OAuth connections
  - Failed login attempts trigger account lockout after 5 attempts
  - Password reset tokens expire after 24 hours

**Implementation Guidance:**
- **Database Schema**: 
  ```sql
  CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
  );
  
  CREATE TABLE oauth_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    UNIQUE(provider, provider_id)
  );
  ```
- **Migration Strategy**: Use Alembic for versioned migrations with rollback support
- **Performance Considerations**: Index on email, provider combinations

**Architecture Context:**
- **Existing Patterns**: Follow current UUID primary key pattern
- **Data Relationships**: Users table is referenced by oauth_accounts and user_sessions
- **Indexing Strategy**: Composite index on (provider, provider_id) for OAuth lookups
- **Constraints & Validation**: Email uniqueness, referential integrity for OAuth accounts