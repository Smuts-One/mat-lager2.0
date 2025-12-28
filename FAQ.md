# FAQ - Vanliga frågor och svar

## Allmänna frågor

### Vad är MatLager?
MatLager är en webbapp för att hantera dina matvaror hemma, spåra vad du lagar och hålla koll på dina matkostnader. Tänk det som en digital skafferi-hanterare med smart funktionalitet.

### Varför ska jag använda detta istället för en app från App Store?
- **Din data är din**: All data lagras i din egen Supabase-databas
- **Gratis**: Inga prenumerationsavgifter
- **Anpassningsbar**: Du kan ändra koden som du vill
- **Lär dig**: Perfekt för att lära sig webbutveckling

### Kostar det något?
Nästan ingenting:
- Supabase Free Tier: $0/månad (räcker för personligt bruk)
- Google Gemini Free Tier: $0/månad
- Raspberry Pi elektricitet: ~1-2 SEK/månad
- **Total: Praktiskt taget gratis!**

### Måste jag använda Raspberry Pi?
Nej! Du kan:
- Köra lokalt på din dator för utveckling/testning
- Deploya till Vercel, Netlify eller annan hosting (gratis)
- Använda en VPS istället för Raspberry Pi
- Eller bara köra appen lokalt när du behöver den

Men Raspberry Pi är billigt och perfekt för 24/7-drift hemma.

## Tekniska frågor

### Vilken programmeringserfarenhet behöver jag?
**Minimal nivå:**
- Kunna följa instruktioner
- Grundläggande terminalkunskap (kopiera/klistra in kommandon)
- Inget programmeringskrav för att bara sätta upp appen

**För att utveckla vidare:**
- JavaScript/TypeScript
- React
- SQL (grundläggande)

### Kan jag använda detta på Windows?
Ja! Guiderna täcker:
- **Lokal utveckling**: Windows, macOS, Linux
- **Raspberry Pi**: Linux (Raspberry Pi OS)

### Varför Supabase och inte egen databas?
**Fördelar med Supabase:**
- ✅ Ingen serverkonfiguration
- ✅ Automatiska backups
- ✅ Inbyggd autentisering
- ✅ Realtime-funktionalitet
- ✅ Row Level Security
- ✅ Gratis tier

**Nackdelar:**
- ⚠️ Beroende av extern tjänst
- ⚠️ Begränsningar i free tier (500 MB databas)

Du kan alltid migrera till egen PostgreSQL-databas senare om du vill.

### Varför inte Docker?
Docker är kraftfullt men lägger till komplexitet:
- Extra konfigurationslager
- Mer minnesanvändning
- Svårare att felsöka för nybörjare

För detta projekt är direkt installation enklare och mer transparent.

### Kan jag använda detta för flera användare?
Ja! Varje användare loggar in med sin email och ser bara sin egen data tack vare Row Level Security (RLS) i Supabase.

## Säkerhetsfrågor

### Är det säkert?
Ja, om du följer best practices:
- ✅ All data krypteras i transit (HTTPS/SSL)
- ✅ Autentisering via Supabase (email magic link)
- ✅ Row Level Security (RLS) förhindrar dataläckage
- ✅ API-nycklar i miljövariabler, inte i kod
- ✅ Regelbundna säkerhetsuppdateringar

### Kan någon hacka min Pi?
Risk minimeras genom:
- SSH-nyckelautentisering (inte lösenord)
- Tailscale eller SSH-tunnel (inte direkt exponering)
- Firewall-konfiguration
- Regelbundna uppdateringar

### Vad händer om min API-nyckel läcker?
**Supabase Anon Key**: Publikt säker tack vare RLS-policies
**Gemini API Key**: Begränsa användning i Google Cloud Console

## Deployment-frågor

### Måste jag använda Tailscale?
Nej! Alternativ:
1. **Tailscale** (rekommenderat) - Enklast, gratis
2. **SSH-tunnel + VPS** - Mer avancerat, små kostnader
3. **Port forwarding** - Inte rekommenderat p.g.a. säkerhetsrisker
4. **Vercel/Netlify** - Deployer frontend till molnet istället

### Vad är fördelen med att köra på Pi hemma?
- **Integritet**: Din data stannar hemma
- **Kostnad**: Ingen månadskostnad efter initial investering
- **Kontroll**: Full kontroll över hårdvara och mjukvara
- **Lärande**: Perfekt för att lära sig Linux och deployment

