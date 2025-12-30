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
