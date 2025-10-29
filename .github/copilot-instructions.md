# Copilot Instructions for Zealot

This file provides guidance to GitHub Copilot when working with code in this repository.

## Project Overview

Zealot is an open-source self-hosted continuous integration platform for mobile app distribution. It provides:
- Multi-platform application hosting (macOS, iOS, Android, Windows, Linux)
- Automated test device management and Apple Developer integration
- Rich developer toolkits with REST API, iOS/Android SDKs, and fastlane plugin
- Application metadata parsing for iOS and Android apps
- Built-in event notifications and webhook integrations
- Multi-channel application management
- Third-party authentication (Feishu, GitLab, GitHub, Google, LDAP, OIDC)

## Technology Stack

### Backend
- **Primary Language**: Ruby 3.2+
- **Framework**: Ruby on Rails 8.0+
- **Database**: PostgreSQL
- **Cache**: Solid Cache
- **API**: GraphQL, Active Model Serializers
- **Background Jobs**: ActiveJob with GoodJob
- **Testing**: RSpec with Factory Bot

### Frontend
- **JavaScript Framework**: Hotwired Stimulus 3.2+, Turbo Rails
- **Build Tool**: esbuild
- **CSS**: Sass, Bootstrap 5.3+
- **Admin UI**: AdminLTE 4.0

### Tools & Infrastructure
- **Linter**: RuboCop (with rubocop-rails)
- **Server**: Puma
- **Containerization**: Docker
- **Package Manager**: Bundler (Ruby), pnpm (JavaScript)

## Coding Guidelines

### Ruby/Rails Standards
- **Ruby Version**: Target Ruby 3.2+ features
- **Rails Version**: Target Rails 8.0+ features
- **Style Guide**: Follow RuboCop configuration in `.rubocop.yml`
- **Frozen String Literals**: Always include `# frozen_string_literal: true` at the top of Ruby files (except config.ru, Gemfile, Rakefile, and config files)
- **Indentation**: 2 spaces (configured in `.editorconfig`)
- **Line Length**: Maximum 120 characters (with exceptions for config and spec files)
- **Method Length**: Maximum 60 lines
- **Class Length**: Maximum 250 lines

### File Organization
- **Controllers**: `app/controllers/` - Handle HTTP requests
- **Models**: `app/models/` - Business logic and database interactions
- **Services**: `app/services/` - Complex business operations
- **Jobs**: `app/jobs/` - Background job processing
- **Policies**: `app/policies/` - Authorization logic (Pundit)
- **Serializers**: `app/serializers/` - API response formatting
- **GraphQL**: `app/graphql/` - GraphQL schema and resolvers
- **Views**: `app/views/` - HTML templates (Slim format)
- **JavaScript**: `app/javascript/` - Stimulus controllers and frontend code
- **Stylesheets**: `app/assets/stylesheets/` - Sass/SCSS files

### JavaScript/Frontend Standards
- **Framework**: Use Hotwired Stimulus for JavaScript interactions
- **Turbo**: Leverage Turbo Drive, Frames, and Streams for dynamic updates
- **Build**: Use esbuild for JavaScript bundling
- **CSS**: Write Sass/SCSS following Bootstrap 5.3+ conventions
- **Indentation**: 2 spaces for JavaScript
- **Target**: ES2017+ features

### Database & Migrations
- **Always create reversible migrations** when possible
- **Add indexes** for foreign keys and frequently queried columns
- **Include comments** on complex migrations
- **Test migrations** both up and down
- **Use strong parameters** in controllers

## Testing Expectations

### RSpec Guidelines
- **Location**: All tests live in `spec/` directory
- **Factory Bot**: Use factories from `spec/factories/` for test data
- **Coverage**: Aim for comprehensive test coverage for new features
- **Test Types**:
  - **Request specs**: `spec/api/` - API endpoint testing
  - **Model specs**: Test validations, associations, and business logic
  - **Controller specs**: Test controller actions and responses
  - **Service specs**: Test service objects thoroughly
  - **GraphQL specs**: Test queries and mutations

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/path/to/spec_file.rb

# Run tests with specific tag
bundle exec rspec --tag focus
```

### Test Requirements
- **Every functional change must include tests**
- **Update existing tests** when modifying behavior
- **Mock external services** to avoid network calls in tests
- **Use let/let!** for test data setup
- **Follow existing test patterns** in the codebase

## Build & Validation

### Ruby/Rails Commands
```bash
# Install dependencies
bundle install

# Run RuboCop linter
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Run database migrations
bundle exec rails db:migrate

# Run Rails server
bundle exec rails server

# Run Rails console
bundle exec rails console
```

### JavaScript/Frontend Commands
```bash
# Install dependencies
pnpm install

# Build JavaScript
pnpm build

# Build CSS
pnpm build:css
```

### Database Commands
```bash
# Create database
bundle exec rails db:create

# Run migrations
bundle exec rails db:migrate

# Seed database
bundle exec rails db:seed

# Reset database
bundle exec rails db:reset
```

## Development Workflow

### Before Making Changes
1. **Check current state**: Run tests and linter to understand baseline
2. **Read related code**: Understand the context and existing patterns
3. **Plan your changes**: Make minimal, focused modifications

### Making Changes
1. **Follow existing patterns** in similar files
2. **Write tests first** or alongside code changes
3. **Run linter frequently**: `bundle exec rubocop -a`
4. **Keep commits focused**: One logical change per commit
5. **Write descriptive commit messages**

### Before Submitting
1. **Run full test suite**: `bundle exec rspec`
2. **Fix all linting issues**: `bundle exec rubocop`
3. **Verify migrations**: Test both up and down
4. **Check for N+1 queries**: Review database query performance
5. **Update documentation**: If adding/changing features

## Common Patterns

### Service Objects
```ruby
# frozen_string_literal: true

class MyService
  def initialize(params)
    @params = params
  end

  def call
    # Implementation
  end

  private

  attr_reader :params
end
```

### GraphQL Mutations
- Follow existing mutation patterns in `app/graphql/mutations/`
- Include proper authorization checks
- Return appropriate error messages

### API Endpoints
- Use Active Model Serializers for JSON responses
- Follow RESTful conventions
- Include proper authentication/authorization
- Version APIs when making breaking changes

### Background Jobs
- Keep jobs idempotent
- Handle failures gracefully
- Use appropriate queue names

## Internationalization (i18n)

- **Locale files**: `config/locales/`
- **Supported languages**: English (en), Simplified Chinese (zh-CN)
- **Always use i18n keys** in views and controllers
- **Add translations** for both English and Chinese when adding new text
- **Use Crowdin** for managing translations

## Security Considerations

- **Never commit secrets** or sensitive data
- **Use Rails credentials** for sensitive configuration
- **Validate user input** thoroughly
- **Use parameterized queries** to prevent SQL injection
- **Implement proper authorization** using Pundit policies
- **Sanitize HTML output** when rendering user content

## Documentation

- **Update README.md** when adding major features
- **Comment complex logic** but prefer self-documenting code
- **Document API changes** in appropriate guides
- **Keep CHANGELOG.md updated** for notable changes

## Pull Request Guidelines

- **Keep PRs focused**: One feature or fix per PR
- **Write clear descriptions**: Explain what and why
- **Reference issues**: Use "fixes #123" format
- **Request reviews**: Get feedback before merging
- **Ensure CI passes**: All tests and checks must pass
- **Update documentation**: Include relevant docs updates
