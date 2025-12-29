# Steg 4: Fjärråtkomst (Tillgång från Internet)

Detta steg visar hur du gör din MatLager-app tillgänglig från internet på ett enkelt och säkert sätt.

## Metod: Tailscale

Vi använder **Tailscale** för att göra din Pi tillgänglig från internet. Det är det enklaste och säkraste alternativet.

### Fördelar med Tailscale:
- ✅ Mycket enkelt att sätta upp
- ✅ Automatisk kryptering
- ✅ Inget krångel med routerkonfiguration
- ✅ Fungerar även bakom CGNAT
- ✅ Gratis för personligt bruk
- ⚠️ Kräver att du installerar Tailscale på varje enhet du vill komma åt från

## Installation och Konfiguration

### 1. Vad är Tailscale?

Tailscale skapar ett privat nätverk (VPN) mellan dina enheter. Det är som att alla dina enheter är på samma WiFi, oavsett var i världen de befinner sig.

### 2. Skapa Tailscale-konto

1. Gå till https://tailscale.com
2. Klicka "Get Started"
3. Logga in med Google, Microsoft, eller GitHub
4. Du kommer till Tailscale admin-konsolen

### 3. Installera Tailscale på Raspberry Pi

```bash
# Anslut till din Pi via SSH
ssh pi@[PI_IP_ADRESS]

# Installera Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Starta Tailscale och logga in
sudo tailscale up

# Du kommer få en URL som du ska öppna i en webbläsare
# Öppna URLen och godkänn enheten i Tailscale-konsolen
```

Efter att du godkänt enheten:

```bash
# Verifiera att det fungerar
tailscale status

# Du ska se din Pi och dess Tailscale IP (t.ex. 100.x.x.x)
tailscale ip -4

# Spara denna IP-adress!
```

### 4. Installera Tailscale på dina andra enheter

**På din telefon:**
1. Ladda ner Tailscale-appen från App Store eller Google Play
2. Logga in med samma konto
3. Godkänn enheten

**På din laptop/dator:**

**macOS/Windows:**
1. Ladda ner från https://tailscale.com/download
2. Installera och logga in
3. Godkänn enheten

**Linux:**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

### 5. Testa åtkomst

1. Öppna webbläsare på din telefon/dator
2. Gå till: `http://100.x.x.x` (ersätt med din Pi:ns Tailscale IP)
3. Du ska se MatLager-inloggningssidan!

### 6. Aktivera MagicDNS (Valfritt men rekommenderat)

Detta låter dig använda ett lätt-att-komma-ihåg-namn istället för IP-adress:

1. Gå till Tailscale admin-konsolen: https://login.tailscale.com/admin/dns
2. Aktivera "MagicDNS"
3. Nu kan du nå din Pi med: `http://matlager` istället för IP-adressen

### 7. Aktivera Tailscale vid systemstart

```bash
# På Pi:n, säkerställ att Tailscale startar automatiskt
sudo systemctl enable tailscaled
sudo systemctl start tailscaled

# Testa genom att starta om Pi:n
sudo reboot

# Efter omstart, kolla att Tailscale körs
ssh pi@[PI_IP_ADRESS]
tailscale status
```

### 8. (Valfritt) Dela åtkomst med familj/vänner

```bash
# På Pi:n, gör den tillgänglig som en "exit node" eller dela specifikt
sudo tailscale set --advertise-exit-node=false

# För att dela med specifika personer:
# Gå till Tailscale admin > Machines
# Klicka på din Pi
# Klicka "Share" och skicka en inbjudan
```

## Säkerhetstips

### 1. Håll allt uppdaterat

```bash
# På Pi:n
sudo apt update && sudo apt upgrade -y

# Gör detta minst en gång per månad
```

### 2. Backup av Supabase

Supabase gör automatiska backups, men du kan också:

```bash
# Exportera databas manuellt
# Gå till Supabase Dashboard > Database > Backups
# Klicka "Create backup" för manual backup
```

## Övervaka och underhålla

### Kolla att Tailscale fungerar

```bash
# På Pi:n
tailscale status
tailscale ping [ANNAN_ENHET]
```

### Loggar

```bash
# Pi nginx-loggar
sudo tail -f /var/log/nginx/matlager-error.log
```

## Felsökning

### Problem: Kan inte nå appen utifrån

- Kolla att båda enheter är inloggade i Tailscale
- Kör `tailscale status` på båda
- Testa `tailscale ping [PI_IP]` från din andra enhet
- Kontrollera att nginx körs på Pi:n: `sudo systemctl status nginx`

## Sammanfattning

Du har nu en MatLager-app som:
- ✅ Körs på din Raspberry Pi hemma
- ✅ Är tillgänglig från internet via Tailscale
- ✅ Är säker (autentisering via Supabase + krypterad Tailscale-anslutning)
- ✅ Kostar nästan ingenting att drifta

Grattis, du är klar! 🎉
