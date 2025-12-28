# Steg 3: Deployment till Raspberry Pi

Detta steg visar hur du deployar applikationen till din Raspberry Pi 3B+.

## 3.1 Förbered Raspberry Pi

### 3.1.1 Installera Raspberry Pi OS

1. **Ladda ner Raspberry Pi Imager**
   - Från: https://www.raspberrypi.com/software/
   - Installera på din dator

2. **Flasha SD-kortet**
   ```
   - Sätt in MicroSD-kortet i din dator
   - Öppna Raspberry Pi Imager
   - Välj "Raspberry Pi OS (64-bit)" under Operating System
   - Välj ditt SD-kort under Storage
   - Klicka på kugghjulet (⚙️) för avancerade inställningar:
     * Sätt hostname: "matlager"
     * Aktivera SSH (använd lösenordsautentisering)
     * Sätt användarnamn: "pi" och lösenord: [välj ett säkert lösenord]
     * Konfigurera WiFi: SSID och lösenord
     * Sätt landsinställningar: SE, Stockholm, sv-SE
   - Klicka "Save" och sedan "Write"
   - Vänta tills processen är klar
   ```

3. **Starta Raspberry Pi**
   ```
   - Ta ut SD-kortet och sätt in det i Raspberry Pi
   - Anslut strömförsörjning
   - Vänta 2-3 minuter för första uppstarten
   ```

### 3.1.2 Anslut till Raspberry Pi

**Hitta IP-adressen:**

Alternativ 1: Från din router
```
- Logga in på din router (vanligtvis 192.168.1.1 eller 192.168.0.1)
- Kolla listan över anslutna enheter
- Leta efter "matlager" eller "raspberrypi"
```

Alternativ 2: Använd nmap (om du har det)
```bash
# Scanna ditt nätverk (ersätt med ditt nätverk)
nmap -sn 192.168.1.0/24 | grep -B 2 "Raspberry Pi"
```

**Anslut via SSH:**
```bash
# Ersätt X.X.X.X med Pi:ns IP-adress
ssh pi@X.X.X.X

# Första gången kommer du få en säkerhetsvarning
# Skriv "yes" och Enter
# Ange lösenordet du satte när du flashade SD-kortet
```

### 3.1.3 Uppdatera systemet

```bash
# När du är inloggad på Pi:n
sudo apt update
sudo apt upgrade -y

# Detta kan ta 10-20 minuter beroende på hur många uppdateringar som finns
```

## 3.2 Installera nödvändig programvara på Pi:n

### 3.2.1 Installera Node.js

```bash
# Installera Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verifiera installation
node --version  # Ska visa v20.x.x
npm --version   # Ska visa 10.x.x
```

### 3.2.2 Installera nginx

```bash
# Installera nginx
sudo apt install -y nginx

# Starta nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verifiera att nginx körs
sudo systemctl status nginx

# Testa att besöka http://[PI_IP_ADRESS] i en webbläsare
# Du ska se nginx välkomstsidan
```

### 3.2.3 Installera Git

```bash
# Installera git (om det inte redan finns)
sudo apt install -y git

# Konfigurera git
git config --global user.name "Ditt Namn"
git config --global user.email "din@email.se"
```

## 3.3 Klona och bygg projektet på Pi:n

### 3.3.1 Skapa projektmapp

```bash
# Skapa mapp för projekt
mkdir -p ~/apps
cd ~/apps
```

### 3.3.2 Klona repot

```bash
# Klona ditt GitHub-repo
git clone https://github.com/Smuts-One/mat-lager2.0.git
cd mat-lager2.0
```

### 3.3.3 Installera dependencies

```bash
# Installera alla npm-paket
npm install

# Detta kan ta 5-10 minuter på en Raspberry Pi 3B+
```

### 3.3.4 Skapa .env.local på Pi:n

```bash
# Skapa miljövariabel-fil
nano .env.local
```

Lägg in samma innehåll som du hade lokalt:
```
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Spara: Ctrl+O, Enter, Ctrl+X

### 3.3.5 Bygg produktionsversion

```bash
# Bygg appen för produktion
npm run build

# Detta skapar en 'dist'-mapp med optimerade filer
# Kan ta 5-10 minuter på Pi:n
```

Verifiera att bygget lyckades:
```bash
ls -lh dist/
# Du ska se index.html och assets/-mapp
```

## 3.4 Konfigurera nginx att serva appen

### 3.4.1 Skapa nginx-konfiguration

```bash
# Skapa ny site-konfiguration
sudo nano /etc/nginx/sites-available/matlager
```

Lägg in följande konfiguration:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name _;

    root /home/pi/apps/mat-lager2.0/dist;
    index index.html;

    # Loggar
    access_log /var/log/nginx/matlager-access.log;
    error_log /var/log/nginx/matlager-error.log;

    # SPA routing - alla requests går till index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache statiska filer
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Säkerhetshuvuden
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip-komprimering
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/javascript application/json;
}
```

Spara: Ctrl+O, Enter, Ctrl+X

### 3.4.2 Aktivera site och starta om nginx

