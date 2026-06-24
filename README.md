<div align="center">

# JueviOS

**Sistema operacional interno da Ju&Vi Collab — versão Collab (open-source)**

Centraliza projetos, CRM, financeiro, portfólio e comunicação do estúdio criativo
num único app multiplataforma, com sincronização em tempo real entre os dispositivos da equipe.

`Flutter` · `Supabase (Postgres + Realtime)` · `Riverpod` · `GoRouter`

</div>

---

## O que é

A **Ju&Vi Collab** é um estúdio criativo. O **JueviOS** é o "sistema operacional" do estúdio:
em vez de pular entre planilhas, apps de tarefas e mensagens soltas, a equipe trabalha num único
lugar onde projeto, cliente, dinheiro e portfólio conversam entre si e sincronizam em tempo real.

Esta é a **versão Collab (clone público)**. Ela **não** inclui credenciais, materiais de marca
nem dados sensíveis — qualquer pessoa pode clonar, apontar para o seu próprio projeto Supabase e rodar.

## Stack

| Camada | Tecnologia |
|--------|-----------|
| App | Flutter 3.41+ / Dart 3.11+ |
| Estado | Riverpod |
| Rotas | GoRouter |
| Backend | Supabase — Postgres + Realtime |
| Gráficos | fl_chart |
| Plataformas | Windows desktop · Android |
| Automação | n8n (sync opcional com Notion) |

## As 10 telas

1. **Splash** — abertura com os personagens da marca + entrar
2. **Dashboard** — métricas, gráfico, projetos recentes e atividade
3. **Atividade** — feed cronológico de eventos do estúdio
4. **Notificações** — alertas por tipo, marcar como lido
5. **CRM** — contatos, status, busca e detalhe lateral
6. **Projeto** — cork board com sticky notes e polaroids
7. **Redes Sociais** — calendário de conteúdo
8. **Perfil Collab** — avatar, personagem e stats pessoais
9. **Portfólio** — grid de polaroids + filtros
10. **Equipe** — cards de colaboradores

Detalhes de arquitetura em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).
Roadmap em [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Layout adaptativo

| Largura | Dispositivo | Navegação | Layout |
|---------|-------------|-----------|--------|
| < 600px | Android | Bottom bar | Coluna única |
| 600–900px | Tablet | Navigation Rail | 2 colunas |
| > 900px | Windows | Nav Pill lateral | Grid 3 colunas |

## Começando

> **Pré-requisito:** Flutter 3.41+ instalado ([guia oficial](https://docs.flutter.dev/get-started/install)).

```bash
git clone https://github.com/juevicollab-sys/JueviOS.git
cd JueviOS
cp .env.example .env                               # credenciais do Supabase (opcional p/ demo)
cp lib/config/app_config.example.dart lib/config/app_config.dart   # obrigatório: a app importa AppConfig
flutter pub get
flutter run -d windows      # ou: flutter run -d <seu-device-android>
```

> `lib/config/app_config.dart` está no `.gitignore`, então **não** vem no clone. Copie o
> template acima antes do primeiro `flutter run`. Sem credenciais reais preenchidas, o app
> sobe em modo de demonstração.

Sem um `.env` configurado, o app roda em **modo de demonstração** com dados de exemplo —
ótimo para explorar as telas antes de ligar um backend real.

### Configurando o Supabase

1. Crie um projeto gratuito em [supabase.com](https://supabase.com).
2. Rode o schema do banco (ver `docs/ARCHITECTURE.md` → seção *Banco de dados*).
3. Habilite **Realtime** em todas as tabelas.
4. Copie a *Project URL* e a *anon key* para o seu `.env`.

## Contribuindo

Veja [`CONTRIBUTING.md`](CONTRIBUTING.md). Issues e PRs são bem-vindos.

## Licença

[MIT](LICENSE) — use, modifique e distribua livremente.
