import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'

export default function Dashboard({ session }) {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchItems()
  }, [])

  const fetchItems = async () => {
    try {
      const { data, error } = await supabase
        .from('inventory_items')
        .select('*')
        .order('created_at', { ascending:  false })

      if (error) throw error
      setItems(data || [])
    } catch (error) {
      console.error('Error fetching items:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSignOut = async () => {
    await supabase.auth.signOut()
  }

  return (
    <div className="dashboard">
      <header>
        <h1>🥘 MatLager 2.0</h1>
        <div className="user-info">
          <span>{session.user.email}</span>
          <button onClick={handleSignOut}>Logga ut</button>
        </div>
      </header>

      <main>
        <div className="inventory-section">
          <h2>Ditt Matförråd</h2>
          
          {loading ? (
            <p>Laddar...</p>
          ) : items.length === 0 ? (
            <div className="empty-state">
              <p>Ditt lager är tomt! </p>
              <p>Lägg till dina första varor för att komma igång.</p>
            </div>
          ) : (
            <div className="items-grid">
              {items. map((item) => (
                <div key={item.id} className="item-card">
                  <h3>{item.name}</h3>
                  <p>
                    {item.quantity} {item.unit}
                  </p>
                  {item.category && <span className="category">{item.category}</span>}
                  {item.expiry_date && (
                    <span className="expiry">Utgår: {item.expiry_date}</span>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
