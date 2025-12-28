# Steg 4: Fjärråtkomst (Tillgång från Internet)

Detta steg visar hur du gör din MatLager-app tillgänglig från internet på ett enkelt och säkert sätt.

## Översikt av Alternativ

Det finns flera sätt att göra din Pi tillgänglig från internet. Vi rekommenderar **Tailscale** som det enklaste alternativet.

### Alternativ 1: Tailscale (REKOMMENDERAT - Enklast!)
- ✅ Mycket enkelt att sätta upp
- ✅ Automatisk kryptering
- ✅ Inget krångel med routerkonfiguration
- ✅ Fungerar även bakom CGNAT
- ✅ Gratis för personligt bruk
- ⚠️ Kräver att du installerar Tailscale på varje enhet du vill komma åt från

### Alternativ 2: SSH-tunnel via en VPS
- ✅ Fungerar överallt, ingen installation på klientenheter
- ✅ Billigt (VPS från ~5 USD/månad)
- ⚠️ Kräver en VPS-server
- ⚠️ Lite mer avancerat att sätta upp

### Alternativ 3: Port Forwarding (EJ REKOMMENDERAT)
- ❌ Säkerhetsproblem
- ❌ Kräver statisk IP eller DDNS
- ❌ Fungerar inte med CGNAT
- ❌ Komplext att sätta upp korrekt

## Alternativ 1: Tailscale (Rekommenderad metod)

### 4.1.1 Vad är Tailscale?

Tailscale skapar ett privat nätverk (VPN) mellan dina enheter. Det är som att alla dina enheter är på samma WiFi, oavsett var i världen de befinner sig.

### 4.1.2 Skapa Tailscale-konto

1. Gå till https://tailscale.com
2. Klicka "Get Started"
3. Logga in med Google, Microsoft, eller GitHub
4. Du kommer till Tailscale admin-konsolen

### 4.1.3 Installera Tailscale på Raspberry Pi

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

### 4.1.4 Installera Tailscale på dina andra enheter

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

### 4.1.5 Testa åtkomst

1. Öppna webbläsare på din telefon/dator
2. Gå till: `http://100.x.x.x` (ersätt med din Pi:ns Tailscale IP)
3. Du ska se MatLager-inloggningssidan!

### 4.1.6 Aktivera MagicDNS (Valfritt men rekommenderat)

Detta låter dig använda ett lätt-att-komma-ihåg-namn istället för IP-adress:

1. Gå till Tailscale admin-konsolen: https://login.tailscale.com/admin/dns
2. Aktivera "MagicDNS"
3. Nu kan du nå din Pi med: `http://matlager` istället för IP-adressen

### 4.1.7 Aktivera Tailscale vid systemstart

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

### 4.1.8 (Valfritt) Dela åtkomst med familj/vänner

```bash
# På Pi:n, gör den tillgänglig som en "exit node" eller dela specifikt
sudo tailscale set --advertise-exit-node=false

# För att dela med specifika personer:
# Gå till Tailscale admin > Machines
# Klicka på din Pi
# Klicka "Share" och skicka en inbjudan
```

## Alternativ 2: SSH-tunnel via VPS

Detta alternativ är för dig som vill ha full webbåtkomst utan att installera något på klientenheter.

### 4.2.1 Skaffa en VPS

Rekommenderade leverantörer (alla har gratis trial eller billiga alternativ):

- **DigitalOcean**: $4-6/månad, $200 gratis kredit för 60 dagar
- **Linode**: $5/månad, $100 gratis kredit
- **Vultr**: $2.50-5/månad
- **Hetzner**: €4.5/månad (~50 SEK)

**Skapa VPS:**
1. Registrera konto hos någon av leverantörerna
2. Skapa en "Droplet" eller "Instance"
3. Välj:
   - OS: Ubuntu 22.04 LTS
   - Plan: Billigaste alternativet (1GB RAM räcker)
   - Region: Frankfurt eller Amsterdam (närmast Sverige)
