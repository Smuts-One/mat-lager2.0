import { useState } from 'react'
import { supabase } from '../lib/supabase'

export default function Auth() {
  const [loading, setLoading] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [isSignUp, setIsSignUp] = useState(false)
  const [message, setMessage] = useState('')

  const handleAuth = async (e) => {
    e.preventDefault()
    setLoading(true)
    setMessage('')

    try {
      if (isSignUp) {
        const { error } = await supabase.auth.signUp({
          email,
          password,
        })
        if (error) throw error
        setMessage('Kolla din e-post för verifieringslänken!')
      } else {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })
        if (error) throw error
      }
    } catch (error) {
      setMessage(error. message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="auth-container">
      <div className="auth-card">
        <h1>🥘 MatLager 2.0</h1>
        <p className="subtitle">Håll koll på ditt matförråd</p>
        
        <form onSubmit={handleAuth}>
          <input
            type="email"
            placeholder="Din e-postadress"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            disabled={loading}
          />
          <input
            type="password"
            placeholder="Lösenord"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            disabled={loading}
          />
          
          <button type="submit" disabled={loading}>
            {loading ? 'Laddar...' : isSignUp ?  'Skapa konto' : 'Logga in'}
          </button>
        </form>

        {message && (
          <div className={`message ${message.includes('Kolla') ? 'success' : 'error'}`}>
            {message}
          </div>
        )}

        <button
          className="toggle-mode"
          onClick={() => {
            setIsSignUp(!isSignUp)
            setMessage('')
          }}
          disabled={loading}
        >
          {isSignUp ? 'Har redan ett konto?  Logga in' : 'Inget konto? Skapa ett'}
        </button>
      </div>
    </div>
  )
}
