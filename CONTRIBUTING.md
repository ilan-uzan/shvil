# Contributing to Shvil Minimal

Thank you for your interest in contributing to Shvil Minimal! This document provides guidelines and information for contributors.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project follows a code of conduct that we expect all contributors to follow. Please be respectful, inclusive, and constructive in all interactions.

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 18.0+ deployment target
- Swift 5.9+
- Git

### Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/shvil.git`
3. Open `shvil.xcodeproj` in Xcode
4. Build and run the project

## Development Workflow

### Issue-First Development
We follow an issue-first development process:

1. **Find or create an issue** for the work you want to do
2. **Get the issue approved** and assigned to you
3. **Create a feature branch** from `main`
4. **Implement the changes** following our coding standards
5. **Create a pull request** with proper documentation
6. **Address feedback** and get approval
7. **Merge** after all checks pass

### Branching Strategy
- `main` - Always stable, demo-ready
- `feat/<slug>` - New features
- `fix/<slug>` - Bug fixes
- `chore/<slug>` - Maintenance, refactoring, tooling

### Commit Messages
We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(scope): short description

Longer description if needed

- Bullet points for details
- Reference issues: Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `chore`: Maintenance, refactoring, tooling
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `test`: Adding or updating tests
- `refactor`: Code refactoring

## Coding Standards

### Swift Style
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Keep functions small and focused
- Add documentation comments for public APIs
- Use `guard` statements for early returns
- Prefer `let` over `var` when possible

### Architecture
- Follow the modular architecture (AppCore, LocationKit, MapEngine, etc.)
- Keep modules loosely coupled
- Use dependency injection where appropriate
- Follow MVVM pattern for UI components

### Design System
- Use Liquid Glass design tokens from `LiquidGlassDesign.swift`
- Follow the component library in `LiquidGlassComponents.swift`
- Ensure accessibility compliance
- Test on multiple device sizes

## Testing

### Unit Tests
- Write unit tests for business logic
- Aim for high test coverage on critical paths
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

### UI Tests
- Write UI tests for critical user flows
- Test accessibility features
- Test on multiple device sizes
- Use Page Object pattern for complex UIs

### Manual Testing
- Test on physical devices when possible
- Test with different accessibility settings
- Test offline scenarios
- Test with different network conditions

## Documentation

### Code Documentation
- Document public APIs with Swift doc comments
- Keep README.md up to date
- Update DESIGN.md when UI changes
- Update ARCHITECTURE.md when structure changes

### Pull Request Documentation
- Use the PR template
- Include screenshots for UI changes
- Document breaking changes
- Link to related issues

## Pull Request Process

### Before Submitting
- [ ] Code follows project conventions
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Branch is up to date with main

### PR Requirements
- [ ] Linked to an issue
- [ ] Follows PR template
- [ ] All checklists completed
- [ ] CI passes
- [ ] Code review approved
- [ ] Accessibility tested

### Review Process
1. Automated checks must pass
2. At least one code review approval required
3. All feedback addressed
4. Squash merge to main

## Project Structure

```
shvil/
├── AppCore/           # Core app state and dependencies
├── LocationKit/       # Location services
├── MapEngine/         # MapKit wrapper
├── RoutingEngine/     # Navigation logic
├── ContextEngine/     # Smart suggestions
├── SocialKit/         # Social features
├── SafetyKit/         # Safety reports
├── Persistence/       # Local storage
├── PrivacyGuard/      # Privacy management
├── Utils/             # Utility services
├── Shared/            # Shared components and services
├── Features/          # Feature-specific views
└── .github/           # GitHub templates and workflows
```

## Getting Help

- Check existing issues and discussions
- Ask questions in issue comments
- Follow the code of conduct
- Be patient and respectful

## License

By contributing to Shvil Minimal, you agree that your contributions will be licensed under the same license as the project.
