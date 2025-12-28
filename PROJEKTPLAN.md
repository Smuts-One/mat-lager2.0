# MatLager 2.0 - Projektplan

## Översikt

Detta är en förenklad version av MatLager-appen som ska köras på en Raspberry Pi 3B+ och vara tillgänglig över internet. Fokus ligger på enkelhet och underhållbarhet.

## Vad är MatLager?

MatLager är en webbapp för att:
- **Hantera matvaror i ditt kylskåp/skafferi** - lägg till varor, se vad du har hemma
- **Laga mat och logga förbrukning** - registrera vad du använder när du lagar mat
- **Spåra kostnader** - se hur mycket pengar du spenderar på mat
- **Hantera recept** - spara dina favoritrecept
- **Planera måltider** - planera vad du ska äta
- **Skapa inköpslistor** - baserat på recept och planering

## Teknisk Arkitektur (Förenklad)

### Frontend
- **React** med **Vite** - snabb och modern utveckling
- **TypeScript** - typsäkerhet
- **Tailwind CSS** - enkel styling utan extra CSS-filer

### Backend & Databas
- **Supabase** (gratis tier) - hanterar:
  - PostgreSQL databas
  - Autentisering (email magic link)
  - Realtime uppdateringar
  - API utan att behöva skriva egen backend-kod

### AI-integration
- **Google Gemini** (gratis tier) - för receptförslag och smart funktionalitet

### Hosting
- **Frontend**: Körs direkt på Raspberry Pi med enkel HTTP-server (nginx eller http-server)
- **Fjärråtkomst**: SSH-tunnel med autossh (enklare än Docker/Cloudflare)

## Varför är detta enklare än förra versionen?

1. **Ingen Docker** - kör Node.js/nginx direkt på Pi:n
2. **Ingen Cloudflare Tunnel** - använd SSH-tunnel eller Tailscale istället
3. **Supabase istället för egen backend** - slipp konfigurera databas och API
4. **Färre lager** - mindre att felsöka

## Förutsättningar

### Hårdvara
- Raspberry Pi 3B+ med Raspberry Pi OS (64-bit rekommenderas)
- MicroSD-kort (minst 16GB)
- Stabil internetanslutning
- Strömförsörjning

### Mjukvara som behöver installeras
- Node.js (v18 eller senare)
- nginx (webbserver)
- git
- autossh (för stabil SSH-tunnel)

### Externa tjänster (alla med gratis tier)
- Supabase-konto (databas & auth)
- Google AI Studio-konto (Gemini API)
- GitHub-konto (för versionshantering)

## Projektstruktur

```
mat-lager2.0/
├── README.md
├── PROJEKTPLAN.md
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.js
├── postcss.config.js
├── index.html
├── src/
│   ├── App.tsx
│   ├── main.tsx
│   ├── index.css
│   ├── components/
│   │   ├── InventoryView.tsx
│   │   ├── Scanner.tsx
│   │   ├── CookingView.tsx
│   │   ├── StatsView.tsx
│   │   ├── RecipeView.tsx
│   │   ├── HistoryView.tsx
│   │   └── ManualConsumptionLogModal.tsx
│   ├── hooks/
│   │   ├── useSupabaseSession.ts
│   │   ├── useInventory.ts
│   │   ├── useConsumptionLogs.ts
│   │   └── useCookingSessions.ts
│   ├── services/
│   │   ├── supabaseClient.ts
│   │   └── geminiService.ts
│   └── types.ts
├── sql/
│   └── supabase-schema.sql
└── docs/
    ├── STEG-1-SETUP.md
    ├── STEG-2-UTVECKLING.md
    ├── STEG-3-DEPLOYMENT.md
    └── STEG-4-FJARRATKOMST.md
```

## Implementationsplan

### Fas 1: Grundläggande Setup (1-2 timmar)
1. Installera Node.js på din utvecklingsdator
2. Skapa Supabase-projekt och konfigurera databas
3. Skapa Google AI Studio-projekt och få API-nyckel
4. Sätt upp projektet lokalt

### Fas 2: Utveckling (4-6 timmar)
1. Implementera grundläggande komponenter
2. Integrera Supabase för autentisering
3. Implementera lagerhantering
4. Implementera matlagningsfunktion
5. Implementera ekonomi/statistik
6. Testa lokalt

### Fas 3: Raspberry Pi Setup (2-3 timmar)
1. Installera Raspberry Pi OS
2. Installera Node.js och nginx på Pi:n
3. Klona projekt till Pi:n
4. Bygg produktionsversion
5. Konfigurera nginx
6. Testa lokalt på Pi:n

### Fas 4: Fjärråtkomst (1-2 timmar)
1. Konfigurera SSH-tunnel ELLER Tailscale
2. Testa åtkomst från extern enhet
3. Sätt upp autossh för automatisk återanslutning

## Säkerhetsaspekter

1. **Autentisering**: Supabase Email Magic Link - ingen lösenordshantering
2. **Databassäkerhet**: Row Level Security (RLS) i Supabase
3. **API-nycklar**: Lagras i miljövariabler, aldrig i kod
4. **HTTPS**: Via SSH-tunnel eller Tailscale
5. **Uppdateringar**: Regelbundet uppdatera Pi:n och npm-paket

## Underhåll

### Daglig drift
- Appen körs automatiskt när Pi:n startar
- SSH-tunnel återansluter automatiskt vid avbrott

### Veckovis
- Kolla loggar för eventuella fel
- Verifiera att allt fungerar

### Månadsvis
- Uppdatera npm-paket: `npm update`
- Uppdatera Pi:n: `sudo apt update && sudo apt upgrade`
- Backup av Supabase-data (kan göras automatiskt)

## Kostnad

- **Supabase Free Tier**: $0/månad (upp till 500MB databas, 2GB fillagring)
- **Google Gemini Free Tier**: $0/månad (upp till 60 förfrågningar per minut)
- **Elektricitet för Pi**: ~1-2 SEK/månad (ca 3W strömförbrukning)
- **Totalt**: Nästan gratis!

## Nästa steg

Fortsätt till **docs/STEG-1-SETUP.md** för detaljerade instruktioner.
