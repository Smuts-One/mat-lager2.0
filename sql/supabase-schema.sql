-- MatLager 2.0 - Supabase Database Schema
-- Kör detta i Supabase SQL Editor för att skapa alla tabeller

-- Aktivera UUID-extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles-tabell (utökar auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lagervaror
CREATE TABLE IF NOT EXISTS public.inventory_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  quantity NUMERIC NOT NULL CHECK (quantity >= 0),
  unit TEXT NOT NULL,
  category TEXT,
  expiry_date DATE,
  price_info NUMERIC,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  source TEXT NOT NULL CHECK (source IN ('manual', 'scan', 'shopping'))
);

-- Index för snabbare sökningar
CREATE INDEX IF NOT EXISTS idx_inventory_user_id ON public.inventory_items(user_id);
CREATE INDEX IF NOT EXISTS idx_inventory_category ON public.inventory_items(category);
CREATE INDEX IF NOT EXISTS idx_inventory_expiry ON public.inventory_items(expiry_date);

-- Förbrukningsloggar
CREATE TABLE IF NOT EXISTS public.consumption_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  logged_at TIMESTAMPTZ DEFAULT NOW(),
  item_name TEXT NOT NULL,
  quantity_used NUMERIC NOT NULL CHECK (quantity_used > 0),
  unit TEXT NOT NULL,
  cost NUMERIC DEFAULT 0,
  reason TEXT NOT NULL CHECK (reason IN ('cooked', 'expired', 'wasted', 'other')),
  dish_name TEXT,
  notes TEXT
);

-- Index för förbrukningsloggar
CREATE INDEX IF NOT EXISTS idx_consumption_user_id ON public.consumption_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_consumption_logged_at ON public.consumption_logs(logged_at);
CREATE INDEX IF NOT EXISTS idx_consumption_reason ON public.consumption_logs(reason);

-- Matlagningssessioner
CREATE TABLE IF NOT EXISTS public.cooking_sessions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  dish_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  total_cost NUMERIC DEFAULT 0,
  servings INTEGER,
  notes TEXT
);

-- Index för matlagningssessioner
CREATE INDEX IF NOT EXISTS idx_cooking_sessions_user_id ON public.cooking_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_cooking_sessions_created_at ON public.cooking_sessions(created_at);

-- Matlagningssession-ingredienser
CREATE TABLE IF NOT EXISTS public.cooking_session_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  session_id UUID REFERENCES public.cooking_sessions(id) ON DELETE CASCADE NOT NULL,
  item_name TEXT NOT NULL,
  quantity_used NUMERIC NOT NULL CHECK (quantity_used > 0),
  unit TEXT NOT NULL,
  cost NUMERIC DEFAULT 0
);

-- Index för session-items
CREATE INDEX IF NOT EXISTS idx_session_items_session_id ON public.cooking_session_items(session_id);

-- Recept
CREATE TABLE IF NOT EXISTS public.recipes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  instructions TEXT[],
  prep_time INTEGER, -- minuter
  cook_time INTEGER, -- minuter
  servings INTEGER,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  image_url TEXT,
  source_url TEXT,
  tags TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index för recept
CREATE INDEX IF NOT EXISTS idx_recipes_user_id ON public.recipes(user_id);
CREATE INDEX IF NOT EXISTS idx_recipes_title ON public.recipes(title);

-- Receptingredienser
CREATE TABLE IF NOT EXISTS public.recipe_ingredients (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  recipe_id UUID REFERENCES public.recipes(id) ON DELETE CASCADE NOT NULL,
  ingredient_name TEXT NOT NULL,
  quantity NUMERIC,
  unit TEXT,
  notes TEXT
);

-- Index för receptingredienser
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe_id ON public.recipe_ingredients(recipe_id);

