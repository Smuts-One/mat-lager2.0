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
