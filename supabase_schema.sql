-- Shvil Database Schema for Supabase
-- This file contains the complete database schema for the Shvil app

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create custom types
CREATE TYPE place_type AS ENUM ('home', 'work', 'favorite', 'custom');
CREATE TYPE route_type AS ENUM ('fastest', 'safest', 'scenic', 'balanced');
CREATE TYPE adventure_status AS ENUM ('draft', 'active', 'completed', 'cancelled');
CREATE TYPE stop_category AS ENUM ('landmark', 'food', 'scenic', 'museum', 'activity', 'nightlife', 'hidden_gem');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Saved Places table
CREATE TABLE public.saved_places (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    type place_type NOT NULL DEFAULT 'custom',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Friends table
CREATE TABLE public.friends (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    friend_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- pending, accepted, blocked
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, friend_id)
);

-- Friend Locations table (for real-time location sharing)
CREATE TABLE public.friend_locations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION DEFAULT 10.0,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ETA Shares table
CREATE TABLE public.eta_shares (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    route_data JSONB NOT NULL, -- Store RouteInfo as JSON
    recipients TEXT[] NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Group Trips table
CREATE TABLE public.group_trips (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    creator_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    destination_latitude DOUBLE PRECISION NOT NULL,
    destination_longitude DOUBLE PRECISION NOT NULL,
    destination_name TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'planning', -- planning, active, completed, cancelled
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group Trip Participants table
CREATE TABLE public.group_trip_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    trip_id UUID REFERENCES public.group_trips(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'invited', -- invited, accepted, declined
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(trip_id, user_id)
);

-- Adventure Plans table
CREATE TABLE public.adventure_plans (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    city TEXT NOT NULL,
    duration_hours INTEGER NOT NULL,
    mood TEXT NOT NULL,
    is_group BOOLEAN DEFAULT false,
    status adventure_status DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adventure Stops table
CREATE TABLE public.adventure_stops (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    adventure_id UUID REFERENCES public.adventure_plans(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    category stop_category NOT NULL,
    order_index INTEGER NOT NULL,
    estimated_duration INTEGER, -- in minutes
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Safety Reports table
CREATE TABLE public.safety_reports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    report_type TEXT NOT NULL, -- incident, hazard, general
    description TEXT,
    severity INTEGER DEFAULT 1, -- 1-5 scale
    is_resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_saved_places_user_id ON public.saved_places(user_id);
CREATE INDEX idx_saved_places_type ON public.saved_places(type);
CREATE INDEX idx_friends_user_id ON public.friends(user_id);
CREATE INDEX idx_friends_friend_id ON public.friends(friend_id);
CREATE INDEX idx_friend_locations_user_id ON public.friend_locations(user_id);
CREATE INDEX idx_friend_locations_timestamp ON public.friend_locations(timestamp);
CREATE INDEX idx_eta_shares_user_id ON public.eta_shares(user_id);
CREATE INDEX idx_eta_shares_active ON public.eta_shares(is_active);
CREATE INDEX idx_group_trips_creator_id ON public.group_trips(creator_id);
CREATE INDEX idx_group_trip_participants_trip_id ON public.group_trip_participants(trip_id);
CREATE INDEX idx_group_trip_participants_user_id ON public.group_trip_participants(user_id);
CREATE INDEX idx_adventure_plans_user_id ON public.adventure_plans(user_id);
CREATE INDEX idx_adventure_stops_adventure_id ON public.adventure_stops(adventure_id);
CREATE INDEX idx_safety_reports_location ON public.safety_reports USING GIST(ST_Point(longitude, latitude));
CREATE INDEX idx_safety_reports_created_at ON public.safety_reports(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friend_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.eta_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_trip_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.adventure_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.adventure_stops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.safety_reports ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own data
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Saved places policies
CREATE POLICY "Users can view own saved places" ON public.saved_places
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own saved places" ON public.saved_places
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own saved places" ON public.saved_places
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own saved places" ON public.saved_places
    FOR DELETE USING (auth.uid() = user_id);

-- Friends policies
CREATE POLICY "Users can view their friends" ON public.friends
    FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can manage their friendships" ON public.friends
    FOR ALL USING (auth.uid() = user_id);

-- Friend locations policies
CREATE POLICY "Users can view friend locations" ON public.friend_locations
    FOR SELECT USING (
        auth.uid() = user_id OR 
        EXISTS (
            SELECT 1 FROM public.friends 
            WHERE (user_id = auth.uid() AND friend_id = public.friend_locations.user_id)
            OR (friend_id = auth.uid() AND user_id = public.friend_locations.user_id)
        )
    );

CREATE POLICY "Users can insert own location" ON public.friend_locations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ETA shares policies
CREATE POLICY "Users can view own ETA shares" ON public.eta_shares
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create ETA shares" ON public.eta_shares
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own ETA shares" ON public.eta_shares
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own ETA shares" ON public.eta_shares
    FOR DELETE USING (auth.uid() = user_id);

-- Group trips policies
CREATE POLICY "Users can view trips they're part of" ON public.group_trips
    FOR SELECT USING (
        auth.uid() = creator_id OR 
        EXISTS (
            SELECT 1 FROM public.group_trip_participants 
            WHERE trip_id = public.group_trips.id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create trips" ON public.group_trips
    FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Trip creators can update trips" ON public.group_trips
    FOR UPDATE USING (auth.uid() = creator_id);

-- Group trip participants policies
CREATE POLICY "Users can view trip participants" ON public.group_trip_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.group_trips 
            WHERE id = public.group_trip_participants.trip_id 
            AND (creator_id = auth.uid() OR EXISTS (
                SELECT 1 FROM public.group_trip_participants gtp2 
                WHERE gtp2.trip_id = public.group_trips.id AND gtp2.user_id = auth.uid()
            ))
        )
    );

CREATE POLICY "Trip creators can manage participants" ON public.group_trip_participants
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.group_trips 
            WHERE id = public.group_trip_participants.trip_id AND creator_id = auth.uid()
        )
    );

-- Adventure plans policies
CREATE POLICY "Users can view own adventures" ON public.adventure_plans
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create adventures" ON public.adventure_plans
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own adventures" ON public.adventure_plans
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own adventures" ON public.adventure_plans
    FOR DELETE USING (auth.uid() = user_id);

-- Adventure stops policies
CREATE POLICY "Users can view adventure stops" ON public.adventure_stops
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.adventure_plans 
            WHERE id = public.adventure_stops.adventure_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage adventure stops" ON public.adventure_stops
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.adventure_plans 
            WHERE id = public.adventure_stops.adventure_id AND user_id = auth.uid()
        )
    );

-- Safety reports policies
CREATE POLICY "Users can view safety reports" ON public.safety_reports
    FOR SELECT USING (true); -- Public safety information

CREATE POLICY "Users can create safety reports" ON public.safety_reports
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own safety reports" ON public.safety_reports
    FOR UPDATE USING (auth.uid() = user_id);

-- Create functions for common operations
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, display_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'display_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_saved_places_updated_at BEFORE UPDATE ON public.saved_places
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_group_trips_updated_at BEFORE UPDATE ON public.group_trips
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_adventure_plans_updated_at BEFORE UPDATE ON public.adventure_plans
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_safety_reports_updated_at BEFORE UPDATE ON public.safety_reports
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
