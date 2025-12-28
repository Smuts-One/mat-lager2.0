# Steg 2: Utveckling och Implementation

I detta steg implementerar vi applikationens funktionalitet steg för steg.

## 2.1 Projektstruktur

Skapa grundläggande projektstruktur:

```bash
# Från projektets rot-mapp
mkdir -p src/components
mkdir -p src/hooks  
mkdir -p src/services
```

## 2.2 Konfigurera TypeScript och Build Tools

### 2.2.1 Skapa package.json

```bash
# Skapa package.json om den inte finns
npm init -y

# Öppna package.json
nano package.json
```

Ersätt innehållet med:

```json
{
  "name": "mat-lager",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "recharts": "^2.10.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.3.6",
    "typescript": "^5.3.3",
    "vite": "^5.0.8"
  }
}
```

Installera alla paket:
```bash
npm install
```

### 2.2.2 Skapa tsconfig.json

```bash
nano tsconfig.json
```

Lägg in:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### 2.2.3 Skapa tsconfig.node.json

```bash
nano tsconfig.node.json
```

Lägg in:

```json
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
```

### 2.2.4 Skapa vite.config.ts

```bash
nano vite.config.ts
```

Lägg in:

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: true
  }
})
```

### 2.2.5 Konfigurera Tailwind CSS

```bash
# Skapa Tailwind config
npx tailwindcss init -p
```

Redigera `tailwind.config.js`:

```bash
nano tailwind.config.js
```

Ersätt med:

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

## 2.3 Skapa grundläggande filer

### 2.3.1 Skapa index.html

```bash
nano index.html
```

Lägg in:

```html
<!DOCTYPE html>
<html lang="sv">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="MatLager - Håll koll på dina matvaror" />
    <title>MatLager</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

### 2.3.2 Skapa src/main.tsx

```bash
nano src/main.tsx
```

Lägg in:

```typescript
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
```

### 2.3.3 Skapa src/index.css

```bash
nano src/index.css
```

Lägg in:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}
```

## 2.4 Implementera Supabase-integration

### 2.4.1 Skapa Supabase-klient

```bash
nano src/services/supabaseClient.ts
```

Lägg in:

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Supabase URL eller API-nyckel saknas i miljövariabler')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### 2.4.2 Skapa typdefinitioner

```bash
nano src/types.ts
```

Lägg in:

```typescript
export interface InventoryItem {
  id: string
  name: string
  quantity: number
  unit: string
  category?: string
  expiryDate?: string
  priceInfo?: number
  addedDate: string
  source: 'manual' | 'scan'
}

export interface ConsumptionLog {
  id: string
  date: string
  itemName: string
  quantityUsed: number
  unit: string
  cost: number
  reason: 'cooked' | 'expired' | 'other'
  dishName?: string
  notes?: string
}

export interface CookingSession {
  id: string
  dishName: string
  createdAt: string
  totalCost: number
  notes?: string
}

export interface CookingSessionItem {
  id: string
  sessionId: string
  itemName: string
  quantityUsed: number
  unit: string
  cost: number
}

export interface DeductionSuggestion {
  itemId: string
  deductAmount: number
}

export interface Recipe {
  id: string
  title: string
  description?: string
  instructions: string[]
  cookTime?: string
  createdAt: string
}

export interface RecipeIngredient {
  id: string
  recipeId: string
  ingredientName: string
  quantity?: number
  unit?: string
}
```

### 2.4.3 Skapa authentication hook

```bash
nano src/hooks/useSupabaseSession.ts
```

Lägg in:

```typescript
import { useEffect, useState } from 'react'
import { supabase } from '../services/supabaseClient'
import { Session } from '@supabase/supabase-js'

export const useSupabaseSession = () => {
  const [session, setSession] = useState<Session | null>(null)
  const [initializing, setInitializing] = useState(true)

  useEffect(() => {
    // Hämta nuvarande session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setInitializing(false)
    })

    // Lyssna på auth-ändringar
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
    })

    return () => subscription.unsubscribe()
  }, [])

  return { session, initializing }
}
```

### 2.4.4 Skapa inventory hook

```bash
nano src/hooks/useInventory.ts
```

Lägg in:

```typescript
import { useEffect, useState } from 'react'
import { supabase } from '../services/supabaseClient'
import { InventoryItem } from '../types'

