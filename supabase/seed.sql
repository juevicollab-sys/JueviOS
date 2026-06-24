-- Ju&Vi Studio OS — Seed de Dados (dados de exemplo)
-- ───────────────────────────────────────────────────────────────────────────
-- Rodar DEPOIS de schema.sql, no SQL Editor do painel Supabase.
-- Objetivo: tirar as 10 telas do estado vazio quando conectadas ao Supabase
-- (hoje as telas que já consomem os providers Riverpod aparecem em branco sem
--  registros). Os dados abaixo refletem o contexto de um estúdio criativo.
--
-- Segurança: idempotente. Limpa as 7 tabelas (na ordem das FKs) e reinsere.
-- Use UUIDs fixos para manter integridade referencial entre contatos/projetos
-- e as tabelas dependentes (transactions, tasks, activities).
--
-- ⚠️ NÃO rodar em produção com dados reais — isto APAGA o conteúdo das tabelas.
-- ───────────────────────────────────────────────────────────────────────────

BEGIN;

-- ── Limpeza (ordem reversa das dependências) ──────────────────────────────
TRUNCATE TABLE activities, tasks, notifications, posts, transactions, projects, contacts
  RESTART IDENTITY CASCADE;

-- ── CONTATOS (CRM) ────────────────────────────────────────────────────────
-- status ∈ (cliente, lead, prospect, inativo)
INSERT INTO contacts (id, name, email, phone, company, status, notes, created_at) VALUES
  ('11111111-1111-1111-1111-111111111101', 'Marina Alves',     'marina@flordecactus.com.br', '+55 11 99812-3344', 'Flor de Cactus Cosméticos', 'cliente',  'Cliente recorrente. Rebrand + social mensal.',        NOW() - INTERVAL '120 days'),
  ('11111111-1111-1111-1111-111111111102', 'Rafael Monteiro',  'rafa@studiomont.com',        '+55 21 98654-7788', 'Monteiro Arquitetura',      'cliente',  'Indicado pela Marina. Projeto de identidade visual.', NOW() - INTERVAL '74 days'),
  ('11111111-1111-1111-1111-111111111103', 'Beatriz Lima',     'bia.lima@cafeorigem.com',    '+55 31 99123-4567', 'Café Origem',               'lead',     'Pediu orçamento de embalagem. Aguardando retorno.',  NOW() - INTERVAL '21 days'),
  ('11111111-1111-1111-1111-111111111104', 'Diego Santos',     'diego@pulsefit.com.br',      '+55 11 97777-1212', 'PulseFit Academia',         'prospect', 'Contato frio via Instagram. Possível social media.', NOW() - INTERVAL '12 days'),
  ('11111111-1111-1111-1111-111111111105', 'Camila Rocha',     'camila@editoraluma.com',     '+55 41 98888-9090', 'Editora Luma',              'cliente',  'Capa de livro + diagramação. Entregue, pode voltar.', NOW() - INTERVAL '210 days'),
  ('11111111-1111-1111-1111-111111111106', 'Henrique Dias',    'hd@oldbrand.com',            '+55 11 96543-2100', 'Old Brand Confecções',      'inativo',  'Projeto pausado em 2025. Sem resposta há meses.',    NOW() - INTERVAL '300 days');

