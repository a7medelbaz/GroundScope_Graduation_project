# Constitution: Fix Supervisor Dashboard Loading

## Goal

Fix SupervisorDashboardCubit so parallel Supabase queries never block each other.

## Rules

- Use _safeCall `<T>`() + Future.wait for all independent queries
- State fields are nullable per metric
- Add sessionExpired status → UI redirects to login via AuthCubit.logout()
- Never access Supabase client directly — always through repo
- Follow CLAUDE.md error handling pattern exactly