export const useInventory = (userId: string | null) => {
  const [items, setItems] = useState<InventoryItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchInventory = async () => {
    if (!userId) {
      setItems([])
      setLoading(false)
      return
    }

    try {
      const { data, error } = await supabase
        .from('inventory_items')
        .select('*')
        .eq('user_id', userId)
        .order('added_at', { ascending: false })

      if (error) throw error

      const mapped: InventoryItem[] = (data || []).map(item => ({
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        category: item.category,
        expiryDate: item.expiry_date,
        priceInfo: item.price_info,
        addedDate: item.added_at,
        source: item.source
      }))

      setItems(mapped)
      setError(null)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Okänt fel')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchInventory()

    // Prenumerera på realtime-ändringar
    const channel = supabase
      .channel('inventory_changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'inventory_items',
          filter: `user_id=eq.${userId}`
        },
        () => {
          fetchInventory()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [userId])

  return {
    items,
    loading,
    error,
    refresh: fetchInventory
  }
}
```

## 2.5 Skapa grundläggande App-komponent

```bash
nano src/App.tsx
```

Lägg in en minimal version:

```typescript
import React, { useState } from 'react'
import { supabase } from './services/supabaseClient'
import { useSupabaseSession } from './hooks/useSupabaseSession'
import { useInventory } from './hooks/useInventory'

const App: React.FC = () => {
  const [email, setEmail] = useState('')
  const [loginMessage, setLoginMessage] = useState<string | null>(null)
  const { session, initializing } = useSupabaseSession()
  const userId = session?.user?.id ?? null
  const { items, loading } = useInventory(userId)

  const handleEmailLogin = async (event: React.FormEvent) => {
    event.preventDefault()
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: window.location.origin }
    })
    
    if (error) {
      setLoginMessage('Fel: ' + error.message)
    } else {
      setLoginMessage('Kolla din inkorg för en magisk inloggningslänk.')
    }
  }

  const handleSignOut = async () => {
    await supabase.auth.signOut()
  }

  if (initializing) {
    return <div className="min-h-screen flex items-center justify-center">Laddar...</div>
  }

  if (!session) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 p-4">
        <div className="w-full max-w-md bg-white shadow-lg rounded-lg p-6">
          <h1 className="text-2xl font-bold mb-4">MatLager - Logga in</h1>
          <form onSubmit={handleEmailLogin} className="space-y-4">
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              placeholder="din@email.se"
              className="w-full px-4 py-2 border rounded-lg"
              required
            />
            <button
              type="submit"
              className="w-full bg-emerald-600 text-white py-2 rounded-lg hover:bg-emerald-700"
            >
              Skicka magisk länk
            </button>
          </form>
          {loginMessage && <p className="mt-4 text-sm">{loginMessage}</p>}
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-emerald-600 text-white p-4">
        <div className="max-w-3xl mx-auto flex justify-between items-center">
          <h1 className="text-2xl font-bold">MatLager</h1>
          <button
            onClick={handleSignOut}
            className="bg-white/20 px-4 py-2 rounded-lg hover:bg-white/30"
          >
            Logga ut
          </button>
        </div>
      </header>
      
      <main className="max-w-3xl mx-auto p-4">
        <h2 className="text-xl font-semibold mb-4">Ditt lager</h2>
        {loading ? (
          <p>Hämtar lagret...</p>
        ) : items.length === 0 ? (
          <p className="text-gray-500">Inga varor i lagret än.</p>
        ) : (
          <ul className="space-y-2">
            {items.map(item => (
              <li key={item.id} className="bg-white p-4 rounded-lg shadow">
                <div className="font-semibold">{item.name}</div>
                <div className="text-sm text-gray-600">
                  {item.quantity} {item.unit}
                  {item.priceInfo && ` - ${item.priceInfo} kr`}
                </div>
              </li>
            ))}
          </ul>
        )}
      </main>
    </div>
  )
}

export default App
```

## 2.6 Testa applikationen

```bash
# Starta utvecklingsservern
npm run dev
```

Öppna http://localhost:5173/ i webbläsaren och testa:

1. **Logga in**: Ange din email och klicka "Skicka magisk länk"
2. **Kolla email**: Leta efter email från Supabase med inloggningslänk
3. **Klicka på länken**: Du ska loggas in automatiskt
4. **Se lagret**: Tom lagervy ska visas (vi lägger till items i nästa steg)

## 2.7 Lägg till varor manuellt (för testning)

Du kan lägga till testdata direkt i Supabase:

1. Gå till Supabase Dashboard
2. Klicka på "Table Editor"
3. Välj "inventory_items"
4. Klicka "Insert row"
5. Fyll i:
   - user_id: (kopiera från authentication > users)
   - name: "Mjölk"
   - quantity: 1
   - unit: "liter"
   - source: "manual"
6. Klicka "Save"
7. Uppdatera appen - varan ska dyka upp automatiskt!

## Nästa steg

Nu har du en fungerande grundläggande app! Fortsätt till:
- **STEG-3-DEPLOYMENT.md** för att deploya till Raspberry Pi
- Eller fortsätt utveckla fler funktioner (Scanner, Matlagning, etc.)
