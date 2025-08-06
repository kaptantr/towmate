-- Location: supabase/migrations/20250105190000_towmate_complete_schema.sql
-- TowMate - Complete Database Schema for Tow Truck Service App
-- Integration Type: Complete new schema creation
-- Dependencies: None (new database setup)

-- 1. CREATE TYPES FIRST
CREATE TYPE public.user_role AS ENUM ('admin', 'driver', 'customer', 'support');
CREATE TYPE public.request_status AS ENUM ('pending', 'accepted', 'in_progress', 'completed', 'cancelled');
CREATE TYPE public.vehicle_type AS ENUM ('sedan', 'suv', 'truck', 'motorcycle', 'heavy_truck', 'bus');
CREATE TYPE public.service_type AS ENUM ('towing', 'jumpstart', 'tire_change', 'lockout', 'fuel_delivery', 'winch_service');
CREATE TYPE public.urgency_level AS ENUM ('low', 'medium', 'high', 'emergency');
CREATE TYPE public.driver_status AS ENUM ('offline', 'online', 'busy', 'break');
CREATE TYPE public.payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded');

-- 2. CREATE CORE TABLES
-- User Profiles Table (intermediary for auth.users)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role public.user_role DEFAULT 'customer'::public.user_role,
    profile_image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Driver Profiles Table
CREATE TABLE public.driver_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    license_number TEXT NOT NULL UNIQUE,
    license_expiry_date DATE NOT NULL,
    vehicle_type public.vehicle_type NOT NULL,
    vehicle_make TEXT NOT NULL,
    vehicle_model TEXT NOT NULL,
    vehicle_year INTEGER NOT NULL,
    license_plate TEXT NOT NULL UNIQUE,
    insurance_number TEXT NOT NULL,
    insurance_expiry_date DATE NOT NULL,
    current_status public.driver_status DEFAULT 'offline'::public.driver_status,
    current_latitude DECIMAL(10,8),
    current_longitude DECIMAL(11,8),
    last_location_update TIMESTAMPTZ,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_jobs INTEGER DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    is_available BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Service Requests Table
CREATE TABLE public.service_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.driver_profiles(id) ON DELETE SET NULL,
    service_type public.service_type NOT NULL,
    vehicle_type public.vehicle_type NOT NULL,
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10,8) NOT NULL,
    pickup_longitude DECIMAL(11,8) NOT NULL,
    destination_address TEXT,
    destination_latitude DECIMAL(10,8),
    destination_longitude DECIMAL(11,8),
    description TEXT,
    urgency public.urgency_level DEFAULT 'medium'::public.urgency_level,
    status public.request_status DEFAULT 'pending'::public.request_status,
    estimated_price DECIMAL(8,2),
    final_price DECIMAL(8,2),
    distance_km DECIMAL(6,2),
    requested_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    customer_notes TEXT,
    driver_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Payments Table
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.driver_profiles(id) ON DELETE CASCADE,
    amount DECIMAL(8,2) NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    payment_status public.payment_status DEFAULT 'pending'::public.payment_status,
    transaction_id TEXT,
    payment_gateway TEXT,
    driver_earnings DECIMAL(8,2),
    platform_fee DECIMAL(8,2),
    tip_amount DECIMAL(8,2) DEFAULT 0.00,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Reviews and Ratings Table
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    reviewee_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_customer_review BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Driver Earnings Table
CREATE TABLE public.driver_earnings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID REFERENCES public.driver_profiles(id) ON DELETE CASCADE,
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    base_amount DECIMAL(8,2) NOT NULL,
    tip_amount DECIMAL(8,2) DEFAULT 0.00,
    bonus_amount DECIMAL(8,2) DEFAULT 0.00,
    total_amount DECIMAL(8,2) NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. CREATE INDEXES
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_driver_profiles_user_id ON public.driver_profiles(user_id);
CREATE INDEX idx_driver_profiles_status ON public.driver_profiles(current_status);
CREATE INDEX idx_driver_profiles_location ON public.driver_profiles(current_latitude, current_longitude);
CREATE INDEX idx_service_requests_customer_id ON public.service_requests(customer_id);
CREATE INDEX idx_service_requests_driver_id ON public.service_requests(driver_id);
CREATE INDEX idx_service_requests_status ON public.service_requests(status);
CREATE INDEX idx_service_requests_location ON public.service_requests(pickup_latitude, pickup_longitude);
CREATE INDEX idx_payments_service_request_id ON public.payments(service_request_id);
CREATE INDEX idx_reviews_service_request_id ON public.reviews(service_request_id);
CREATE INDEX idx_driver_earnings_driver_id ON public.driver_earnings(driver_id);
CREATE INDEX idx_driver_earnings_date ON public.driver_earnings(date);

