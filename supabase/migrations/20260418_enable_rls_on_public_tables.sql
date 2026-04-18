-- Harden public tables flagged by database lints.
-- Enabling RLS with FORCE prevents accidental data exposure through permissive grants.

alter table if exists public.visits enable row level security;
alter table if exists public.visits force row level security;

alter table if exists public.logs enable row level security;
alter table if exists public.logs force row level security;

alter table if exists public.app_secrets enable row level security;
alter table if exists public.app_secrets force row level security;
