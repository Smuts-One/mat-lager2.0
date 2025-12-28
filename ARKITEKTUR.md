# MatLager 2.0 - Arkitektur och Design

## Översikt

Detta dokument beskriver den tekniska arkitekturen för MatLager 2.0 - en förenklad version jämfört med originalet.

## Design-principer

### 1. Enkelhet framför komplexitet
- Minimalt antal verktyg och tjänster
- Direkt deployment utan containerisering
- Tydlig separation mellan frontend och backend (via Supabase)

### 2. Kostnadseffektivitet
- Alla tjänster har gratis tier som räcker för personligt bruk
- Raspberry Pi istället för molnserver = ingen månadskostnad
- Öppen källkod utan licensavgifter

### 3. Säkerhet och integritet
- All data lagras i din egen Supabase-instans
- Row Level Security (RLS) säkerställer dataseparation
- End-to-end krypterad fjärråtkomst via Tailscale

## System-arkitektur

```
┌─────────────────────────────────────────────────────────┐
│                    Användare                             │
│              (Webbläsare på mobil/dator)                 │
└─────────────────────┬───────────────────────────────────┘
                      │
                      │ HTTPS (via Tailscale eller SSH-tunnel)
                      │
┌─────────────────────┴───────────────────────────────────┐
│              Raspberry Pi 3B+ (hemma)                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │              nginx (webbserver)                    │  │
│  │         Servar statiska filer från /dist          │  │
│  └───────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
                      │
                      │ API-anrop (HTTPS)
                      │
┌─────────────────────┴───────────────────────────────────┐
│                 Supabase (molnet)                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │  PostgreSQL Database                            │   │
│  │  - inventory_items                              │   │
│  │  - consumption_logs                             │   │
│  │  - cooking_sessions                             │   │
│  │  - recipes                                      │   │
│  │  - meal_plan                                    │   │
│  │  - shopping_list                                │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Authentication (Auth)                          │   │
│  │  - Email Magic Link                             │   │
│  │  - Session Management                           │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Realtime (WebSocket)                           │   │
│  │  - Live uppdateringar när data ändras           │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
                      │
                      │ API-anrop (HTTPS)
                      │
┌─────────────────────┴───────────────────────────────────┐
│           Google AI Studio / Gemini API                  │
│  - Receptförslag baserat på lagervaror                  │
│  - Smart ingrediensigenkänning                          │
│  - Måltidsplaneringshhjälp                              │
└──────────────────────────────────────────────────────────┘
```

## Komponentarkitektur (Frontend)

### Huvudkomponenter

```
App.tsx (huvudkomponent)
├── Authentication (inloggning/utloggning)
├── Header (navigation, användarinfo)
├── Main Content Area
│   ├── InventoryView (lagerlista)
│   ├── RecipeView (receptlista)
│   ├── HistoryView (historik)
│   ├── CookingView (matlagningsflöde)
│   └── StatsView (statistik och ekonomi)
├── Modals
│   ├── Scanner (lägg till varor)
│   └── ManualConsumptionLogModal (manuell logg)
└── Bottom Navigation (tabbar)
```

### Custom Hooks

```
useSupabaseSession
├── Hanterar autentiseringstillstånd
├── Lyssnar på auth-ändringar
└── Returnerar session-objekt

useInventory(userId)
├── Hämtar lagervaror från Supabase
├── Prenumererar på realtime-uppdateringar
└── Returnerar items[], loading, error, refresh()

useConsumptionLogs(userId)
├── Hämtar förbrukningsloggar
├── Prenumererar på realtime-uppdateringar
└── Returnerar logs[], loading, error, addLog()

useCookingSessions(userId)
├── Hanterar matlagningssessioner
└── Returnerar createSession(), addSessionItem()
```

### Services

```
supabaseClient.ts
└── Skapar och exporterar Supabase-klient

geminiService.ts (valfritt, för framtida funktioner)
└── Integration med Google Gemini API
```

## Dataflöde

### 1. Användaren loggar in
```
1. Användare anger email
2. Frontend anropar supabase.auth.signInWithOtp()
3. Supabase skickar magisk länk till email
4. Användare klickar på länk
5. Frontend får session-token
6. useSupabaseSession() uppdateras
7. App renderar huvudinnehåll
```

### 2. Hämta lagervaror
```
1. useInventory(userId) hook aktiveras
2. Supabase query: SELECT * FROM inventory_items WHERE user_id = ?
3. RLS-policy verifierar att användaren äger datan
4. Data returneras till frontend
5. Realtime-subscription sätts upp för live-uppdateringar
```

### 3. Lägga till vara
```
1. Användare fyller i formulär
2. Frontend: supabase.from('inventory_items').insert(...)
3. Supabase verifierar RLS-policy
4. Data sparas i databas
5. Realtime-notification skickas
6. useInventory() får uppdatering automatiskt
7. UI uppdateras
```

