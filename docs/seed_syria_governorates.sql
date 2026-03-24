-- Seed: Syrian governorates (idempotent)
-- Run this in Supabase SQL Editor

begin;

insert into public.locations (name, name_en, slug)
values
  ('حلب', 'Aleppo', 'aleppo'),
  ('دمشق', 'Damascus', 'damascus'),
  ('ريف دمشق', 'Rif Dimashq', 'rif-dimashq'),
  ('حمص', 'Homs', 'homs'),
  ('حماة', 'Hama', 'hama'),
  ('اللاذقية', 'Latakia', 'latakia'),
  ('طرطوس', 'Tartus', 'tartus'),
  ('الرقة', 'Raqqa', 'raqqa'),
  ('دير الزور', 'Deir al-Zor', 'deir-al-zor'),
  ('الحسكة', 'Hasakah', 'hasakah'),
  ('إدلب', 'Idlib', 'idlib'),
  ('درعا', 'Daraa', 'daraa'),
  ('القنيطرة', 'Quneitra', 'quneitra'),
  ('السويداء', 'As-Suwayda', 'as-suwayda')
on conflict (slug) do update
  set name = excluded.name,
      name_en = excluded.name_en;

commit;
