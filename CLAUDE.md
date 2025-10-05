# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Twenty is an open-source CRM built with modern technologies in a monorepo structure. The codebase is organized as an Nx workspace with multiple packages.

## Prerequisites

- **Node.js**: ^24.5.0
- **Yarn**: >=4.0.2 (using Yarn 4.9.2)
- **PostgreSQL**: 16+ (can be run via Docker)
- **Redis**: Latest (can be run via Docker)
- **Docker**: Required for local infrastructure setup

### Initial Setup
```bash
# Install dependencies
yarn install

# Copy environment files
cp packages/twenty-server/.env.example packages/twenty-server/.env
cp packages/twenty-front/.env.example packages/twenty-front/.env

# Start infrastructure (PostgreSQL + Redis)
make postgres-on-docker
make redis-on-docker

# Initialize database
npx nx database:reset twenty-server

# Start development servers
yarn start
```

## Key Commands

### Development
```bash
# Start development environment (frontend + backend + worker)
yarn start

# Individual package development
npx nx start twenty-front     # Start frontend dev server
npx nx start twenty-server    # Start backend server
npx nx run twenty-server:worker  # Start background worker
```

### Testing
```bash
# Run tests
npx nx test twenty-front      # Frontend unit tests
npx nx test twenty-server     # Backend unit tests
npx nx run twenty-server:test:integration:with-db-reset  # Integration tests with DB reset

# Storybook
npx nx storybook:build twenty-front         # Build Storybook
npx nx storybook:serve-and-test:static twenty-front     # Run Storybook tests
```

### Code Quality
```bash
# Linting
npx nx lint twenty-front      # Frontend linting
npx nx lint twenty-server     # Backend linting
npx nx lint twenty-front --fix  # Auto-fix linting issues

# Type checking
npx nx typecheck twenty-front
npx nx typecheck twenty-server

# Format code
npx nx fmt twenty-front
npx nx fmt twenty-server
```

### Build
```bash
# Build packages
npx nx build twenty-front
npx nx build twenty-server

# Build all packages
npx nx run-many --target=build --all

# Build affected packages only
npx nx affected --target=build --base=main
```

### Nx Utilities
```bash
# View dependency graph
npx nx graph

# Check what's affected by changes
npx nx affected --target=test
npx nx affected --target=lint --base=main

# Run target for multiple projects
npx nx run-many --target=test --projects=twenty-front,twenty-server
```

### Database Operations
```bash
# Database management
npx nx database:reset twenty-server         # Reset database
npx nx run twenty-server:database:init:prod # Initialize database
npx nx run twenty-server:database:migrate:prod # Run migrations

# Generate migration
npx nx run twenty-server:typeorm migration:generate src/database/typeorm/core/migrations/[name] -d src/database/typeorm/core/core.datasource.ts

# Sync metadata
npx nx run twenty-server:command workspace:sync-metadata -f
```

### GraphQL
```bash
# Generate GraphQL types
npx nx run twenty-front:graphql:generate
```

## Architecture Overview

### Tech Stack
- **Frontend**: React 18, TypeScript, Recoil (state management), Emotion (styling), Vite
- **Backend**: NestJS, TypeORM, PostgreSQL, Redis, GraphQL (with GraphQL Yoga)
- **Monorepo**: Nx workspace managed with Yarn 4

### Package Structure
```
packages/
├── twenty-front/          # React frontend application (Vite + React 18)
├── twenty-server/         # NestJS backend API (GraphQL, TypeORM, Redis)
├── twenty-ui/             # Shared UI components library (styled-components)
├── twenty-shared/         # Common types and utilities (shared across packages)
├── twenty-utils/          # Utility functions library
├── twenty-emails/         # Email templates with React Email
├── twenty-website/        # Next.js documentation website
├── twenty-zapier/         # Zapier integration package
├── twenty-cli/            # CLI tools for workspace management
└── twenty-e2e-testing/    # Playwright E2E tests
```

### Package Relationships
- `twenty-front` depends on `twenty-ui`, `twenty-shared`, `twenty-utils`
- `twenty-server` depends on `twenty-shared`, `twenty-utils`, `twenty-emails`
- All imports use path mappings defined in `tsconfig.base.json`

### Key Development Principles
- **Functional components only** (no class components)
- **Named exports only** (no default exports)
- **Types over interfaces** (except when extending third-party interfaces)
- **String literals over enums** (except for GraphQL enums)
- **No 'any' type allowed** - TypeScript strict mode enabled
- **Event handlers preferred over useEffect** for state updates
- **Small, focused functions** - Extract complex logic into hooks/utilities
- **Composition over inheritance** - Combine simple components

### State Management
- **Recoil** for global state management
  - Atoms for primitive state
  - Selectors for derived state
  - Atom families for dynamic atoms
- Component-specific state with React hooks (useState, useReducer)
- GraphQL cache managed by Apollo Client
- Props down, events up - unidirectional data flow

### Backend Architecture
- **NestJS modules** for feature organization
- **TypeORM** for database ORM with PostgreSQL
- **GraphQL** API with code-first approach
- **Redis** for caching and session management
- **BullMQ** for background job processing

### Database
- **PostgreSQL** as primary database
- **Redis** for caching and sessions
- **TypeORM migrations** for schema management
- **ClickHouse** for analytics (when enabled)

## Development Workflow

### Before Making Changes
1. Always run linting and type checking after code changes
2. Test changes with relevant test suites
3. Ensure database migrations are properly structured
4. Check that GraphQL schema changes are backward compatible