### Hur mycket strömförbrukning har Pi:n?
Raspberry Pi 3B+ använder ca 2.5-3W i idle, upp till 5-7W under load.
- **Årlig kostnad**: ~10-20 SEK (beroende på elpris)
- **Jämfört med**: En glödlampa använder 40-60W

### Kan jag använda en äldre Raspberry Pi?
- **Pi 2**: Fungerar men långsamt
- **Pi 3**: Perfekt för detta projekt ✅
- **Pi 4**: Mer kraft än nödvändigt men fungerar utmärkt
- **Pi Zero**: För lite kraft för Node.js-builds

## Utvecklingsfrågor

### Hur lägger jag till nya funktioner?
1. Lägg till komponenter i `src/components/`
2. Skapa nya hooks i `src/hooks/` vid behov
3. Uppdatera typer i `src/types.ts`
4. Testa lokalt med `npm run dev`
5. Bygg och deploya: `npm run build`

### Kan jag använda detta som mall för egna projekt?
Absolut! Projektet är open source. Använd det som:
- Lärande-exempel för React + Supabase
- Startpunkt för egna projekt
- Referens för best practices

### Hur uppdaterar jag dependencies?
```bash
# Kolla för uppdateringar
npm outdated

# Uppdatera alla till senaste minor/patch
npm update

# Uppdatera specifikt paket
npm install react@latest

# Testa att allt fungerar
npm run dev
```

### Var finns koden för den ursprungliga mat-lager-appen?
https://github.com/Smuts-One/mat-lager

Den innehåller fullständig implementation med alla komponenter.

## Felsökning

### Appen laddar inte efter deployment
Vanliga orsaker:
1. `.env.local` saknas eller har fel värden
2. `dist/`-mapp saknas (kör `npm run build`)
3. nginx-konfiguration fel
4. Filrättigheter fel

**Lösning**: Se felsökningssektionen i STEG-3-DEPLOYMENT.md

### "Failed to connect to Supabase"
Kolla:
1. Är VITE_SUPABASE_URL korrekt?
2. Är VITE_SUPABASE_ANON_KEY korrekt?
3. Är Supabase-projektet aktivt?
4. Har du internet-anslutning?

### Build tar evigheter på Pi:n
Detta är normalt. Raspberry Pi 3B+ är inte särskilt kraftfull för TypeScript-builds.
**Tips:**
- Öka swap-size (se STEG-3)
- Bygg på din dator och kopiera dist/ till Pi:n
- Använd Pi 4 för snabbare builds

### Kan inte ansluta utifrån med Tailscale
Kolla:
1. Är Tailscale aktivt på båda enheter? (`tailscale status`)
2. Är enheterna på samma Tailscale-nätverk?
3. Kan du pinga Pi:n? (`tailscale ping [PI_IP]`)
4. Kör nginx? (`sudo systemctl status nginx`)

## Support och hjälp

### Var får jag mer hjälp?
1. **Dokumentation**: Läs guiderna i `docs/`-mappen
2. **Felsökning**: Varje guide har felsökningssektion
3. **GitHub Issues**: Öppna en issue på GitHub
4. **Supabase Docs**: https://supabase.com/docs
5. **React Docs**: https://react.dev

### Kan jag bidra till projektet?
Absolut! Sätt:
- Öppna issues för buggar eller funktionsförslag
- Skapa pull requests med förbättringar
- Förbättra dokumentationen
- Dela dina erfarenheter

### Hur rapporterar jag en bugg?
1. Gå till GitHub Issues
2. Beskriv problemet tydligt
3. Inkludera:
   - Vad du försökte göra
   - Vad som hände
   - Felmeddelanden
   - Din miljö (OS, Node-version, etc.)

## Nästa steg

### Jag har läst FAQ, vad gör jag nu?
1. Börja med **[PROJEKTPLAN.md](PROJEKTPLAN.md)**
2. Följ **docs/STEG-1-SETUP.md**
3. Fortsätt med de andra guiderna i ordning

### Jag vill bara testa lokalt först
Perfekt! Du behöver bara:
- STEG-1-SETUP.md (första delen)
- STEG-2-UTVECKLING.md (grundläggande setup)

Hoppa över Raspberry Pi och fjärråtkomst tills du är redo.

### Jag har tekniska frågor som inte täcks här
- Läs [ARKITEKTUR.md](ARKITEKTUR.md) för djupare teknisk förståelse
- Öppna en GitHub Issue
- Kolla Supabase/React dokumentation

---

**Hittade du inte svar på din fråga?**
Öppna en issue på GitHub så lägger vi till det här! 🙂