-- ── PROJETOS ──────────────────────────────────────────────────────────────
-- status ∈ (briefing, producao, revisao, entregue, arquivado); phase 0..4
INSERT INTO projects (id, title, client_id, status, phase, value, deadline, description, created_at) VALUES
  ('22222222-2222-2222-2222-222222222201', 'Rebrand Flor de Cactus',        '11111111-1111-1111-1111-111111111101', 'producao', 2, 18500.00, DATE '2026-07-10', 'Nova identidade visual + manual de marca + kit social.', NOW() - INTERVAL '40 days'),
  ('22222222-2222-2222-2222-222222222202', 'Identidade Monteiro Arq.',      '11111111-1111-1111-1111-111111111102', 'revisao',  3, 12000.00, DATE '2026-06-30', 'Logo, papelaria e assinatura de e-mail.',               NOW() - INTERVAL '55 days'),
  ('22222222-2222-2222-2222-222222222203', 'Embalagem Café Origem',         '11111111-1111-1111-1111-111111111103', 'briefing', 0,  7800.00, DATE '2026-08-15', 'Linha de embalagens para 3 blends de café especial.',   NOW() - INTERVAL '8 days'),
  ('22222222-2222-2222-2222-222222222204', 'Social PulseFit — Julho',       '11111111-1111-1111-1111-111111111104', 'briefing', 1,  3200.00, DATE '2026-07-01', 'Pacote de 12 posts + 4 reels para lançamento de turma.', NOW() - INTERVAL '5 days'),
  ('22222222-2222-2222-2222-222222222205', 'Capa "Marés" — Editora Luma',   '11111111-1111-1111-1111-111111111105', 'entregue', 4,  4500.00, DATE '2026-05-20', 'Capa e contracapa do romance. Aprovado e enviado.',     NOW() - INTERVAL '95 days');

-- ── TRANSAÇÕES (Financeiro) ───────────────────────────────────────────────
-- type ∈ (receita, despesa)
INSERT INTO transactions (id, title, type, category, value, date, project_id, created_at) VALUES
  ('33333333-3333-3333-3333-333333333301', 'Entrada 50% — Rebrand Flor de Cactus', 'receita', 'Projeto',      9250.00, DATE '2026-05-15', '22222222-2222-2222-2222-222222222201', NOW() - INTERVAL '38 days'),
  ('33333333-3333-3333-3333-333333333302', 'Entrada 50% — Identidade Monteiro',    'receita', 'Projeto',      6000.00, DATE '2026-05-02', '22222222-2222-2222-2222-222222222202', NOW() - INTERVAL '51 days'),
  ('33333333-3333-3333-3333-333333333303', 'Pagamento final — Capa Marés',         'receita', 'Projeto',      4500.00, DATE '2026-05-22', '22222222-2222-2222-2222-222222222205', NOW() - INTERVAL '31 days'),
  ('33333333-3333-3333-3333-333333333304', 'Assinatura Adobe Creative Cloud',      'despesa', 'Software',       320.00, DATE '2026-06-01', NULL,                                   NOW() - INTERVAL '21 days'),
  ('33333333-3333-3333-3333-333333333305', 'Banco de imagens (anual rateado)',     'despesa', 'Software',       149.00, DATE '2026-06-01', NULL,                                   NOW() - INTERVAL '21 days'),
  ('33333333-3333-3333-3333-333333333306', 'Impressão de provas — Monteiro',       'despesa', 'Produção',       210.00, DATE '2026-06-10', '22222222-2222-2222-2222-222222222202', NOW() - INTERVAL '12 days'),
  ('33333333-3333-3333-3333-333333333307', 'Coworking — junho',                    'despesa', 'Estrutura',      900.00, DATE '2026-06-05', NULL,                                   NOW() - INTERVAL '17 days'),
  ('33333333-3333-3333-3333-333333333308', 'Anúncio Instagram — captação',         'despesa', 'Marketing',      180.00, DATE '2026-06-12', NULL,                                   NOW() - INTERVAL '10 days');

