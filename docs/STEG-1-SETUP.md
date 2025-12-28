# Steg 1: Grundläggande Setup

Detta steg förbereder din utvecklingsmiljö och de externa tjänster du behöver.

## 1.1 Installera Node.js (på din utvecklingsdator)

### Linux (Ubuntu/Debian)
```bash
# Installera Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verifiera installation
node --version  # Ska visa v20.x.x
npm --version   # Ska visa 10.x.x
```

### macOS
```bash
# Använd Homebrew
brew install node@20

# Verifiera installation
node --version
npm --version
```

### Windows
1. Ladda ner installationsprogram från https://nodejs.org/
2. Kör installationsprogrammet
3. Öppna Command Prompt och kör:
```cmd
node --version
npm --version
```

## 1.2 Skapa Supabase-projekt

1. **Gå till Supabase**
   - Öppna https://supabase.com i din webbläsare
   - Klicka på "Start your project"
   - Logga in med GitHub

2. **Skapa nytt projekt**
   ```
   - Klicka på "New Project"
   - Projekt-namn: mat-lager
   - Databas-lösenord: [Välj ett starkt lösenord och spara det!]
   - Region: North Europe (Stockholm) - närmast Sverige
   - Klicka "Create new project"
   ```
   
   *Vänta 2-3 minuter medan projektet skapas...*

3. **Hämta API-nycklar**
   ```
   - När projektet är klart, gå till Settings (längst ner i sidomenyn)
   - Klicka på "API" under Project Settings
   - Kopiera följande värden:
     * Project URL (börjar med https://xxxxx.supabase.co)
     * anon/public key (en lång sträng som börjar med eyJh...)
   
   - Spara dessa i en textfil temporärt
   ```

4. **Skapa databas-tabeller**
   ```
   - Gå till "SQL Editor" i sidomenyn
   - Klicka på "New query"
   - Kopiera innehållet från sql/supabase-schema.sql (vi skapar den i nästa steg)
   - Kör queryn genom att klicka "Run"
   ```

5. **Aktivera Email Authentication**
   ```
   - Gå till "Authentication" i sidomenyn
   - Klicka på "Providers"
   - Leta upp "Email" och se till att den är aktiverad
   - Scrolla ner till "Email Templates" 
   - Välj "Magic Link" och anpassa om du vill
   - Klicka "Save"
   ```

6. **Konfigurera Row Level Security (RLS)**
   ```
   - Detta görs automatiskt via SQL-schemat
   - RLS säkerställer att användare bara ser sin egen data
   ```

## 1.3 Skapa Google AI Studio-projekt och få Gemini API-nyckel

1. **Gå till Google AI Studio**
   - Öppna https://aistudio.google.com i din webbläsare
   - Logga in med ditt Google-konto

2. **Skapa API-nyckel**
   ```
   - Klicka på "Get API key" i övre menyn
   - Klicka på "Create API key"
   - Välj "Create API key in new project"
   - Kopiera API-nyckeln som visas
   - Spara den i en textfil temporärt
   ```

3. **Testa API-nyckeln (valfritt)**
   ```bash
   curl -X POST \
     -H "Content-Type: application/json" \
     -d '{
       "contents": [{
         "parts": [{"text": "Hej, fungerar du?"}]
       }]
     }' \
     "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=DIN_API_NYCKEL"
   ```

## 1.4 Sätt upp projektet lokalt

1. **Klona GitHub-repot**
   ```bash
   # Gå till din projektmapp
   cd ~/projekt  # eller där du vill ha projektet
   
   # Klona repot
   git clone https://github.com/Smuts-One/mat-lager2.0.git
   cd mat-lager2.0
   ```

2. **Installera npm-paket**
   ```bash
   # Detta installerar alla dependencies från package.json
   npm install
   ```

3. **Skapa .env.local-fil**
   ```bash
   # Skapa filen
   touch .env.local
   
   # Öppna i en texteditor (använd nano, vim, eller valfri editor)
   nano .env.local
   ```
   
   Lägg in följande innehåll (ersätt med dina nycklar från steg 1.2 och 1.3):
   ```
   VITE_SUPABASE_URL=https://xxxxx.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   VITE_GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```
   
   Spara filen:
   - I nano: Ctrl+O, Enter, Ctrl+X
   - I vim: Esc, :wq, Enter

4. **Lägg .env.local i .gitignore**
   ```bash
   # Säkerställ att .env.local inte committas
   echo ".env.local" >> .gitignore
   ```

5. **Verifiera konfiguration**
   ```bash
   # Kolla att .env.local existerar
   ls -la .env.local
   
   # Kolla att den innehåller rätt variabler (utan att visa nycklarna)
   grep "VITE_" .env.local | cut -d'=' -f1
   # Ska visa:
   # VITE_SUPABASE_URL
   # VITE_SUPABASE_ANON_KEY
   # VITE_GEMINI_API_KEY
   ```

## 1.5 Skapa databas-schema

1. **Skapa sql-mapp**
   ```bash
   mkdir -p sql
   ```

2. **Skapa schema-fil**
   ```bash
   # Skapa filen
   touch sql/supabase-schema.sql
   
   # Öppna i editor
   nano sql/supabase-schema.sql
   ```

3. **Kopiera SQL-schema**
   - Kopiera innehållet från den ursprungliga mat-lager-projektets schema
   - Eller använd det förenklade schemat som finns i detta repo
   - Spara filen

4. **Kör schemat i Supabase**
   ```
   - Gå tillbaka till Supabase Dashboard
   - SQL Editor > New query
   - Kopiera hela innehållet från sql/supabase-schema.sql
   - Klicka "Run"
   - Verifiera att alla tabeller skapades:
     * Gå till "Table Editor"
     * Du ska se: profiles, inventory_items, consumption_logs, 
       cooking_sessions, cooking_session_items, recipes, 
       recipe_ingredients, meal_plan, shopping_list
   ```

## 1.6 Testa att projektet startar

```bash
# Starta utvecklingsservern
npm run dev

# Du ska se något liknande:
#   VITE v6.x.x  ready in xxx ms
#   ➜  Local:   http://localhost:5173/
#   ➜  Network: use --host to expose
```

Öppna http://localhost:5173/ i din webbläsare. Du ska se inloggningssidan för MatLager.

## Felsökning

### Problem: "command not found: node"
**Lösning**: Node.js är inte installerat eller inte i din PATH.
- Följ installationsinstruktionerna i steg 1.1 igen
- Starta om terminalen efter installation

### Problem: "Cannot find module 'vite'"
**Lösning**: npm-paketen är inte installerade.
```bash
npm install
```

### Problem: "Failed to fetch from Supabase"
**Lösning**: 
- Kontrollera att VITE_SUPABASE_URL och VITE_SUPABASE_ANON_KEY är korrekta i .env.local
- Kontrollera att Supabase-projektet är aktivt (gå till dashboard)
- Kör om utvecklingsservern: Ctrl+C, sedan `npm run dev`

### Problem: "Gemini API error"
**Lösning**:
- Kontrollera att VITE_GEMINI_API_KEY är korrekt i .env.local
- Verifiera att API-nyckeln är aktiv i Google AI Studio
- Vissa funktioner fungerar utan Gemini (lagerhantering, matlagning)

## Nästa steg

När du har:
- ✅ Node.js installerat
- ✅ Supabase-projekt skapat med databas-schema
- ✅ Google AI Studio API-nyckel
- ✅ Projekt klonat och konfigurerat
- ✅ Utvecklingsserver startar utan fel

...kan du fortsätta till **STEG-2-UTVECKLING.md** för att implementera funktionaliteten.
