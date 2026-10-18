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

- **Primary Language**: Ruby 4.0+
- **Framework**: Ruby on Rails 8.1+
- **Database**: PostgreSQL
- **Cache**: Solid Cache
- **API**: GraphQL, Active Model Serializers
- **Background Jobs**: ActiveJob with GoodJob

### Frontend

- **JavaScript Framework**: Hotwired Stimulus 3.2+, Turbo Rails
- **Build Tool**: vite
- **CSS**: TailwindCSS 4+, DaisyUI 5+, FontAwesome 7+

### Tools & Infrastructure

- **Linter**: RuboCop (with rubocop-rails)
- **Server**: Puma
- **Containerization**: Docker
- **Package Manager**: Bundler (Ruby), pnpm (JavaScript)

## Coding Guidelines

### Ruby/Rails Standards

- **Ruby Version**: Target Ruby 4.0+ features
- **Rails Version**: Target Rails 8.1+ features
- **Style Guide**: Follow RuboCop configuration in `.rubocop.yml`
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
- **JavaScript**: `app/frontend/javascript` - Stimulus controllers and frontend code
- **Stylesheets**: `app/frontend/stylesheets/` - Sass/SCSS files

### JavaScript/Frontend Standards

- **Framework**: Use Hotwired Stimulus for JavaScript interactions
- **Turbo**: Leverage Turbo Drive, Frames, and Streams for dynamic updates
- **Build**: Use vite for CSS/JavaScript bundling
- **Indentation**: 2 spaces for JavaScript
- **Target**: ES2017+ features

### Database & Migrations

- **Always create reversible migrations** when possible
- **Add indexes** for foreign keys and frequently queried columns
- **Include comments** on complex migrations
- **Test migrations** both up and down
- **Use strong parameters** in controllers

## Styling

- **TailwindCSS** or **DaisyUI** Only:
  - Do not write custom CSS
  - Do not use scoped CSS
  - Do not use inline styles
  - Always use TailwindCSS or DaisyUI utility classes
  - **Responsive Design**: Ensure components are responsive using Tailwind's responsive utilities

## Verification & OpenAPI

CI verifies this repository with RuboCop, a Zeitwerk check and a boot smoke;
there is no test suite. `spec/api/*` is an rswag OpenAPI **document generator**:
rswag drives it in dry-run (`.rspec` sets `--dry-run`), so `run_test!` never
issues a request, and `spec/` holds no factories or request specs.

To change an API response shape, edit `spec/api/*` and `spec/swagger_helper.rb`
(`components.schemas`), then regenerate the tracked documents:

```bash
bin/rails zealot:swaggerize
```

## Build & Validation

### Ruby/Rails Commands

```bash
# Install dependencies
bundle install

# Run RuboCop linter
bin/rubocop

# Auto-fix RuboCop issues
bin/rubocop -a

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

# Build JavaScript/CSS assets
pnpm build
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

## Local Development Gotchas

- **Local Docker builds**: pass `--build-arg REPLACE_CHINA_MIRROR=false`. The
  Dockerfile defaults it to `true`, which rewrites gem sources to
  `gems.ruby-china.com`; that mirror fails TLS from outside China.
  All workflows already pass `false`.
- **Connecting to the dev Postgres**: the devcontainer's service has an
  underscore in its hostname (`zealot_devcontainer-db-1`), which
  `URI::InvalidURIError`s when used in `ZEALOT_DATABASE_URL`. Use the container's
  IP instead (`docker inspect ... | grep IPAddress`).
- **Running the app container** needs `SECRET_KEY_BASE` set and the
  `zealot_devcontainer_default` network joined.

## Development Workflow

### Before Making Changes

1. **Check current state**: Run `bin/rubocop` to understand the baseline
2. **Read related code**: Understand the context and existing patterns
3. **Plan your changes**: Make minimal, focused modifications

### Making Changes

1. **Follow existing patterns** in similar files
2. **Lint as you go**: `bin/rubocop -a`
3. **Keep commits focused**: One logical change per commit
4. **Write descriptive commit messages**

### Before Submitting

1. **Fix all linting issues**: `bin/rubocop`
2. **Verify migrations**: Test both up and down
3. **Check for N+1 queries**: Review database query performance
4. **Update OpenAPI documents**: Regenerate `swagger/v1/*.json` if API shapes changed
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
- **Ensure CI passes**: RuboCop, Zeitwerk and the boot smoke must pass
- **Update documentation**: Include relevant docs updates
