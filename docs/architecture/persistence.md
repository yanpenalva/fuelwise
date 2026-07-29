# Persistence

Drift over SQLite stores the vehicle profile and calculation history locally. Decimal values are stored as text, dates are stored in UTC, and the initial schema version is 1.

`SharedPreferencesAsync` stores the standard/custom rule preference and the custom threshold value.

History stores a complete calculation snapshot so old results remain correct when the current vehicle profile changes.
