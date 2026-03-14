-- Supabase RLS setup for Pension Calculator Civilian
-- Run this in the Supabase SQL Editor.

begin;

-- ---------------------------
-- logs table
-- ---------------------------
alter table if exists public.logs enable row level security;

-- Remove old policies (safe to re-run)
drop policy if exists "anon_can_select_logs" on public.logs;
drop policy if exists "anon_can_insert_logs" on public.logs;
drop policy if exists "anon_can_update_logs" on public.logs;
drop policy if exists "anon_can_delete_logs" on public.logs;

-- This app uses anon key from the browser to read/write logs.
create policy "anon_can_select_logs"
on public.logs
for select
to anon
using (true);

create policy "anon_can_insert_logs"
on public.logs
for insert
to anon
with check (true);

create policy "anon_can_update_logs"
on public.logs
for update
to anon
using (true)
with check (true);

create policy "anon_can_delete_logs"
on public.logs
for delete
to anon
using (true);

-- ---------------------------
-- visits table
-- ---------------------------
alter table if exists public.visits enable row level security;

-- Remove old policies (safe to re-run)
drop policy if exists "anon_can_select_visits" on public.visits;
drop policy if exists "anon_can_insert_visits" on public.visits;
drop policy if exists "anon_can_update_visits_row_1" on public.visits;

-- App reads the counter value from visits(id=1).
create policy "anon_can_select_visits"
on public.visits
for select
to anon
using (true);

-- Optional bootstrap insert (only row id=1).
create policy "anon_can_insert_visits"
on public.visits
for insert
to anon
with check (id = 1);

-- App increments the counter on row id=1.
create policy "anon_can_update_visits_row_1"
on public.visits
for update
to anon
using (id = 1)
with check (id = 1);

-- ---------------------------
-- increment_visits RPC helper
-- ---------------------------
create or replace function public.increment_visits()
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
    new_count bigint;
begin
    insert into public.visits (id, count)
    values (1, 0)
    on conflict (id) do nothing;

    update public.visits
    set count = count + 1
    where id = 1
    returning count into new_count;

    return coalesce(new_count, 0);
end;
$$;

revoke all on function public.increment_visits() from public;
grant execute on function public.increment_visits() to anon;

commit;
