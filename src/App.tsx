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
