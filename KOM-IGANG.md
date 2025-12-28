# Kom Igång - Visuell Guide

En visuell översikt av hur du sätter upp MatLager 2.0.

## 🎯 Mål

```
┌─────────────────────────────────────────────────────┐
│  Du vill ha en webbapp för att hantera matvaror    │
│  som körs hemma på Raspberry Pi och är tillgänglig │
│  från mobilen när du är i mataffären               │
└─────────────────────────────────────────────────────┘
```

## 🗺️ Översiktsflöde

```
START
  │
  ├─> 1. FÖRBEREDELSER (30 min)
  │     ├─ Skapa Supabase-konto
  │     ├─ Skapa Google AI Studio-konto
  │     └─ Installera Node.js
  │
  ├─> 2. LOKAL UTVECKLING (1 timme)
  │     ├─ Klona projekt
  │     ├─ Konfigurera .env.local
  │     ├─ Kör SQL-schema i Supabase
  │     ├─ Testa lokalt (npm run dev)
  │     └─ Verifiera att inloggning fungerar
  │
  ├─> 3. RASPBERRY PI SETUP (2-3 timmar)
  │     ├─ Installera Raspberry Pi OS
  │     ├─ Installera Node.js + nginx
  │     ├─ Klona projekt till Pi:n
  │     ├─ Bygg produktionsversion
  │     └─ Konfigurera nginx
  │
  └─> 4. FJÄRRÅTKOMST (1-2 timmar)
        ├─ Alternativ A: Tailscale (ENKELT)
        │   ├─ Installera på Pi
        │   ├─ Installera på mobil
        │   └─ Klart!
        │
        └─ Alternativ B: SSH-tunnel + VPS
            ├─ Skaffa VPS
            ├─ Konfigurera SSH-tunnel
            └─ Sätt upp nginx på VPS

KLART! 🎉
```

## 📊 Systemöversikt

```
┌─────────────────────────────────────────────────────────────┐
│                     DIN SMARTPHONE                           │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Webbläsare öppnad till:                           │    │
│  │  • http://100.x.x.x (Tailscale)                    │    │
│  │  • eller https://din-vps.com (VPS)                 │    │
│  └────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Internet (krypterat)
                         │
┌────────────────────────┴────────────────────────────────────┐
│                  RASPBERRY PI (hemma)                        │
│  ┌────────────────────────────────────────────────────┐    │
│  │  nginx                                             │    │
│  │  ↓                                                 │    │
│  │  Statiska filer från /dist                        │    │
│  │  (HTML, CSS, JavaScript)                          │    │
│  └────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ API-anrop
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
┌───────────────┐              ┌─────────────────┐
│   SUPABASE    │              │  GOOGLE GEMINI  │
│   (Database   │              │  (AI Assistant) │
│    + Auth)    │              └─────────────────┘
└───────────────┘
```

## 🔄 Dataflöde - Exempel: Lägg till vara

```
1. ANVÄNDARE
   "Jag vill lägga till 2 liter mjölk"
   │
   │ [Klickar på + knappen]
   │ [Fyller i formulär]
   │ [Klickar "Spara"]
   │
   ▼
2. FRONTEND (React på Pi)
   - Validerar input
   - Anropar: supabase.from('inventory_items').insert(...)
   │
   │ [HTTPS till Supabase]
   │
   ▼
3. SUPABASE
   - Verifierar autentisering (JWT-token)
   - Kontrollerar RLS-policy (är du inloggad?)
   - Sparar i PostgreSQL-databas
   - Skickar realtime-notifikation
   │
   │ [WebSocket tillbaka]
   │
   ▼
4. FRONTEND (alla inloggade enheter)
   - Tar emot realtime-uppdatering
   - Uppdaterar useInventory() hook
   - React re-renderar UI
   │
   ▼
5. ANVÄNDARE
   "Ser den nya varan i listan!" ✅
```

## 🔐 Säkerhetsflöde

```
┌─────────────────────────────────────────────────┐
│ Användare vill logga in                         │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 1. Anger email i appen                          │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 2. Supabase skickar magic link till email       │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 3. Användare klickar på länk                    │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 4. Supabase genererar JWT-token                 │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 5. Frontend sparar token i sessionStorage       │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 6. Alla API-anrop inkluderar token              │
│    Authorization: Bearer <token>                │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 7. Supabase verifierar token vid varje request  │
│    RLS-policies säkerställer att user_id matchar│
└─────────────────────────────────────────────────┘
```

## 📱 Användarupplevelse - Typiskt Scenario

```
MORGON (hemma):
  ┌──────────────────────────┐
  │ Kollar lagret på datorn  │
  │ Ser att mjölken tar slut │
  └──────────────────────────┘

MIDDAG (i mataffären):
  ┌──────────────────────────┐
  │ Öppnar appen på mobilen  │
  │ (via Tailscale/VPS)      │
  │ Kollar vad som behövs    │
  │ Handlar                  │
  └──────────────────────────┘

KVÄLL (hemma):
  ┌──────────────────────────┐
  │ Lägger till nya varor    │
  │ Lagar middag             │
  │ Loggar förbrukning       │
  └──────────────────────────┘

NÄSTA DAG:
  ┌──────────────────────────┐
  │ Ser statistik över       │
  │ matkostnader i veckan    │
  └──────────────────────────┘
```

## 🛠️ Teknologi-stack Visualiserad

