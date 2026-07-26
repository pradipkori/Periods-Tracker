-- ==========================================
-- PERIOD TRACKER SUPABASE SCHEMA & RLS
-- ==========================================
-- Copy and paste this entire file into the Supabase SQL Editor and click 'Run'.

-- 1. Create Tables

CREATE TABLE public.user_settings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  average_cycle_length INT DEFAULT 28,
  average_period_length INT DEFAULT 5,
  luteal_phase_length INT DEFAULT 14,
  last_period_date TIMESTAMPTZ,
  notifications_enabled BOOLEAN DEFAULT true,
  notification_hour INT DEFAULT 9,
  notification_minute INT DEFAULT 0,
  period_reminder_enabled BOOLEAN DEFAULT true,
  ovulation_reminder_enabled BOOLEAN DEFAULT true,
  daily_log_reminder_enabled BOOLEAN DEFAULT false,
  passcode TEXT,
  biometric_enabled BOOLEAN DEFAULT false,
  user_name TEXT DEFAULT 'User',
  theme TEXT DEFAULT 'light',
  language TEXT DEFAULT 'en',
  pregnancy_mode BOOLEAN DEFAULT false,
  conception_date TIMESTAMPTZ,
  due_date TIMESTAMPTZ,
  has_completed_onboarding BOOLEAN DEFAULT false,
  data_backup_enabled BOOLEAN DEFAULT false,
  last_backup_date TIMESTAMPTZ,
  health_log_streak INT DEFAULT 0,
  last_health_log_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.cycle_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  flow_intensity INT,
  flow_type TEXT,
  notes TEXT,
  symptoms TEXT[] DEFAULT '{}',
  moods TEXT[] DEFAULT '{}',
  is_predicted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.health_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  weight NUMERIC,
  temperature NUMERIC,
  water_intake INT,
  sleep_duration INT,
  exercise_duration INT,
  symptoms TEXT[] DEFAULT '{}',
  moods TEXT[] DEFAULT '{}',
  medications TEXT[] DEFAULT '{}',
  had_intimacy BOOLEAN,
  protected_intimacy BOOLEAN,
  discharge_type TEXT,
  cervical_mucus TEXT,
  ovulation_test_result TEXT,
  pregnancy_test_result TEXT,
  daily_note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date) -- A user can only have one health log per day
);

CREATE TABLE public.reminders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  type TEXT NOT NULL,
  reminder_date TIMESTAMPTZ NOT NULL,
  hour_of_day INT NOT NULL,
  minute INT NOT NULL,
  is_enabled BOOLEAN DEFAULT true,
  is_repeating BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.pregnancy_data (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  weight NUMERIC,
  symptoms TEXT[] DEFAULT '{}',
  moods TEXT[] DEFAULT '{}',
  notes TEXT,
  next_appointment TIMESTAMPTZ,
  doctor_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.stored_notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL,
  type TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  data_json TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Global Articles Table (Read-Only for users)
CREATE TABLE public.articles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 2. Enable Row Level Security (RLS)
-- ==========================================

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cycle_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pregnancy_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stored_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- 3. Create RLS Policies
-- ==========================================
-- These policies ensure that users can ONLY select, insert, update, or delete THEIR OWN data.

-- User Settings
CREATE POLICY "Users can manage their own settings" ON public.user_settings
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Cycle Logs
CREATE POLICY "Users can manage their own cycle logs" ON public.cycle_logs
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Health Logs
CREATE POLICY "Users can manage their own health logs" ON public.health_logs
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Reminders
CREATE POLICY "Users can manage their own reminders" ON public.reminders
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Pregnancy Data
CREATE POLICY "Users can manage their own pregnancy data" ON public.pregnancy_data
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Stored Notifications
CREATE POLICY "Users can manage their own notifications" ON public.stored_notifications
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Articles (Public read, admin write)
CREATE POLICY "Anyone can read articles" ON public.articles
  FOR SELECT USING (true);

-- ==========================================
-- 4. Automatic User Settings Creation Trigger
-- ==========================================
-- When a user signs up via Google, automatically create a default user_settings row for them.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_settings (user_id)
  VALUES (new.id);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
