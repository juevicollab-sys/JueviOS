# Roadmap — JueviOS (versão Collab)

Derivado do plano interno do estúdio, em versão pública. Atualizado a cada ciclo de trabalho.

## Curto prazo — "fazer rodar de verdade"

- [x] Migrar o código Flutter do app para este repositório público (hoje vive no repo admin). *(ciclo 2)*
- [ ] `flutter pub get` + `flutter analyze` sem erros num clone limpo.
- [x] Schema Supabase público de referência (`supabase/schema.sql`) + instruções. *(ciclo 2)*
- [x] Seed de dados de exemplo para as telas saírem do estado vazio (`supabase/seed.sql`). *(ciclo 2)*
- [ ] Modo de demonstração robusto (sem `.env` → dados mock, sem crash).

## Médio prazo — "dados reais + interação"

- [ ] Ligar as 10 telas aos providers Riverpod (substituir dados mock embutidos).
- [ ] Estados de loading / erro / vazio em cada AsyncNotifier.
- [ ] CRUD completo em CRM, Projeto e Financeiro com escrita no Supabase.
- [ ] Checklist e workspace persistentes (tabela `tasks` + sync realtime).
- [ ] Sync Notion via n8n: validar webhook e comando de sincronização.
- [ ] Layout adaptativo testado nos 3 breakpoints (mobile / tablet / desktop).

## Longo prazo — "produto instalável"

- [ ] Build de release Windows + auto-start nos PCs da equipe.
- [ ] Build Android (APK/AAB) e distribuição interna.
- [ ] Autenticação por colaborador (perfis e permissões).
- [ ] Portfólio público (integração Behance + export).
- [ ] Notificações push (Android) e desktop.

## Registro de ciclos automáticos

### 2026-06-22 — Ciclo 1: fundação do repositório
Repositório estava vazio (só um README stub). Criada a fundação pública e segura:
README completo, `docs/ARCHITECTURE.md`, este roadmap, `.gitignore` (Flutter),
`.env.example`, `CONTRIBUTING.md`, `LICENSE` (MIT) e `CHANGELOG.md`.
Próximo passo: trazer o código Flutter (lib/, assets processados, pubspec) para o repo.

### 2026-06-22 — Ciclo 2: migração do código-fonte Flutter
Migrado o app do repo admin (`juevi_studio_os`) para este repositório público,
de forma sanitizada:
- `lib/` completo (39 arquivos Dart), `pubspec.yaml`/`.lock`, `analysis_options.yaml`,
  `.metadata`, `.gitattributes`, `test/`.
- `supabase/schema.sql` + `supabase/seed.sql` (dados de exemplo fictícios).
- Runners `android/` e `windows/` (sem artefatos de build).
- `assets/characters/` e `assets/logos/` apenas com README — materiais de marca
  não acompanham o clone público.
- Mantidos fora do versionamento: `app_config.dart` (gitignored), PDF do Manual de
  Marca, `referencias/`, binários de marca, `ADMIN.md`/`CLAUDE.md`/`PLANO.md`/`.docx`.

Pendência conhecida: o nome do pacote Dart continua `juevi_studio_os` (em `pubspec.yaml`,
`.metadata` e no pacote Android `com.juevi.juevi_studio_os`) — renomear para `juevi_os`
é invasivo e fica para um ciclo futuro.

Próximo passo (Ciclo 3): validar build limpo — `flutter pub get` + `flutter analyze`
sem erros num clone novo; corrigir o que aparecer; garantir o modo de demonstração
(sem `.env`) sem crash no boot.
