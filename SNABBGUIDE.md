# Snabbguide - MatLager 2.0

En ultra-kompakt guide för att komma igång snabbt.

## 🚀 TL;DR - Snabbaste vägen

```bash
# 1. Förutsättningar
# - Node.js 18+ installerat
# - Supabase-konto skapat (https://supabase.com)
# - Google AI Studio API-nyckel (https://aistudio.google.com)

# 2. Klona och installera
git clone https://github.com/Smuts-One/mat-lager2.0.git
cd mat-lager2.0
npm install

# 3. Konfigurera miljövariabler
cat > .env.local << EOF
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOi...
VITE_GEMINI_API_KEY=AIzaSy...
EOF

# 4. Kör SQL-schema i Supabase
# Gå till Supabase Dashboard > SQL Editor
# Kopiera innehållet från sql/supabase-schema.sql och kör

# 5. Starta appen
npm run dev
# Öppna http://localhost:5173
```

## 📚 Fullständig dokumentation

För detaljerade instruktioner, se:

1. **[PROJEKTPLAN.md](PROJEKTPLAN.md)** - Översikt och planering
2. **[ARKITEKTUR.md](ARKITEKTUR.md)** - Teknisk arkitektur
3. **docs/STEG-1-SETUP.md** - Grundläggande setup
4. **docs/STEG-2-UTVECKLING.md** - Utveckling och implementation
5. **docs/STEG-3-DEPLOYMENT.md** - Deploya till Raspberry Pi
6. **docs/STEG-4-FJARRATKOMST.md** - Fjärråtkomst via internet

## 🔑 Viktiga kommandon

### Lokal utveckling
```bash
npm run dev          # Starta dev-server
npm run build        # Bygg för produktion
npm run preview      # Förhandsgranska produktionsbygge
```

### På Raspberry Pi
```bash
# Uppdatera appen
cd ~/apps/mat-lager2.0
git pull
npm install
npm run build
sudo systemctl reload nginx

# Övervaka loggar
sudo tail -f /var/log/nginx/matlager-error.log

# Starta om services
sudo systemctl restart nginx
```

### Supabase
```sql
-- Kolla tabeller
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Kolla RLS-policies
SELECT * FROM pg_policies;

-- Testdata
INSERT INTO inventory_items (user_id, name, quantity, unit, source)
VALUES ('USER_UUID', 'Mjölk', 1, 'liter', 'manual');
```

## 🆘 Snabb felsökning

### Problem: Kan inte ansluta till Supabase
```bash
# Kolla att env-variabler är rätt
cat .env.local | grep VITE_SUPABASE

# Testa från kommandoraden
curl -X GET \
  -H "apikey: DIN_ANON_KEY" \
  "https://xxxxx.supabase.co/rest/v1/inventory_items"
```

### Problem: nginx visar 502 Bad Gateway
```bash
# På Pi:n
ls ~/apps/mat-lager2.0/dist/  # Kolla att dist finns
sudo systemctl status nginx    # Kolla nginx-status
sudo nginx -t                  # Testa config
```

### Problem: Appen är långsam på Pi:n
```bash
# Öka swap-size
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile  # Ändra till CONF_SWAPSIZE=1024
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

## 📞 Support

- **Dokumentation**: Läs guiderna i `docs/`
- **Felsökning**: Se "Felsökning"-sektioner i varje guide
- **GitHub Issues**: https://github.com/Smuts-One/mat-lager2.0/issues

## ✅ Checklista - Innan du börjar

- [ ] Node.js 18+ installerat (`node --version`)
- [ ] Supabase-konto skapat
- [ ] Supabase-projekt skapat med schema
- [ ] Google AI Studio API-nyckel hämtad
- [ ] .env.local skapad med alla nycklar
- [ ] Raspberry Pi OS installerat (om du ska deploya)

## 🎯 Nästa steg efter installation

1. **Logga in** - Använd email magic link
2. **Lägg till testdata** - Manuellt i Supabase eller via UI
3. **Testa funktionalitet** - Lager, matlagning, statistik
4. **Deploya till Pi** - Om du vill köra det hemma
5. **Sätt upp fjärråtkomst** - Tailscale rekommenderas

## 💡 Tips

- **Använd Tailscale** - Enklaste sättet att komma åt Pi:n utifrån
- **Backup regelbundet** - Supabase Dashboard > Database > Backups
- **Håll uppdaterat** - `sudo apt update && sudo apt upgrade` månadsvis
- **Testa lokalt först** - Innan du deployar till Pi:n

## 📖 Läs mer

- [Supabase Documentation](https://supabase.com/docs)
- [Vite Documentation](https://vitejs.dev)
- [React Documentation](https://react.dev)
- [Tailwind CSS](https://tailwindcss.com)

---

**Lycka till med din MatLager-app! 🎉**