4. Lägg till din SSH-nyckel eller använd lösenord
5. Skapa server och vänta 1-2 minuter

### 4.2.2 Grundläggande VPS-setup

```bash
# Anslut till din VPS
ssh root@[VPS_IP_ADRESS]

# Uppdatera systemet
apt update && apt upgrade -y

# Installera nginx
apt install -y nginx

# Installera certbot för HTTPS (valfritt men rekommenderat)
apt install -y certbot python3-certbot-nginx

# Skapa en användare (säkrare än att använda root)
adduser tunnel
usermod -aG sudo tunnel

# Byt till den nya användaren
su - tunnel
```

### 4.2.3 Konfigurera SSH-tunnel från Pi till VPS

**På Pi:n:**

```bash
# Generera SSH-nyckel (om du inte redan har en)
ssh-keygen -t ed25519 -C "pi@matlager"
# Tryck Enter för alla frågor (använd default-värden)

# Kopiera SSH-nyckeln till VPS
ssh-copy-id tunnel@[VPS_IP_ADRESS]

# Testa att du kan ansluta utan lösenord
ssh tunnel@[VPS_IP_ADRESS]
# Om detta fungerar, skriv 'exit' för att gå tillbaka till Pi:n
```

**Installera autossh på Pi:n:**

```bash
# autossh håller SSH-tunneln vid liv automatiskt
sudo apt install -y autossh
```

**Skapa autossh-service:**

```bash
# Skapa systemd service-fil
sudo nano /etc/systemd/system/autossh-tunnel.service
```

Lägg in följande:

```ini
[Unit]
Description=AutoSSH tunnel till VPS för MatLager
After=network.target

[Service]
Type=simple
User=pi
ExecStart=/usr/bin/autossh -M 0 -N -T -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" -o "ExitOnForwardFailure yes" -R 8080:localhost:80 tunnel@[VPS_IP_ADRESS]
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**OBS**: Ersätt `[VPS_IP_ADRESS]` med din faktiska VPS IP-adress!

Spara: Ctrl+O, Enter, Ctrl+X

**Aktivera service:**

```bash
# Ladda om systemd
sudo systemctl daemon-reload

# Aktivera och starta service
sudo systemctl enable autossh-tunnel.service
sudo systemctl start autossh-tunnel.service

# Kolla status
sudo systemctl status autossh-tunnel.service

