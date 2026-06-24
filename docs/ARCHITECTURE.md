# Arquitetura — JueviOS

Documento vivo. Descreve como o app é organizado e como os dados fluem.

## Visão geral

```
┌──────────────────────────────────────────────┐
│  Flutter app (Windows · Android)               │
│                                                │
│  UI (10 telas)  ──>  Riverpod providers        │
│        ▲                    │                  │
│        │ realtime           │ read/write       │
│        └──────────┐         ▼                  │
│                   │   Supabase service         │
└───────────────────┼────────────┬───────────────┘
                     │            │
              Realtime stream     │ REST/SDK
                     ▼            ▼
            ┌─────────────────────────────┐
            │  Supabase (Postgres)         │
            └─────────────────────────────┘
                     ▲
                     │ webhook (a cada 5 min, opcional)
                     │
                  n8n  <─sync─>  Notion
```

## Camadas do código (`lib/`)

| Pasta | Responsabilidade |
|-------|------------------|
| `lib/config/` | Configuração de ambiente (URL/keys, flags). `app_config.example.dart` é o template. |
| `lib/core/` | Tema (cores, tipografia), constantes, utilitários e widgets compartilhados. |
| `lib/models/` | Modelos de dados imutáveis (Project, Contact, Task, Transaction, Post...). |
| `lib/providers/` | Providers Riverpod — fonte de verdade do estado da UI. |
| `lib/services/` | Acesso ao Supabase (CRUD + streams realtime) e integrações externas. |
| `lib/screens/` | As 10 telas. Cada tela consome providers, nunca o service direto. |
| `lib/app.dart` · `lib/main_layout.dart` | Bootstrap, shell de navegação e roteamento (GoRouter). |

**Regra de dependência:** `screens → providers → services → Supabase`.
A UI nunca fala com o service diretamente; sempre passa por um provider.

## Estado (Riverpod)

Cada domínio (projetos, contatos, tarefas, transações, posts, atividade, notificações)
tem um `AsyncNotifier` que:

1. Carrega o estado inicial do Supabase.
2. Assina o stream Realtime e atualiza o estado quando o banco muda.
3. Expõe métodos de CRUD que escrevem no Supabase (o stream propaga de volta para todos os devices).

Cada tela deve renderizar três estados: **loading** (skeleton), **erro** (retry) e **vazio**
(empty-state com personagem da marca).

## Banco de dados (Supabase / Postgres)

Tabelas principais (todas com Realtime habilitado):

| Tabela | Conteúdo |
|--------|----------|
| `projects` | Projetos do estúdio, status, datas, cliente associado |
| `contacts` | CRM — pessoas e empresas, status do relacionamento |
| `tasks` | Checklist por projeto / pessoais |
| `transactions` | Entradas e saídas financeiras |
| `posts` | Calendário de conteúdo de redes sociais |
| `activity` | Feed cronológico de eventos |
| `notifications` | Alertas por tipo, flag de lido |

> O `schema.sql` aplicável vive no repositório admin; uma versão pública de referência
> será adicionada a este repo num ciclo futuro (ver ROADMAP).

## Sincronização em tempo real

O Supabase Realtime propaga qualquer alteração para todos os dispositivos conectados em < 1s.
Não há polling no app: a UI reage ao stream.

## Sync opcional com Notion (n8n)

Um workflow n8n pode espelhar `projects` / `contacts` / `finances` com bancos do Notion via
webhook (intervalo padrão: 5 min). É **opcional** — o app funciona 100% sem isso.

## Modo de demonstração

Quando não há `.env`/config válida, o app não tenta inicializar o Supabase e roda com dados de
exemplo embutidos. Isso permite explorar a UI sem backend e evita crash no boot de um clone novo.