-- ── POSTS (Redes Sociais) ─────────────────────────────────────────────────
-- network ∈ (instagram, tiktok, linkedin, youtube, threads)
-- status  ∈ (rascunho, agendado, publicado)
INSERT INTO posts (id, title, caption, network, scheduled_date, status, created_at) VALUES
  ('44444444-4444-4444-4444-444444444401', 'Bastidores Rebrand Flor de Cactus', 'Spoiler da nova cara da @flordecactus 🌵 Vem ver o processo!', 'instagram', DATE '2026-06-24', 'agendado',  NOW() - INTERVAL '3 days'),
  ('44444444-4444-4444-4444-444444444402', 'Antes & Depois — Logo Monteiro',    'O poder de uma identidade bem resolvida. Swipe ➡️',           'instagram', DATE '2026-06-26', 'agendado',  NOW() - INTERVAL '2 days'),
  ('44444444-4444-4444-4444-444444444403', 'Reel: 3 dicas de paleta de cor',    'Salva esse pra não errar mais na hora de escolher cores.',    'tiktok',    DATE '2026-06-28', 'rascunho',  NOW() - INTERVAL '1 days'),
  ('44444444-4444-4444-4444-444444444404', 'Case Editora Luma no portfólio',    'Mais um projeto que amamos fazer. Link na bio 📚',            'linkedin',  DATE '2026-06-20', 'publicado', NOW() - INTERVAL '4 days'),
  ('44444444-4444-4444-4444-444444444405', 'Lançamento turma PulseFit',         'Parceria nova chegando! 💪 Conteúdo de julho vem aí.',        'instagram', DATE '2026-07-01', 'rascunho',  NOW() - INTERVAL '1 days'),
  ('44444444-4444-4444-4444-444444444406', 'Thread: como cobramos por projeto', 'Transparência sobre precificação no estúdio. Abrindo o jogo.', 'threads',   DATE '2026-06-30', 'rascunho',  NOW());

-- ── NOTIFICAÇÕES ──────────────────────────────────────────────────────────
-- type ∈ (projeto, financeiro, crm, geral)
INSERT INTO notifications (id, title, message, type, is_read, created_at) VALUES
  ('55555555-5555-5555-5555-555555555501', 'Revisão pendente: Monteiro Arq.', 'O cliente enviou comentários na papelaria. Revisar até 28/06.', 'projeto',    FALSE, NOW() - INTERVAL '6 hours'),
  ('55555555-5555-5555-5555-555555555502', 'Parcela a receber',               'Entrada de 50% do Rebrand Flor de Cactus liberada.',           'financeiro', FALSE, NOW() - INTERVAL '1 days'),
  ('55555555-5555-5555-5555-555555555503', 'Novo lead no CRM',                'Beatriz Lima (Café Origem) pediu orçamento de embalagem.',     'crm',        TRUE,  NOW() - INTERVAL '21 days'),
  ('55555555-5555-5555-5555-555555555504', 'Post agendado publicado',         'O case da Editora Luma foi ao ar no LinkedIn.',                'geral',      TRUE,  NOW() - INTERVAL '4 days'),
  ('55555555-5555-5555-5555-555555555505', 'Deadline se aproximando',         'Identidade Monteiro Arq. vence em 30/06.',                     'projeto',    FALSE, NOW() - INTERVAL '2 hours');

-- ── TAREFAS (Checklist) ───────────────────────────────────────────────────
INSERT INTO tasks (id, title, is_done, due_date, project_id, created_at) VALUES
  ('66666666-6666-6666-6666-666666666601', 'Finalizar manual de marca (Flor de Cactus)', FALSE, DATE '2026-06-30', '22222222-2222-2222-2222-222222222201', NOW() - INTERVAL '10 days'),
  ('66666666-6666-6666-6666-666666666602', 'Exportar kit de social (9 templates)',       FALSE, DATE '2026-07-05', '22222222-2222-2222-2222-222222222201', NOW() - INTERVAL '8 days'),
  ('66666666-6666-6666-6666-666666666603', 'Ajustar papelaria conforme feedback',        FALSE, DATE '2026-06-28', '22222222-2222-2222-2222-222222222202', NOW() - INTERVAL '3 days'),
  ('66666666-6666-6666-6666-666666666604', 'Enviar contrato — Café Origem',              FALSE, DATE '2026-06-25', '22222222-2222-2222-2222-222222222203', NOW() - INTERVAL '2 days'),
  ('66666666-6666-6666-6666-666666666605', 'Briefing inicial PulseFit',                  TRUE,  DATE '2026-06-18', '22222222-2222-2222-2222-222222222204', NOW() - INTERVAL '5 days'),
  ('66666666-6666-6666-6666-666666666606', 'Reunião de alinhamento semanal',             TRUE,  DATE '2026-06-22', NULL,                                   NOW() - INTERVAL '1 days'),
  ('66666666-6666-6666-6666-666666666607', 'Atualizar portfólio com case Marés',         FALSE, DATE '2026-07-02', '22222222-2222-2222-2222-222222222205', NOW() - INTERVAL '6 days'),
  ('66666666-6666-6666-6666-666666666608', 'Emitir nota fiscal — entrada Monteiro',      TRUE,  DATE '2026-05-05', '22222222-2222-2222-2222-222222222202', NOW() - INTERVAL '48 days');

