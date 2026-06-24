# Contribuindo com o JueviOS

Obrigado pelo interesse! Este é o clone público (versão Collab) do sistema operacional
interno da Ju&Vi Collab.

## Como rodar localmente

```bash
flutter pub get
cp .env.example .env   # opcional — sem ele, roda em modo demo
flutter run -d windows
```

## Padrões

- **Arquitetura:** respeite a direção de dependência `screens → providers → services`.
  A UI nunca acessa o Supabase service diretamente.
- **Design system:** cores e tipografia ficam em `lib/core` (tema). Não use cores soltas
  (hardcoded) nos widgets — referencie o tema.
- **Estados:** toda tela que carrega dados precisa tratar loading, erro e vazio.
- **Análise:** rode `flutter analyze` antes de abrir o PR; zero warnings.

## Não versione

`.env`, credenciais, materiais de marca (PDF/PSD/AI) e dados de clientes. O `.gitignore`
já cobre os casos comuns — confira antes de commitar.

## Commits e PRs

- Mensagens de commit no imperativo e descritivas (ex.: `Conecta tela de CRM ao provider`).
- Um PR por mudança lógica. Descreva o que muda e por quê.
