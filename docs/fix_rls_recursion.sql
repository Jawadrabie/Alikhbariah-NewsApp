-- Fix RLS recursion causing "stack depth limit exceeded"
-- Run this in Supabase SQL Editor

begin;

create or replace function public.is_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.user_id = auth.uid()
  );
$$;

revoke all on function public.is_admin_user() from public;
grant execute on function public.is_admin_user() to authenticated, anon;

-- Remove recursive policy on admin_users

drop policy if exists admin_users_admin_all on public.admin_users;
drop policy if exists admin_users_self_select on public.admin_users;

create policy admin_users_self_select on public.admin_users
for select
to authenticated
using (user_id = auth.uid());

commit;
