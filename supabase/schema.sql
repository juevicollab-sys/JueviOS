-- Ju&Vi Studio OS — Schema Supabase
-- Rodar no SQL Editor do painel Supabase (https://app.supabase.com)

-- ─────────────────────────────────────────
-- TABELAS
-- ─────────────────────────────────────────

CREATE TABLE contacts (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name       TEXT NOT NULL,
  email      TEXT,
  phone      TEXT,
  company    TEXT,
  status     TEXT NOT NULL DEFAULT 'lead'
             CHECK (status IN ('cliente', 'lead', 'prospect', 'inativo')),
  avatar_url TEXT,
  notes      TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE projects (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  client_id   UUID REFERENCES contacts(id) ON DELETE SET NULL,
  status      TEXT NOT NULL DEFAULT 'briefing'
              CHECK (status IN ('briefing', 'producao', 'revisao', 'entregue', 'arquivado')),
  phase       INTEGER DEFAULT 0 CHECK (phase BETWEEN 0 AND 4),
  value       NUMERIC(12,2),
  deadline    DATE,
  description TEXT,
  cover_url   TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE transactions (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('receita', 'despesa')),
  category    TEXT,
  value       NUMERIC(12,2) NOT NULL,
  date        DATE NOT NULL DEFAULT CURRENT_DATE,
  project_id  UUID REFERENCES projects(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE posts (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title          TEXT NOT NULL,
  caption        TEXT,
  network        TEXT NOT NULL
                 CHECK (network IN ('instagram', 'tiktok', 'linkedin', 'youtube', 'threads')),
  scheduled_date DATE NOT NULL,
  status         TEXT NOT NULL DEFAULT 'rascunho'
                 CHECK (status IN ('rascunho', 'agendado', 'publicado')),
  cover_url      TEXT,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title      TEXT NOT NULL,
  message    TEXT,
  type       TEXT NOT NULL DEFAULT 'geral'
             CHECK (type IN ('projeto', 'financeiro', 'crm', 'geral')),
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tasks (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  is_done     BOOLEAN DEFAULT FALSE,
  due_date    DATE,
  project_id  UUID REFERENCES projects(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE activities (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type        TEXT NOT NULL,
  title       TEXT NOT NULL,
  description TEXT,
  entity_type TEXT CHECK (entity_type IN ('projeto', 'contato', 'financeiro', 'post')),
  entity_id   UUID,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- TRIGGER: updated_at automático
-- ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER contacts_updated_at
  BEFORE UPDATE ON contacts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER projects_updated_at
  BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─────────────────────────────────────────
-- REALTIME: habilitar em todas as tabelas
-- ─────────────────────────────────────────

ALTER PUBLICATION supabase_realtime ADD TABLE contacts;
ALTER PUBLICATION supabase_realtime ADD TABLE projects;
ALTER PUBLICATION supabase_realtime ADD TABLE transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE posts;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE activities;

-- ─────────────────────────────────────────
-- RLS: Row Level Security (ajustar conforme auth)
-- Por ora desabilitado para uso interno sem login
-- ─────────────────────────────────────────

ALTER TABLE contacts     DISABLE ROW LEVEL SECURITY;
ALTER TABLE projects     DISABLE ROW LEVEL SECURITY;
ALTER TABLE transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE posts        DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE tasks        DISABLE ROW LEVEL SECURITY;
ALTER TABLE activities   DISABLE ROW LEVEL SECURITY;