# Ska visa "active (running)"
```

### 4.2.4 Konfigurera nginx på VPS

**Anslut till VPS:**

```bash
ssh tunnel@[VPS_IP_ADRESS]
```

**Skapa nginx-konfiguration:**

```bash
sudo nano /etc/nginx/sites-available/matlager
```

Lägg in:

```nginx
server {
    listen 80;
    server_name [DIN_DOMÄN_ELLER_VPS_IP];

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Aktivera site:**

```bash
sudo ln -s /etc/nginx/sites-available/matlager /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 4.2.5 Testa åtkomst

Öppna webbläsare och gå till: `http://[VPS_IP_ADRESS]`

Du ska se MatLager-appen!

### 4.2.6 (Valfritt) Sätt upp HTTPS med egen domän

**Om du har en domän (t.ex. matlager.dindomän.se):**

1. Peka DNS A-record till VPS IP-adressen
2. Vänta på DNS-propagering (5-60 min)
3. På VPS:

```bash
# Uppdatera nginx-config med din domän
sudo nano /etc/nginx/sites-available/matlager
# Ändra server_name till din domän

# Hämta SSL-certifikat
sudo certbot --nginx -d matlager.dindomän.se

# Följ instruktionerna
# Välj att omdirigera HTTP till HTTPS

# Testa att det fungerar
curl https://matlager.dindomän.se
```

Nu kan du nå appen med: `https://matlager.dindomän.se` 🎉

### 4.2.7 Automatisk certifikat-förnyelse

```bash
# Certbot sätter upp auto-förnyelse automatiskt
# Testa att förnyelsen fungerar:
sudo certbot renew --dry-run
```

## Säkerhetstips

### 1. Ändra SSH-port på VPS (minskar bot-attacker)

```bash
# På VPS
sudo nano /etc/ssh/sshd_config

# Ändra:
# Port 22
# till:
# Port 2222

# Spara och starta om SSH
sudo systemctl restart sshd

# Nu ansluter du med:
ssh -p 2222 tunnel@[VPS_IP_ADRESS]
```

### 2. Sätt upp firewall på VPS

```bash
# På VPS
sudo apt install -y ufw

# Tillåt SSH och HTTP/HTTPS
sudo ufw allow 2222/tcp  # eller 22 om du inte ändrade porten
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Aktivera firewall
sudo ufw enable

# Kolla status
sudo ufw status
```

### 3. Håll allt uppdaterat

```bash
# På Pi:n
sudo apt update && sudo apt upgrade -y

# På VPS:n
sudo apt update && sudo apt upgrade -y

# Gör detta minst en gång per månad
```

### 4. Backup av Supabase

Supabase gör automatiska backups, men du kan också:

```bash
# Exportera databas manuellt
# Gå till Supabase Dashboard > Database > Backups
# Klicka "Create backup" för manual backup
```

## Övervaka och underhålla

### Kolla att tunneln/Tailscale fungerar

**Tailscale:**
```bash
# På Pi:n
tailscale status
tailscale ping [ANNAN_ENHET]
```

**SSH-tunnel:**
```bash
# På Pi:n
sudo systemctl status autossh-tunnel.service

# På VPS:n
sudo netstat -tlnp | grep 8080
# Ska visa att port 8080 lyssnar
```

### Loggar

```bash
# Pi nginx-loggar
sudo tail -f /var/log/nginx/matlager-error.log

# VPS nginx-loggar (om du använder VPS)
sudo tail -f /var/log/nginx/error.log

# Autossh loggar (om du använder SSH-tunnel)
sudo journalctl -u autossh-tunnel.service -f
```

## Felsökning

### Problem: Kan inte nå appen utifrån

**Tailscale:**
- Kolla att båda enheter är inloggade i Tailscale
- Kör `tailscale status` på båda
- Testa `tailscale ping [PI_IP]` från din andra enhet

**SSH-tunnel:**
- Kolla att autossh-service körs: `sudo systemctl status autossh-tunnel.service`
- Kolla VPS: `ssh tunnel@[VPS_IP] "netstat -tlnp | grep 8080"`
- Kolla nginx på VPS: `ssh tunnel@[VPS_IP] "sudo systemctl status nginx"`

### Problem: Tunnel kopplas ner ofta

```bash
# På Pi:n, öka timeout-värden
sudo nano /etc/systemd/system/autossh-tunnel.service

# Ändra ExecStart-raden till:
ExecStart=/usr/bin/autossh -M 0 -N -T -o "ServerAliveInterval 30" -o "ServerAliveCountMax 10" -o "ExitOnForwardFailure yes" -R 8080:localhost:80 tunnel@[VPS_IP_ADRESS]

# Ladda om och starta om
sudo systemctl daemon-reload
sudo systemctl restart autossh-tunnel.service
```

## Sammanfattning

Du har nu en MatLager-app som:
- ✅ Körs på din Raspberry Pi hemma
- ✅ Är tillgänglig från internet (via Tailscale eller VPS)
- ✅ Är säker (autentisering via Supabase)
- ✅ Kostar nästan ingenting att drifta

**Rekommenderad setup för de flesta:**
- Tailscale för personligt bruk (enklast!)
- SSH-tunnel + VPS om du vill dela med andra utan att de installerar något

Grattis, du är klar! 🎉
