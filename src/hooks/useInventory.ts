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