### File Organization
```
packages/twenty-front/src/
├── components/      # Reusable UI components
├── pages/          # Route components
├── modules/        # Feature modules (with components/, hooks/, services/, types/)
├── hooks/          # Custom hooks
├── services/       # API services
└── types/          # Type definitions

packages/twenty-server/src/
├── modules/        # Feature modules
├── entities/       # Database entities
├── dto/           # Data transfer objects
└── utils/         # Helper functions
```

### File Naming & Structure
- Use **kebab-case** for all files and directories
- Descriptive suffixes: `user-profile.component.tsx`, `user.service.ts`, `user.entity.ts`
- **Index files** for barrel exports - keep imports clean
- **File size**: Components <300 lines, Services <500 lines
- Components in their own directories with tests and stories

### Styling
- Use **Emotion** for styling with styled-components pattern in twenty-front
- Use **styled-components** for twenty-ui package
- Follow **Nx** workspace conventions for imports
- Formatting: 2-space indentation, single quotes, 80 character print width

### Internationalization
- Use **Lingui** for i18n
- Supported languages: English (primary), French, German (planned), Spanish (planned)
- Store translations in JSON files with namespace-based organization

### Testing Strategy
- **Unit tests** with Jest for both frontend and backend
- **Integration tests** for critical backend workflows
- **Storybook** for component development and testing
- **E2E tests** with Playwright for critical user flows

## Important Files
- `nx.json` - Nx workspace configuration with task definitions
- `tsconfig.base.json` - Base TypeScript configuration
- `package.json` - Root package with workspace definitions
- `.cursor/rules/` - Development guidelines and best practices
- `Makefile` - Docker infrastructure setup commands

## Infrastructure Setup

### Local Development with Docker
```bash
# Start PostgreSQL
make postgres-on-docker

# Start Redis
make redis-on-docker

# Optional: ClickHouse for analytics
make clickhouse-on-docker

# Optional: Grafana for monitoring
make grafana-on-docker

# Optional: OpenTelemetry collector
make opentelemetry-collector-on-docker
```

All services run on the `twenty_network` Docker network and persist data in named volumes.

## Code Style Conventions

### Naming Conventions
- **Variables/Functions**: camelCase
- **Constants**: SCREAMING_SNAKE_CASE
- **Types/Classes**: PascalCase
- **Files/Directories**: kebab-case
- **Component Props**: Suffix with 'Props'

### Import Organization
```typescript
// 1. External libraries
import React from 'react';
import { useCallback } from 'react';
import styled from 'styled-components';

// 2. Internal modules (absolute paths with @/)
import { Button } from '@/components/ui';
import { UserService } from '@/services';

// 3. Relative imports
import { UserCardProps } from './types';

// Note: ESLint enforces consistent import ordering
```

### Comments
- Use short-form comments (`//`), NOT JSDoc blocks (`/** */`)
- Explain business logic and non-obvious intentions
- Multi-line comments use multiple `//` lines

### TypeScript Best Practices
```typescript
// ✅ Use type over interface
type User = { id: string; name: string };

// ✅ String literal unions over enums (except GraphQL)
type UserRole = 'admin' | 'user' | 'guest';

// ✅ Leverage type inference when clear
const users = ['John', 'Jane']; // inferred as string[]

// ✅ Discriminated unions for type safety
type Result =
  | { type: 'success'; data: User }
  | { type: 'error'; message: string };

// ✅ Generic types with descriptive names
type ApiResponse<TData> = {
  data: TData;
  status: number;
};
```

### React Performance
```typescript
// ✅ Use memo for expensive components only
const ExpensiveChart = memo(({ data }: ChartProps) => {
  return <ComplexChart data={data} />;
});

// ✅ Memoize callbacks with useCallback
const handleUserSelect = useCallback((user: User) => {
  onUserSelect(user);
}, [onUserSelect]);

// ✅ Functional state updates
setCount(prev => prev + 1);

// ✅ Batch state updates when possible
const updateForm = useCallback(() => {
  setIsLoading(true);
  setError(null);
  setData(newData);
}, [newData]);
```

### Security
- For CSV exports: Always sanitize first, then format: `formatValueForCSV(sanitizeValueForCSVExport(value))`
- Validate all user input before processing
- Never commit `.env` files or credentials

## Testing

### Running Single Tests (Preferred)
```bash
# Frontend tests (.test.ts extension)
npx jest path/to/file.test.ts --config=packages/twenty-front/jest.config.mjs

# Backend tests (.spec.ts extension)
npx jest path/to/file.spec.ts --config=packages/twenty-server/jest.config.mjs

# Watch mode for development
npx jest path/to/file.test.ts --config=packages/twenty-front/jest.config.mjs --watch

# With coverage
npx jest path/to/file.test.ts --config=packages/twenty-front/jest.config.mjs --coverage
```

### Test Structure (AAA Pattern)
```typescript
describe('Feature', () => {
  it('should do something when condition', () => {
    // Arrange - Setup
    // Act - Execute
    // Assert - Verify
  });
});
```

### Test Principles
- Test behavior, not implementation
- Use descriptive test names: "should [behavior] when [condition]"
- Query by user-visible elements (text, roles, labels) over test IDs
- Keep tests isolated and repeatable
- Target: 70% unit, 20% integration, 10% E2E

### Additional Development Utilities
```bash
# View dependency graph
npx nx graph

# Check affected projects
npx nx affected --target=test
npx nx affected --target=lint --base=main

# Run target for multiple projects
npx nx run-many --target=test --projects=twenty-front,twenty-server

# Build affected packages only
npx nx affected --target=build --base=main
```