-- Måltidsplanering
CREATE TABLE IF NOT EXISTS public.meal_plan (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  recipe_id UUID REFERENCES public.recipes(id) ON DELETE SET NULL,
  custom_dish TEXT,
  notes TEXT,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index för måltidsplanering
CREATE INDEX IF NOT EXISTS idx_meal_plan_user_id ON public.meal_plan(user_id);
CREATE INDEX IF NOT EXISTS idx_meal_plan_date ON public.meal_plan(date);
CREATE INDEX IF NOT EXISTS idx_meal_plan_recipe_id ON public.meal_plan(recipe_id);

-- Inköpslista
CREATE TABLE IF NOT EXISTS public.shopping_list (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  item_name TEXT NOT NULL,
  quantity NUMERIC,
  unit TEXT,
  category TEXT,
  priority INTEGER DEFAULT 0,
  store TEXT,
  estimated_price NUMERIC,
  purchased BOOLEAN DEFAULT FALSE,
  purchased_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT
);

-- Index för inköpslista
CREATE INDEX IF NOT EXISTS idx_shopping_list_user_id ON public.shopping_list(user_id);
CREATE INDEX IF NOT EXISTS idx_shopping_list_purchased ON public.shopping_list(purchased);

-- Row Level Security (RLS) Policies
-- Detta säkerställer att användare bara kan se och ändra sin egen data

-- Aktivera RLS på alla tabeller
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consumption_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cooking_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cooking_session_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_plan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_list ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Inventory items policies
CREATE POLICY "Users can view own inventory" ON public.inventory_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own inventory items" ON public.inventory_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own inventory items" ON public.inventory_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own inventory items" ON public.inventory_items
  FOR DELETE USING (auth.uid() = user_id);

-- Consumption logs policies
CREATE POLICY "Users can view own consumption logs" ON public.consumption_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own consumption logs" ON public.consumption_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own consumption logs" ON public.consumption_logs
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own consumption logs" ON public.consumption_logs
  FOR DELETE USING (auth.uid() = user_id);

-- Cooking sessions policies
CREATE POLICY "Users can view own cooking sessions" ON public.cooking_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cooking sessions" ON public.cooking_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cooking sessions" ON public.cooking_sessions
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cooking sessions" ON public.cooking_sessions
  FOR DELETE USING (auth.uid() = user_id);

-- Cooking session items policies (kopplade till sessions)
CREATE POLICY "Users can view own cooking session items" ON public.cooking_session_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.cooking_sessions
      WHERE cooking_sessions.id = cooking_session_items.session_id
      AND cooking_sessions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own cooking session items" ON public.cooking_session_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.cooking_sessions
      WHERE cooking_sessions.id = cooking_session_items.session_id
      AND cooking_sessions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own cooking session items" ON public.cooking_session_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.cooking_sessions
      WHERE cooking_sessions.id = cooking_session_items.session_id
      AND cooking_sessions.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own cooking session items" ON public.cooking_session_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.cooking_sessions
      WHERE cooking_sessions.id = cooking_session_items.session_id
      AND cooking_sessions.user_id = auth.uid()
    )
  );

-- Recipes policies
CREATE POLICY "Users can view own recipes" ON public.recipes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recipes" ON public.recipes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recipes" ON public.recipes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recipes" ON public.recipes
  FOR DELETE USING (auth.uid() = user_id);

-- Recipe ingredients policies
CREATE POLICY "Users can view own recipe ingredients" ON public.recipe_ingredients
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.recipes
      WHERE recipes.id = recipe_ingredients.recipe_id
      AND recipes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own recipe ingredients" ON public.recipe_ingredients
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.recipes
      WHERE recipes.id = recipe_ingredients.recipe_id
      AND recipes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own recipe ingredients" ON public.recipe_ingredients
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.recipes
      WHERE recipes.id = recipe_ingredients.recipe_id
      AND recipes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own recipe ingredients" ON public.recipe_ingredients
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.recipes
      WHERE recipes.id = recipe_ingredients.recipe_id
      AND recipes.user_id = auth.uid()
    )
  );

-- Meal plan policies
CREATE POLICY "Users can view own meal plan" ON public.meal_plan
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meal plan" ON public.meal_plan
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meal plan" ON public.meal_plan
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meal plan" ON public.meal_plan
  FOR DELETE USING (auth.uid() = user_id);

-- Shopping list policies
CREATE POLICY "Users can view own shopping list" ON public.shopping_list
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own shopping list items" ON public.shopping_list
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own shopping list items" ON public.shopping_list
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own shopping list items" ON public.shopping_list
  FOR DELETE USING (auth.uid() = user_id);

-- Funktion för att automatiskt skapa en profil när en användare registreras
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, created_at)
  VALUES (NEW.id, NEW.email, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger för att skapa profil vid ny användare
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Funktion för att uppdatera updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers för updated_at
DROP TRIGGER IF EXISTS set_updated_at_profiles ON public.profiles;
CREATE TRIGGER set_updated_at_profiles
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_inventory ON public.inventory_items;
CREATE TRIGGER set_updated_at_inventory
  BEFORE UPDATE ON public.inventory_items
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_recipes ON public.recipes;
CREATE TRIGGER set_updated_at_recipes
  BEFORE UPDATE ON public.recipes
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Klart! Alla tabeller och policies är nu skapade.
-- Du kan testa genom att gå till Table Editor i Supabase och se att alla tabeller finns.
