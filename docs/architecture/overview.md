# Architecture Overview

Fuelwise follows a modular monolith in Flutter.

## Layers

- Presentation: pages, widgets, and observable state.
- Application: use-case coordination and state orchestration.
- Domain: pure calculation rules and business models.
- Infrastructure: database, preferences, repositories, and mappers.

## Principles

- The domain has no dependency on Flutter, Drift, or SharedPreferences.
- Persistence is isolated in infrastructure.
- The UI consumes state and does not contain business rules.
- Decimal precision is preserved until presentation.
- Offline behavior is a structural requirement.