-- 4. ENABLE RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_earnings ENABLE ROW LEVEL SECURITY;

-- 5. CREATE HELPER FUNCTIONS
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

CREATE OR REPLACE FUNCTION public.is_driver()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'driver'
)
$$;

-- 6. CREATE RLS POLICIES

-- User Profiles Policies (Pattern 1: Core User Table)
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Driver Profiles Policies
CREATE POLICY "drivers_manage_own_driver_profiles"
ON public.driver_profiles
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "customers_view_available_drivers"
ON public.driver_profiles
FOR SELECT
TO authenticated
USING (is_available = true AND current_status = 'online');

CREATE POLICY "admins_manage_all_driver_profiles"
ON public.driver_profiles
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Service Requests Policies
CREATE POLICY "customers_manage_own_service_requests"
ON public.service_requests
FOR ALL
TO authenticated
USING (customer_id = auth.uid())
WITH CHECK (customer_id = auth.uid());

CREATE POLICY "drivers_view_assigned_requests"
ON public.service_requests
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.user_id = auth.uid() AND dp.id = driver_id
    )
);

CREATE POLICY "drivers_update_assigned_requests"
ON public.service_requests
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.user_id = auth.uid() AND dp.id = driver_id
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.user_id = auth.uid() AND dp.id = driver_id
    )
);

CREATE POLICY "admins_manage_all_service_requests"
ON public.service_requests
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Payments Policies
CREATE POLICY "customers_view_own_payments"
ON public.payments
FOR SELECT
TO authenticated
USING (customer_id = auth.uid());

CREATE POLICY "drivers_view_own_payments"
ON public.payments
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.user_id = auth.uid() AND dp.id = driver_id
    )
);

CREATE POLICY "admins_manage_all_payments"
ON public.payments
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Reviews Policies
CREATE POLICY "users_manage_own_reviews"
ON public.reviews
FOR ALL
TO authenticated
USING (reviewer_id = auth.uid())
WITH CHECK (reviewer_id = auth.uid());

CREATE POLICY "users_view_reviews_about_them"
ON public.reviews
FOR SELECT
TO authenticated
USING (reviewee_id = auth.uid());

-- Driver Earnings Policies
CREATE POLICY "drivers_view_own_earnings"
ON public.driver_earnings
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.user_id = auth.uid() AND dp.id = driver_id
    )
);

CREATE POLICY "admins_manage_all_earnings"
ON public.driver_earnings
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 7. CREATE TRIGGERS AND FUNCTIONS
-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')::public.user_role
  );
  RETURN NEW;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update driver location
CREATE OR REPLACE FUNCTION public.update_driver_location(
  driver_user_id UUID,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.driver_profiles
  SET 
    current_latitude = latitude,
    current_longitude = longitude,
    last_location_update = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
  WHERE user_id = driver_user_id;
  
  RETURN FOUND;
END;
$$;

-- Function to calculate distance between two points
CREATE OR REPLACE FUNCTION public.calculate_distance(
  lat1 DECIMAL(10,8),
  lon1 DECIMAL(11,8),
  lat2 DECIMAL(10,8),
  lon2 DECIMAL(11,8)
)
RETURNS DECIMAL(6,2)
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  earth_radius CONSTANT DECIMAL := 6371.0; -- Earth radius in kilometers
  dlat DECIMAL;
  dlon DECIMAL;
  a DECIMAL;
  c DECIMAL;
BEGIN
  dlat := radians(lat2 - lat1);
  dlon := radians(lon2 - lon1);
  
  a := sin(dlat/2) * sin(dlat/2) + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2) * sin(dlon/2);
  c := 2 * atan2(sqrt(a), sqrt(1-a));
  
  RETURN earth_radius * c;
