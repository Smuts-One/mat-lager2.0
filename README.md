# MatLager 2.0

En förenklad och lättunderhållen version av MatLager - en webbapp för att hantera matvaror, laga mat och spåra kostnader.

## 🎯 Vad är MatLager?

MatLager hjälper dig att:
- **Hantera lagervaror** - Håll koll på vad du har hemma
- **Laga mat och logga förbrukning** - Registrera vad du använder
- **Spåra kostnader** - Se hur mycket pengar du spenderar
- **Spara recept** - Dina favoritrecept på ett ställe
- **Planera måltider** - Vad ska vi äta i veckan?
- **Skapa inköpslistor** - Baserat på recept och planering

## 🚀 Snabbstart

### 1. Läs projektplanen
Börja med att läsa **[PROJEKTPLAN.md](PROJEKTPLAN.md)** för en översikt av projektet.

### 2. Följ steg-för-steg-guiderna

Alla instruktioner finns i `docs/`-mappen:

1. **[STEG-1-SETUP.md](docs/STEG-1-SETUP.md)** - Grundläggande setup (Node.js, Supabase, API-nycklar)
2. **[STEG-2-UTVECKLING.md](docs/STEG-2-UTVECKLING.md)** - Implementera funktionaliteten
3. **[STEG-3-DEPLOYMENT.md](docs/STEG-3-DEPLOYMENT.md)** - Deploya till Raspberry Pi
4. **[STEG-4-FJARRATKOMST.md](docs/STEG-4-FJARRATKOMST.md)** - Gör appen tillgänglig från internet

### 3. Snabbversion (om du bara vill testa lokalt)

```bash
# Klona repot
git clone https://github.com/Smuts-One/mat-lager2.0.git
cd mat-lager2.0

# Installera dependencies
npm install

# Skapa .env.local med dina API-nycklar (se STEG-1-SETUP.md)
nano .env.local

# Starta utvecklingsservern
npm run dev
```

Öppna http://localhost:5173/ i din webbläsare.

## 🏗️ Teknisk Stack

- **Frontend**: React + TypeScript + Vite + Tailwind CSS
- **Backend & Databas**: Supabase (PostgreSQL + Auth + Realtime)
- **AI**: Google Gemini (för receptförslag och smart funktionalitet)
- **Hosting**: Raspberry Pi 3B+ + nginx
- **Fjärråtkomst**: Tailscale eller SSH-tunnel

## 📁 Projektstruktur

```
mat-lager2.0/
├── docs/                    # Steg-för-steg-guider
│   ├── STEG-1-SETUP.md
│   ├── STEG-2-UTVECKLING.md
│   ├── STEG-3-DEPLOYMENT.md
│   └── STEG-4-FJARRATKOMST.md
├── sql/                     # Databasschema
│   └── supabase-schema.sql
├── src/                     # Källkod (skapas under utveckling)
│   ├── components/
│   ├── hooks/
│   ├── services/
│   └── types.ts
├── PROJEKTPLAN.md          # Översikt och planering
└── README.md               # Denna fil
```

## 🔑 Förutsättningar

- Node.js 18+ 
- Raspberry Pi 3B+ (för deployment)
- Supabase-konto (gratis)
- Google AI Studio-konto (gratis)

## 💡 Varför en "2.0"-version?

Den ursprungliga versionen blev för komplex med:
- Docker-containers
- Cloudflare Tunnels
- Många lager av konfiguration

**Mat-lager 2.0** är:
- ✅ Enklare att sätta upp
- ✅ Lättare att underhålla
- ✅ Färre beroenden
- ✅ Mer transparent (du förstår hur allt fungerar)

## 🤝 Bidra

Detta är ett personligt projekt, men feedback och förbättringsförslag är välkomna!

## 📄 Licens

Detta projekt är för personligt bruk. Använd gärna koden som inspiration för dina egna projekt.

## 🆘 Hjälp och Support

Om du stöter på problem:
1. Kolla felsökningssektionen i respektive steg-guide
2. Öppna en Issue på GitHub
3. Kontrollera att alla API-nycklar är korrekt konfigurerade

## 🎉 Kom igång!

Börja med att läsa **[PROJEKTPLAN.md](PROJEKTPLAN.md)** och följ sedan guiderna i `docs/`-mappen.

Lycka till! 🚀
