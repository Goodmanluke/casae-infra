-- Schema for Casae CMA tables
-- This file defines tables used for storing properties, CMA runs, adjustment scenarios and PDF artifacts.
create table if not exists properties (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  address text not null,
  lat double precision,
  lng double precision,
  sqft int,
  beds int,
  baths numeric,
  year int,
  condition text,
  waterfront boolean default false,
  last_sale_price numeric,
  last_sale_date date,
  created_at timestamptz default now()
);

create table if not exists cma_runs (
  id uuid primary key,
  property_id uuid references properties(id),
  user_id uuid references auth.users(id),
  is_baseline boolean default false,
  inputs jsonb not null,
  estimate numeric not null,
  comps jsonb not null,
  explanation text,
  created_at timestamptz default now()
);

create table if not exists scenarios (
  id uuid primary key default gen_random_uuid(),
  cma_run_id uuid references cma_runs(id),
  adjustments jsonb not null,
  created_at timestamptz default now()
);

create table if not exists pdf_artifacts (
  id uuid primary key default gen_random_uuid(),
  cma_run_id uuid references cma_runs(id),
  url text not null,
  expires_at timestamptz
);

alter table auth.users add column if not exists role text default 'free_user';
alter table auth.users add column if not exists is_free_access boolean default false;

alter table cma_runs enable row level security;
create policy if not exists "own cma runs" on cma_runs for select using (auth.uid() = user_id);
create policy if not exists "insert own cma runs" on cma_runs for insert with check (auth.uid() = user_id);