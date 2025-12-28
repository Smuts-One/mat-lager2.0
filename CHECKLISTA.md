# Checklista - MatLager 2.0 Implementation

Använd denna checklista för att hålla koll på ditt framsteg.

## 📋 Fas 1: Förberedelser och Setup

### Förutsättningar
- [ ] Node.js 18+ installerat på utvecklingsdatorn
  ```bash
  node --version  # Ska visa v18.x eller senare
  ```
- [ ] Git installerat
  ```bash
  git --version
  ```
- [ ] Textredigerare installerad (VS Code, Sublime, nano, etc.)
- [ ] GitHub-konto skapat

### Supabase Setup
- [ ] Konto skapat på https://supabase.com
- [ ] Nytt projekt skapat (namn: mat-lager)
- [ ] Region vald: North Europe (Stockholm)
- [ ] Project URL kopierad
- [ ] Anon/Public Key kopierad
- [ ] SQL-schema kört i SQL Editor (från `sql/supabase-schema.sql`)
- [ ] Tabeller verifierade i Table Editor:
  - [ ] profiles
  - [ ] inventory_items
  - [ ] consumption_logs
  - [ ] cooking_sessions
  - [ ] cooking_session_items
  - [ ] recipes
  - [ ] recipe_ingredients
  - [ ] meal_plan
  - [ ] shopping_list
- [ ] Email Authentication aktiverad
- [ ] Row Level Security verifierad (policies synliga i Dashboard)

### Google AI Studio Setup
- [ ] Konto skapat på https://aistudio.google.com
- [ ] API-nyckel genererad
- [ ] API-nyckel sparad säkert

### Lokal Projekt Setup
- [ ] Repository klonat
  ```bash
  git clone https://github.com/Smuts-One/mat-lager2.0.git
  ```
- [ ] Dependencies installerade
  ```bash
  npm install
  ```
- [ ] `.env.local` skapad med alla nycklar
- [ ] `.env.local` finns i `.gitignore`
- [ ] Utvecklingsserver startar utan fel
  ```bash
  npm run dev
  ```
- [ ] Kan öppna http://localhost:5173 i webbläsaren
- [ ] Kan se inloggningssidan

## 📋 Fas 2: Grundläggande Funktionalitet

### Autentisering
- [ ] Kan skicka magic link till email
- [ ] Får email från Supabase
- [ ] Kan logga in via magic link
- [ ] Session sparas (behöver inte logga in varje gång)
- [ ] Kan logga ut

### Lagerhantering
- [ ] Kan lägga till vara manuellt i Supabase
- [ ] Varan syns i appen automatiskt (realtime)
- [ ] Kan se alla lagervaror
- [ ] Kan ta bort en vara
- [ ] Ändringar reflekteras direkt i UI

### Testdata
- [ ] Minst 3 testvaror tillagda
- [ ] Testvaror har olika kategorier
- [ ] Testvaror har pris-information

## 📋 Fas 3: Raspberry Pi Setup (Valfritt)

### Hårdvara och OS
- [ ] Raspberry Pi 3B+ (eller senare) förberedd
- [ ] MicroSD-kort (minst 16GB)
- [ ] Raspberry Pi OS flashat på SD-kort
- [ ] SSH aktiverat
- [ ] WiFi konfigurerat
- [ ] Pi:n startar och ansluter till nätverk
- [ ] Kan ansluta till Pi via SSH
- [ ] Pi:ns IP-adress identifierad

### Programvara på Pi:n
- [ ] System uppdaterat (`sudo apt update && sudo apt upgrade`)
- [ ] Node.js 18+ installerat på Pi:n
- [ ] nginx installerat
- [ ] Git installerat
- [ ] Repository klonat till `~/apps/mat-lager2.0`
- [ ] Dependencies installerade på Pi:n (`npm install`)
- [ ] `.env.local` skapad på Pi:n

### Build och Deployment
- [ ] Produktionsbygge skapat (`npm run build`)
- [ ] `dist/`-mapp existerar och innehåller filer
- [ ] nginx-konfiguration skapad (`/etc/nginx/sites-available/matlager`)
- [ ] nginx-site aktiverad
- [ ] nginx konfiguration testad (`sudo nginx -t`)
- [ ] nginx startat/reloaded
- [ ] Kan öppna http://[PI_IP] från annan enhet på samma nätverk
- [ ] Inloggning fungerar på Pi-deployad version