### 4. Laga mat och dra av ingredienser
```
1. Användare väljer ingredienser och mängder
2. Frontend skapar cooking_session
3. Frontend lägger till cooking_session_items
4. Frontend uppdaterar inventory_items (minskar quantity)
5. Frontend skapar consumption_logs
6. Alla operationer wrappar i transaction-logik
7. UI uppdateras via realtime
```

## Säkerhet

### Row Level Security (RLS)

Alla tabeller har RLS aktiverat med policies som:

```sql
-- Exempel: Användare kan bara se sina egna lagervaror
CREATE POLICY "Users can view own inventory" ON inventory_items
  FOR SELECT USING (auth.uid() = user_id);
```

Detta betyder:
- Användare A kan INTE se användare B:s data
- Även om API-nyckeln läcker kan ingen se andras data
- Supabase enforcar policies på databasnivå

### API-nycklar

- **Supabase Anon Key**: Publikt, men skyddas av RLS
- **Gemini API Key**: Endast för AI-anrop, ingen känslig data exponeras

### HTTPS & Kryptering

- **Tailscale**: WireGuard-kryptering (end-to-end)
- **SSH-tunnel**: SSH-kryptering
- **Supabase**: HTTPS för alla API-anrop

## Prestanda-optimeringar

### Frontend
- **Vite**: Snabb byggprocess och dev-server
- **Code splitting**: Automatiskt via Vite
- **Tree shaking**: Tar bort oanvänd kod
- **Minification**: I produktionsbygge

### Nginx
- **Gzip-komprimering**: Minskar storleken på överförda filer
- **Cache headers**: Statiska assets cachas i 1 år
- **HTTP/2**: Snabbare samtidiga requests

### Supabase
- **Indexering**: Alla user_id-kolumner är indexerade
- **Prepared statements**: Automatiskt via Supabase-klient
- **Connection pooling**: Hanteras av Supabase

### Realtime-optimering
- **Selektiv prenumeration**: Endast tabeller som visas
- **Filter på user_id**: Endast relevanta uppdateringar
- **Automatisk återanslutning**: Vid nätverksavbrott

## Skalbarhet

### Nuvarande gränser (Supabase Free Tier)
- **Databas**: 500 MB
- **Samtidiga användare**: 1-2 (personligt bruk)
- **API-requests**: Obegränsat (inom rimliga gränser)

### Om du behöver skala upp
1. **Fler användare**: Supabase Pro ($25/månad) ger 8 GB databas
2. **Mer data**: Lägg till fillagring för bilder
3. **Fler Raspberry Pi**: Load-balance flera Pi:ar med nginx

## Underhåll och Uppdateringar

### Automatiska processer
- **Supabase backups**: Dagliga automatiska backups
- **SSL-certifikat**: Auto-förnyelse (om du använder certbot)
- **Tailscale**: Automatisk återanslutning

### Manuella processer (rekommenderat schema)
- **Veckovis**: Kolla loggar för fel
- **Månadsvis**: `sudo apt update && sudo apt upgrade` på Pi:n
- **Månadsvis**: `npm update` för att uppdatera dependencies
- **Kvartalsvis**: Backup av Supabase-data

## Felsökning och Monitoring

### Loggar att övervaka

**På Raspberry Pi:**
```bash
# nginx access log
sudo tail -f /var/log/nginx/matlager-access.log

# nginx error log
sudo tail -f /var/log/nginx/matlager-error.log

# System logs
sudo journalctl -u nginx -f
```

**I Supabase:**
- Dashboard > Logs > API
- Dashboard > Database > Logs

### Vanliga problem och lösningar

Se felsökningssektionerna i respektive steg-guide.

## Framtida förbättringar

### Kort sikt (1-3 månader)
- Implementera Scanner-komponent med AI
- Lägga till fler receptfunktioner
- Förbättra statistik-vy med grafer

### Medellång sikt (3-6 månader)
- Måltidsplanering
- Inköpslistor med prisoptimering
- Mobilapp (React Native eller PWA)

### Lång sikt (6-12 månader)
- Dela recept mellan användare
- AI-baserade matförslag
- Integration med smarta kylskåp

## Sammanfattning

MatLager 2.0 använder en modern, enkel arkitektur som är:
- **Lätt att förstå**: Tydlig separation mellan frontend, backend och AI
- **Lätt att underhålla**: Minimalt antal beroenden och verktyg
- **Säker**: RLS, kryptering och best practices
- **Kostnadseffektiv**: Nästan gratis att drifta
- **Skalbar**: Kan växa när behoven ökar

Börja med guiderna i `docs/`-mappen för att sätta upp din egen instans!