-- ── ATIVIDADES (Feed) ─────────────────────────────────────────────────────
-- entity_type ∈ (projeto, contato, financeiro, post)
INSERT INTO activities (id, type, title, description, entity_type, entity_id, created_at) VALUES
  ('77777777-7777-7777-7777-777777777701', 'project_updated', 'Rebrand Flor de Cactus avançou para Produção', 'Fase 2 de 4 iniciada.',                       'projeto',    '22222222-2222-2222-2222-222222222201', NOW() - INTERVAL '2 days'),
  ('77777777-7777-7777-7777-777777777702', 'payment_received', 'Pagamento recebido',                          'Entrada de R$ 9.250 — Flor de Cactus.',       'financeiro', '33333333-3333-3333-3333-333333333301', NOW() - INTERVAL '1 days'),
  ('77777777-7777-7777-7777-777777777703', 'contact_created', 'Novo contato no CRM',                          'Beatriz Lima (Café Origem) adicionada como lead.', 'contato', '11111111-1111-1111-1111-111111111103', NOW() - INTERVAL '21 days'),
  ('77777777-7777-7777-7777-777777777704', 'post_published',  'Post publicado',                              'Case Editora Luma foi ao ar no LinkedIn.',    'post',       '44444444-4444-4444-4444-444444444404', NOW() - INTERVAL '4 days'),
  ('77777777-7777-7777-7777-777777777705', 'project_review',  'Identidade Monteiro entrou em Revisão',       'Cliente enviou comentários na papelaria.',    'projeto',    '22222222-2222-2222-2222-222222222202', NOW() - INTERVAL '6 hours'),
  ('77777777-7777-7777-7777-777777777706', 'project_delivered','Capa "Marés" entregue',                      'Projeto aprovado e arquivos finais enviados.', 'projeto',   '22222222-2222-2222-2222-222222222205', NOW() - INTERVAL '31 days'),
  ('77777777-7777-7777-7777-777777777707', 'post_scheduled',  'Post agendado',                               'Bastidores Flor de Cactus agendado p/ 24/06.', 'post',      '44444444-4444-4444-4444-444444444401', NOW() - INTERVAL '3 days'),
  ('77777777-7777-7777-7777-777777777708', 'expense_added',   'Despesa registrada',                          'Coworking de junho — R$ 900.',                'financeiro', '33333333-3333-3333-3333-333333333307', NOW() - INTERVAL '17 days');

COMMIT;

-- ── Conferência rápida (opcional) ─────────────────────────────────────────
-- SELECT 'contacts' t, count(*) FROM contacts
-- UNION ALL SELECT 'projects', count(*) FROM projects
-- UNION ALL SELECT 'transactions', count(*) FROM transactions
-- UNION ALL SELECT 'posts', count(*) FROM posts
-- UNION ALL SELECT 'notifications', count(*) FROM notifications
-- UNION ALL SELECT 'tasks', count(*) FROM tasks
-- UNION ALL SELECT 'activities', count(*) FROM activities;