### Automatisering
- [ ] Update-script skapat (`~/apps/mat-lager2.0/update.sh`)
- [ ] Update-script är körbart (`chmod +x`)
- [ ] Update-script testat och fungerar
- [ ] nginx startar automatiskt vid omstart
- [ ] Backup-script skapat (valfritt)

## 📋 Fas 4: Fjärråtkomst (Valfritt)

### Alternativ A: Tailscale (Rekommenderat)
- [ ] Tailscale-konto skapat
- [ ] Tailscale installerat på Raspberry Pi
- [ ] Pi:n auktoriserad i Tailscale-nätverk
- [ ] Tailscale IP-adress identifierad (t.ex. 100.x.x.x)
- [ ] Tailscale installerat på mobil/laptop
- [ ] Kan nå appen via Tailscale IP från annan enhet
- [ ] MagicDNS aktiverat (valfritt)
- [ ] Kan nå appen via hostname (t.ex. http://matlager)
- [ ] Tailscale startar automatiskt vid omstart

### Alternativ B: SSH-tunnel + VPS
- [ ] VPS skaffad och uppsatt
- [ ] VPS uppdaterad (`apt update && apt upgrade`)
- [ ] nginx installerat på VPS
- [ ] SSH-nyckel genererad på Pi:n
- [ ] SSH-nyckel kopierad till VPS
- [ ] Kan SSH:a till VPS utan lösenord
- [ ] autossh installerat på Pi:n
- [ ] autossh systemd-service skapad
- [ ] autossh-service aktiverad och startad
- [ ] Tunnel fungerar (kan nå port 8080 på VPS)
- [ ] nginx-config skapad på VPS
- [ ] Kan nå appen via VPS IP-adress
- [ ] (Valfritt) Domän pekar till VPS
- [ ] (Valfritt) SSL-certifikat installerat

## 📋 Fas 5: Test och Verifiering

### Funktionalitet
- [ ] Kan logga in från olika enheter
- [ ] Kan lägga till lagervaror
- [ ] Kan ta bort lagervaror
- [ ] Ändringar syns på alla inloggade enheter (realtime)
- [ ] Ingen kan se andra användares data (RLS-test)

### Prestanda
- [ ] Appen laddar snabbt (< 3 sekunder)
- [ ] UI är responsiv
- [ ] Inga JavaScript-fel i Console
- [ ] Inga 404-fel i Network-tab

### Säkerhet
- [ ] API-nycklar finns inte i Git-historik
- [ ] `.env.local` är i `.gitignore`
- [ ] Kan inte komma åt andras data
- [ ] HTTPS fungerar (om via VPS med SSL)

### Stabilitet
- [ ] Pi:n körs stabilt i 24 timmar
- [ ] Appen är åtkomlig efter Pi-omstart
- [ ] Tunnel/Tailscale återansluter automatiskt

## 📋 Fas 6: Dokumentation och Underhåll

### Dokumentation
- [ ] Kommentarer i eventuell egen kod
- [ ] README uppdaterad om du gjort ändringar
- [ ] Egna anteckningar om custom-konfiguration

### Backup
- [ ] Supabase backup-strategi bestämd
- [ ] Manuell backup testad i Supabase Dashboard
- [ ] Backup-schema upprättat (månatligt rekommenderat)
- [ ] `.env.local` backupad säkert (inte i Git!)

### Underhåll
- [ ] Uppdateringsrutin etablerad:
  - [ ] Veckovis: Kolla loggar
  - [ ] Månadsvis: `sudo apt update && apt upgrade` på Pi:n
  - [ ] Månadsvis: `npm update` i projektet
  - [ ] Kvartalsvis: Full funktionstest
- [ ] Monitoring-rutin etablerad (kolla att allt fungerar)

## 🎉 Klart!

Om du har bockat av allt ovanför - grattis! Du har en fullt fungerande MatLager-app.

### Nästa steg (valfritt)
- [ ] Lägg till fler komponenter från originalet (Scanner, CookingView, etc.)
- [ ] Anpassa styling efter eget tycke
- [ ] Integrera med ytterligare tjänster
- [ ] Bjud in familjemedlemmar/rumskamrater att använda
- [ ] Dela dina erfarenheter eller förbättringar som Pull Request

## 📞 Hjälp och Support

Om något inte fungerar:
1. Kolla motsvarande "Felsökning"-sektion i guiderna
2. Läs [FAQ.md](FAQ.md)
3. Öppna en Issue på GitHub
4. Kolla Supabase/React-dokumentation

**Lycka till!** 🚀