END;
$$;

-- 8. MOCK DATA
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    driver1_uuid UUID := gen_random_uuid();
    driver2_uuid UUID := gen_random_uuid();
    customer1_uuid UUID := gen_random_uuid();
    customer2_uuid UUID := gen_random_uuid();
    driver_profile1_id UUID := gen_random_uuid();
    driver_profile2_id UUID := gen_random_uuid();
    request1_id UUID := gen_random_uuid();
    request2_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@towmate.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "TowMate Admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (driver1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'mehmet.driver@towmate.com', crypt('driver123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Mehmet Yılmaz", "role": "driver"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (driver2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'ali.driver@towmate.com', crypt('driver123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Ali Demir", "role": "driver"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (customer1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'ayse.customer@towmate.com', crypt('customer123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Ayşe Demir", "role": "customer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (customer2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'fatma.customer@towmate.com', crypt('customer123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Fatma Kaya", "role": "customer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert driver profiles
    INSERT INTO public.driver_profiles (
        id, user_id, license_number, license_expiry_date, vehicle_type, vehicle_make, 
        vehicle_model, vehicle_year, license_plate, insurance_number, insurance_expiry_date,
        current_status, current_latitude, current_longitude, rating, total_jobs, 
        total_earnings, is_available
    ) VALUES
        (driver_profile1_id, driver1_uuid, 'DRV001234', '2025-12-31', 'heavy_truck', 'Mercedes',
         'Actros', 2020, '34 ABC 123', 'INS001234', '2025-06-30',
         'online', 41.0082, 28.9784, 4.8, 247, 12350.00, true),
        (driver_profile2_id, driver2_uuid, 'DRV005678', '2026-03-15', 'truck', 'Ford',
         'Transit', 2019, '06 DEF 456', 'INS005678', '2025-09-30',
         'online', 41.0156, 28.9796, 4.6, 189, 9500.00, true);

    -- Insert service requests
    INSERT INTO public.service_requests (
        id, customer_id, driver_id, service_type, vehicle_type, pickup_address,
        pickup_latitude, pickup_longitude, destination_address, destination_latitude,
        destination_longitude, description, urgency, status, estimated_price,
        distance_km, requested_at, accepted_at
    ) VALUES
        (request1_id, customer1_uuid, driver_profile1_id, 'towing', 'sedan', 
         'Taksim Meydanı, Beyoğlu/İstanbul', 41.0367, 28.9850,
         'Kadıköy İskelesi, Kadıköy/İstanbul', 41.0082, 29.0246,
         'Car broke down, need towing to service center', 'high', 'accepted', 180.00,
         12.3, now() - interval '30 minutes', now() - interval '25 minutes'),
        (request2_id, customer2_uuid, null, 'jumpstart', 'suv',
         'Beşiktaş Çarşı, Beşiktaş/İstanbul', 41.0422, 29.0014,
         null, null, null,
         'Battery died, need jumpstart service', 'medium', 'pending', 80.00,
         0, now() - interval '10 minutes', null);

    -- Insert payments
    INSERT INTO public.payments (
        service_request_id, customer_id, driver_id, amount, payment_method,
        payment_status, driver_earnings, platform_fee, tip_amount
    ) VALUES
        (request1_id, customer1_uuid, driver_profile1_id, 180.00, 'credit_card',
         'completed', 153.00, 27.00, 15.00);

    -- Insert driver earnings
    INSERT INTO public.driver_earnings (
        driver_id, service_request_id, base_amount, tip_amount, total_amount, date
    ) VALUES
        (driver_profile1_id, request1_id, 153.00, 15.00, 168.00, CURRENT_DATE);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;