# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [Unreleased]

### Adicionado
- Fundação do repositório público: README completo, documentação de arquitetura
  (`docs/ARCHITECTURE.md`) e roadmap (`docs/ROADMAP.md`).
- `.gitignore` para projeto Flutter, `.env.example`, `CONTRIBUTING.md`, `LICENSE` (MIT).
- **Código-fonte Flutter migrado** (ciclo 2): `lib/` completo — 39 arquivos Dart
  (config, core, models, providers, services, screens, theme, widgets), `main.dart`
  e `app.dart`.
- `pubspec.yaml` / `pubspec.lock`, `analysis_options.yaml`, `.metadata`,
  `.gitattributes` e `test/widget_test.dart`.
- Schema e seed de referência do Supabase em `supabase/schema.sql` e
  `supabase/seed.sql` (dados de exemplo fictícios — nenhum dado real de cliente).
- Runners de plataforma `android/` e `windows/` (sem artefatos de build).
- `assets/characters/` e `assets/logos/` com README explicando que os materiais
  de marca não acompanham o clone público.

### Notas de segurança (clone público)
- `lib/config/app_config.dart` permanece no `.gitignore`; apenas o template
  `app_config.example.dart` é versionado.
- Excluídos do clone público: `Manual de Marca.pdf`, `referencias/`, binários de
  marca (PNG/SVG dos personagens e logos), `ADMIN.md`, `CLAUDE.md`, `PLANO.md` e
  o plano de ação (`.docx`).

### A fazer
- `flutter pub get` + `flutter analyze` sem erros num clone limpo.
- Substituir os dados mock embutidos pelos providers Riverpod ligados ao Supabase.