```
┌────────────────────────────────────────────────┐
│              ANVÄNDARGRÄNSSNITT                │
│  ┌──────────────────────────────────────┐     │
│  │ React Components                     │     │
│  │ ├─ InventoryView                     │     │
│  │ ├─ CookingView                       │     │
│  │ ├─ StatsView                         │     │
│  │ └─ RecipeView                        │     │
│  └──────────────────────────────────────┘     │
│  ┌──────────────────────────────────────┐     │
│  │ Custom Hooks                         │     │
│  │ ├─ useInventory                      │     │
│  │ ├─ useSupabaseSession                │     │
│  │ └─ useConsumptionLogs                │     │
│  └──────────────────────────────────────┘     │
│  ┌──────────────────────────────────────┐     │
│  │ Styling: Tailwind CSS                │     │
│  └──────────────────────────────────────┘     │
└────────────────────────────────────────────────┘
                     │
┌────────────────────┼────────────────────────────┐
│              BUILD TOOLS                        │
│  ┌──────────────────────────────────────┐     │
│  │ Vite                                 │     │
│  │ • TypeScript → JavaScript            │     │
│  │ • Bundling                           │     │
│  │ • Minification                       │     │
│  │ • Hot Module Replacement             │     │
│  └──────────────────────────────────────┘     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────┼────────────────────────────┐
│              HOSTING                            │
│  ┌──────────────────────────────────────┐     │
│  │ Raspberry Pi 3B+                     │     │
│  │ • Raspberry Pi OS (Linux)            │     │
│  │ • nginx web server                   │     │
│  │ • Serverar /dist mapp                │     │
│  └──────────────────────────────────────┘     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────┼────────────────────────────┐
│              BACKEND SERVICES                   │
│  ┌──────────────────────────────────────┐     │
│  │ Supabase                             │     │
│  │ • PostgreSQL Database                │     │
│  │ • Authentication (JWT)               │     │
│  │ • Realtime (WebSocket)               │     │
│  │ • Row Level Security                 │     │
│  └──────────────────────────────────────┘     │
│  ┌──────────────────────────────────────┐     │
│  │ Google Gemini                        │     │
│  │ • AI Recipe Suggestions              │     │
│  │ • Ingredient Recognition             │     │
│  └──────────────────────────────────────┘     │
└─────────────────────────────────────────────────┘
```

## ⏱️ Tidsestimat

```
SNABBASTE VÄGEN (endast lokal testning):
├─ Förberedelser: 30 min
├─ Setup: 30 min
└─ Test: 15 min
TOTAL: ~1 timme 15 min

KOMPLETT SETUP (med Pi + fjärråtkomst):
├─ Förberedelser: 30 min
├─ Lokal setup: 1 timme
├─ Pi deployment: 2-3 timmar
└─ Fjärråtkomst: 1-2 timmar
TOTAL: ~5-7 timmar

OBS: Första gången tar det längre tid. 
Nästa gång går det mycket snabbare!
```

## 💰 Kostnadsöversikt

```
┌─────────────────────────────────────────┐
│ ENGÅNGSKOSTNADER                        │
├─────────────────────────────────────────┤
│ Raspberry Pi 3B+ kit: ~700 SEK          │
│ (eller använd befintlig)                │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ MÅNADSKOSTNADER                         │
├─────────────────────────────────────────┤
│ Supabase Free Tier: 0 SEK               │
│ Google Gemini Free: 0 SEK               │
│ Tailscale Personal: 0 SEK               │
│ Elektricitet (Pi): ~1-2 SEK             │
├─────────────────────────────────────────┤
│ TOTAL: ~1-2 SEK/månad                   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ ALTERNATIV: Med VPS (om ej Tailscale)   │
├─────────────────────────────────────────┤
│ VPS hosting: 40-60 SEK/månad            │
│ (DigitalOcean, Hetzner, etc.)           │
└─────────────────────────────────────────┘
```

## 🎓 Vad lär du dig?

```
WEBB-TEKNOLOGIER
├─ React (modern UI-framework)
├─ TypeScript (typsäkert JavaScript)
├─ Vite (snabbt build-tool)
└─ Tailwind CSS (utility-first CSS)

BACKEND & DATABAS
├─ PostgreSQL (SQL-databas)
├─ Supabase (Backend-as-a-Service)
├─ Row Level Security (RLS)
└─ Realtime subscriptions

DEPLOYMENT & DEVOPS
├─ Linux (Raspberry Pi OS)
├─ nginx (web server)
├─ Systemd (service management)
└─ Git (versionshantering)

NÄTVERK & SÄKERHET
├─ SSH (säker fjärråtkomst)
├─ VPN (Tailscale/WireGuard)
├─ HTTPS/SSL
└─ Autentisering (JWT tokens)
```

## 📚 Nästa Steg

```
DU ÄR HÄR → [START]
              │
              ├─> Läs PROJEKTPLAN.md (översikt)
              │
              ├─> Följ STEG-1-SETUP.md (grundsetup)
              │
              ├─> Följ STEG-2-UTVECKLING.md (kod)
              │
              ├─> Följ STEG-3-DEPLOYMENT.md (Pi)
              │
              └─> Följ STEG-4-FJARRATKOMST.md (internet)
                  │
                  └─> [KLART!] 🎉
```

## 🤔 Osäker på något?

1. **Börja enkelt**: Testa lokalt först (hoppa över Pi)
2. **Läs FAQ.md**: Svar på vanliga frågor
3. **Använd CHECKLISTA.md**: Bocka av steg för steg
4. **Fråga**: Öppna GitHub Issue om du fastnar

**Lycka till!** 🚀
