-- Location: supabase/migrations/20250806010000_calltowing_missing_tables.sql
-- Schema Analysis: Existing tables include user_profiles, driver_profiles, service_requests, payments, driver_earnings, reviews
-- Integration Type: Addition - Adding missing tables that services reference
-- Dependencies: user_profiles, driver_profiles, service_requests

-- Add missing admin service configurations table
CREATE TABLE public.admin_service_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type public.service_type NOT NULL,
    display_name TEXT NOT NULL,
    icon_name TEXT,
    base_price NUMERIC(10,2) DEFAULT 0.00,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add missing admin description options table  
CREATE TABLE public.admin_description_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type public.service_type,
    category TEXT NOT NULL,
    option_text TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add missing location address cache table
CREATE TABLE public.location_address_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    latitude NUMERIC(10,8) NOT NULL,
    longitude NUMERIC(11,8) NOT NULL,
    formatted_address TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add missing service request items table for multi-service support
CREATE TABLE public.service_request_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    service_type public.service_type NOT NULL,
    estimated_price NUMERIC(10,2) DEFAULT 0.00,
    status public.request_status DEFAULT 'pending'::public.request_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add missing service request descriptions table
CREATE TABLE public.service_request_descriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    custom_description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add missing admin activity logs table
CREATE TABLE public.admin_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    description TEXT,
    affected_entity_type TEXT,
    affected_entity_id UUID,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add missing admin system statistics table
CREATE TABLE public.admin_system_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stat_name TEXT NOT NULL UNIQUE,
    stat_value NUMERIC,
    stat_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create essential indexes
CREATE INDEX idx_admin_service_configurations_service_type ON public.admin_service_configurations(service_type);
CREATE INDEX idx_admin_description_options_service_type ON public.admin_description_options(service_type);
CREATE INDEX idx_admin_description_options_category ON public.admin_description_options(category);
CREATE INDEX idx_location_address_cache_coords ON public.location_address_cache(latitude, longitude);
CREATE INDEX idx_location_address_cache_expires ON public.location_address_cache(expires_at);
CREATE INDEX idx_service_request_items_service_request_id ON public.service_request_items(service_request_id);
CREATE INDEX idx_service_request_descriptions_service_request_id ON public.service_request_descriptions(service_request_id);
CREATE INDEX idx_admin_activity_logs_admin_user_id ON public.admin_activity_logs(admin_user_id);
CREATE INDEX idx_admin_activity_logs_created_at ON public.admin_activity_logs(created_at);
CREATE INDEX idx_admin_system_statistics_stat_name ON public.admin_system_statistics(stat_name);
CREATE INDEX idx_admin_system_statistics_stat_date ON public.admin_system_statistics(stat_date);

-- Enable RLS for all new tables
ALTER TABLE public.admin_service_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_description_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_address_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_request_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_request_descriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_system_statistics ENABLE ROW LEVEL SECURITY;

-- Create helper function for admin access
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'::public.user_role
)
$$;

-- Create RLS policies using proper patterns
-- Admin configuration tables - only admins can manage
CREATE POLICY "admins_manage_service_configurations"
ON public.admin_service_configurations
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "admins_manage_description_options"
ON public.admin_description_options
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Location cache - all authenticated users can use
CREATE POLICY "authenticated_users_access_location_cache"
ON public.location_address_cache
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Service request related tables - customers and drivers can access their own
CREATE POLICY "users_manage_own_service_request_items"
ON public.service_request_items
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id
        AND (sr.customer_id = auth.uid() OR sr.driver_id IN (
            SELECT dp.id FROM public.driver_profiles dp WHERE dp.user_id = auth.uid()
        ))
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id
        AND sr.customer_id = auth.uid()
    )
);

CREATE POLICY "users_manage_own_service_request_descriptions"
ON public.service_request_descriptions
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id
        AND (sr.customer_id = auth.uid() OR sr.driver_id IN (
            SELECT dp.id FROM public.driver_profiles dp WHERE dp.user_id = auth.uid()
        ))
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id
        AND sr.customer_id = auth.uid()
    )
);

-- Admin activity logs - only admins can access
CREATE POLICY "admins_manage_activity_logs"
ON public.admin_activity_logs
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- System statistics - only admins can manage
CREATE POLICY "admins_manage_system_statistics"
ON public.admin_system_statistics
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Insert initial service configurations
DO $$
BEGIN
    INSERT INTO public.admin_service_configurations (service_type, display_name, icon_name, base_price, description) VALUES
        ('towing'::public.service_type, 'Araç Çekme', 'local_shipping', 150.00, 'Profesyonel araç çekme hizmeti'),
        ('jumpstart'::public.service_type, 'Akü Takviyesi', 'battery_charging_full', 80.00, 'Boşalan akü için acil takviye'),
        ('tire_change'::public.service_type, 'Lastik Değişimi', 'tire_repair', 100.00, 'Patlak lastik değişim hizmeti'),
        ('lockout'::public.service_type, 'Kapı Açma', 'lock_open', 120.00, 'Araç içinde kalan anahtar sorunu'),
        ('fuel_delivery'::public.service_type, 'Yakıt İkmali', 'local_gas_station', 90.00, 'Acil yakıt getirme hizmeti'),
        ('winch_service'::public.service_type, 'Vinç Hizmeti', 'construction', 200.00, 'Ağır vinç operasyonları');

    INSERT INTO public.admin_description_options (service_type, category, option_text, display_order) VALUES
        ('towing'::public.service_type, 'Araç Durumu', 'Motor çalışmıyor', 1),
        ('towing'::public.service_type, 'Araç Durumu', 'Kaza geçirdi', 2),
        ('towing'::public.service_type, 'Araç Durumu', 'Lastik patladı', 3),
        ('jumpstart'::public.service_type, 'Akü Durumu', 'Akü tamamen bitmiş', 1),
        ('jumpstart'::public.service_type, 'Akü Durumu', 'Motor çalışmıyor', 2),
        ('tire_change'::public.service_type, 'Lastik Sorunu', 'Patlak lastik', 1),
        ('tire_change'::public.service_type, 'Lastik Sorunu', 'Yedek lastik yok', 2),
        ('lockout'::public.service_type, 'Kilit Sorunu', 'Anahtar araçta kaldı', 1),
        ('lockout'::public.service_type, 'Kilit Sorunu', 'Anahtar kırıldı', 2);

    INSERT INTO public.admin_system_statistics (stat_name, stat_value) VALUES
        ('total_users', 150),
        ('active_drivers', 25),
        ('pending_verifications', 8),
        ('total_revenue', 45750.00),
        ('total_requests', 234),
        ('completion_rate', 94.5);
END $$;