```bash
# Ta bort default site
sudo rm /etc/nginx/sites-enabled/default

# Aktivera vår nya site
sudo ln -s /etc/nginx/sites-available/matlager /etc/nginx/sites-enabled/

# Testa konfigurationen
sudo nginx -t

# Om allt är OK, starta om nginx
sudo systemctl reload nginx
```

### 3.4.3 Justera filrättigheter

```bash
# Ge nginx läsrättigheter till dist-mappen
chmod -R 755 ~/apps/mat-lager2.0/dist
```

## 3.5 Testa appen lokalt på Pi:n

### 3.5.1 Från Pi:n själv

```bash
# Testa med curl
curl http://localhost

# Du ska se HTML-innehåll
```

### 3.5.2 Från annan dator på samma nätverk

1. Öppna webbläsare på din dator
2. Gå till: `http://[PI_IP_ADRESS]`
3. Du ska se MatLager-inloggningssidan

**Om det inte fungerar:**
```bash
# Kolla nginx-status
sudo systemctl status nginx

# Kolla nginx-loggar för fel
sudo tail -f /var/log/nginx/matlager-error.log

# Kolla att dist-mappen finns och har innehåll
ls -la ~/apps/mat-lager2.0/dist/
```

## 3.6 Automatisk uppdatering

Skapa ett script för att enkelt uppdatera appen:

```bash
# Skapa update-script
nano ~/apps/mat-lager2.0/update.sh
```

Lägg in:

```bash
#!/bin/bash
cd ~/apps/mat-lager2.0

echo "Hämtar senaste ändringar från GitHub..."
git pull

echo "Installerar dependencies..."
npm install

echo "Bygger ny version..."
npm run build

echo "Startar om nginx..."
sudo systemctl reload nginx

echo "Klar! Appen är uppdaterad."
```

Gör scriptet körbart:
```bash
chmod +x ~/apps/mat-lager2.0/update.sh
```

Nu kan du uppdatera appen genom att köra:
```bash
~/apps/mat-lager2.0/update.sh
```

## 3.7 Automatisk start vid omstart

Skapa en systemd-service för att säkerställa att nginx startar automatiskt:

```bash
# nginx är redan konfigurerat att starta automatiskt
# Verifiera:
sudo systemctl is-enabled nginx

# Ska visa "enabled"
```

## 3.8 Backup och återställning

### 3.8.1 Backup av konfiguration

```bash
# Skapa backup-mapp
mkdir -p ~/backups

# Backup av nginx-config
sudo cp /etc/nginx/sites-available/matlager ~/backups/matlager-nginx.conf

# Backup av .env.local
cp ~/apps/mat-lager2.0/.env.local ~/backups/env.local.backup

echo "Backup klar!"
```

### 3.8.2 Återställning

Om något går fel:

```bash
# Återställ nginx-config
sudo cp ~/backups/matlager-nginx.conf /etc/nginx/sites-available/matlager
sudo nginx -t
sudo systemctl reload nginx

# Återställ .env.local
cp ~/backups/env.local.backup ~/apps/mat-lager2.0/.env.local
```

## 3.9 Övervaka appen

### 3.9.1 Kolla status

```bash
# Kolla att nginx körs
sudo systemctl status nginx

# Kolla senaste access-loggar
sudo tail -20 /var/log/nginx/matlager-access.log

# Kolla senaste fel-loggar
sudo tail -20 /var/log/nginx/matlager-error.log

# Kolla Pi:ns systemresurser
htop  # (installera med: sudo apt install htop)
```

### 3.9.2 Reboot-test

```bash
# Testa att allt startar efter omstart
sudo reboot

# Vänta 2 minuter, anslut igen
ssh pi@[PI_IP_ADRESS]

# Verifiera att nginx körs
sudo systemctl status nginx

# Testa appen i webbläsaren
```

## Felsökning

### Problem: "502 Bad Gateway"
**Orsak**: nginx kan inte hitta dist-mappen
**Lösning**:
```bash
# Kolla att dist finns
ls ~/apps/mat-lager2.0/dist/

# Om den saknas, bygg om
cd ~/apps/mat-lager2.0
npm run build

# Starta om nginx
sudo systemctl reload nginx
```

### Problem: "403 Forbidden"
**Orsak**: Felaktiga filrättigheter
**Lösning**:
```bash
chmod -R 755 ~/apps/mat-lager2.0/dist
sudo systemctl reload nginx
```

### Problem: Sidan är tom eller visar fel
**Orsak**: Environment-variabler saknas eller är felaktiga
**Lösning**:
```bash
# Kolla .env.local
cat ~/apps/mat-lager2.0/.env.local

# Om variabler saknas, lägg till dem och bygg om
cd ~/apps/mat-lager2.0
nano .env.local  # Lägg till saknade variabler
npm run build
sudo systemctl reload nginx
```

### Problem: Pi:n är långsam
**Tips**:
```bash
# Öka swap-size för att hjälpa vid builds
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Ändra CONF_SWAPSIZE=100 till CONF_SWAPSIZE=1024
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

## Nästa steg

Nu körs appen på din Pi och är tillgänglig i ditt lokala nätverk!

Fortsätt till **STEG-4-FJARRATKOMST.md** för att göra appen tillgänglig från internet.
