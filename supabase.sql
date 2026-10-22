-- Ejecutar en Supabase > SQL Editor (proyecto nuevo o revisar nombres existentes).
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text default '',
  event_date date,
  event_time time,
  location text,
  image_url text,
  organizer text,
  published boolean not null default true,
  registration_open boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.registrations (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  first_name text not null check (char_length(trim(first_name)) between 1 and 80),
  last_name text not null check (char_length(trim(last_name)) between 1 and 120),
  email text not null check (char_length(email) between 3 and 254 and email ~* '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
  phone text check (phone is null or char_length(phone) <= 25),
  privacy_accepted boolean not null check (privacy_accepted = true),
  created_at timestamptz not null default now()
);
create unique index if not exists registrations_event_email_unique on public.registrations (event_id,lower(email));
create index if not exists registrations_event_created_idx on public.registrations(event_id,created_at desc);
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.events enable row level security;
alter table public.registrations enable row level security;
alter table public.admin_users enable row level security;

-- Definidor aislado para evitar consultas recursivas a admin_users dentro de sus políticas.
create or replace function public.is_event_admin()
returns boolean language sql stable security definer set search_path = ''
as $$ select exists(select 1 from public.admin_users where user_id = (select auth.uid())); $$;
revoke all on function public.is_event_admin() from public;
grant execute on function public.is_event_admin() to authenticated;

revoke all on public.events from anon,authenticated;
revoke all on public.registrations from anon,authenticated;
revoke all on public.admin_users from anon,authenticated;
grant select on public.events to anon;
grant select,update on public.events to authenticated;
grant insert (event_id,first_name,last_name,email,phone,privacy_accepted) on public.registrations to anon;
grant select on public.registrations to authenticated;
grant select on public.admin_users to authenticated;

create policy "Published events visible" on public.events for select to anon using (published=true);
create policy "Admins view events" on public.events for select to authenticated using ((select public.is_event_admin()));
create policy "Admins edit events" on public.events for update to authenticated using ((select public.is_event_admin())) with check ((select public.is_event_admin()));
create policy "Public registration only for open event" on public.registrations for insert to anon
with check (privacy_accepted=true and exists (select 1 from public.events e where e.id=event_id and e.published=true and e.registration_open=true));
create policy "Admins view registrations" on public.registrations for select to authenticated using ((select public.is_event_admin()));
create policy "Admins view own role" on public.admin_users for select to authenticated using (user_id=(select auth.uid()));

insert into public.events (slug,title,description,event_date,event_time,location,organizer)
values ('evento-demo','Un evento para recordar','Un encuentro especial. Completa el formulario para reservar tu plaza gratuita.',null,null,'Ubicación por confirmar','Organización del evento')
on conflict(slug) do nothing;

-- PASO MANUAL: En Supabase > Authentication > Users crea un usuario administrador.
-- Copia su UUID y ejecuta esta sentencia sustituyendo el valor:
-- insert into public.admin_users(user_id) values ('UUID-DE-TU-USUARIO');
