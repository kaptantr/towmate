-- Location: supabase/migrations/20250805230000_calltowing_multi_service_admin_features.sql
-- Schema Analysis: Existing service_requests table with single service_type enum, user_profiles, driver_profiles
-- Integration Type: Extension - Adding multi-service support and admin configuration
-- Dependencies: service_requests, user_profiles (existing tables)

-- 1. Create new types for admin configurations
CREATE TYPE public.description_category AS ENUM ('vehicle_condition', 'location_details', 'urgency_details', 'additional_notes');

-- 2. Create admin configuration tables for service management
CREATE TABLE public.admin_service_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type public.service_type NOT NULL,
    display_name TEXT NOT NULL,
    base_price NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    icon_name TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.admin_description_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category public.description_category NOT NULL,
    service_type public.service_type,  -- NULL means applies to all services
    option_text TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create multi-service request support
CREATE TABLE public.service_request_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    service_type public.service_type NOT NULL,
    estimated_price NUMERIC(10,2),
    final_price NUMERIC(10,2),
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.service_request_descriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    description_option_id UUID REFERENCES public.admin_description_options(id) ON DELETE SET NULL,
    custom_description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create pricing rules table for multi-service discounts
CREATE TABLE public.pricing_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    rule_type TEXT NOT NULL DEFAULT 'multi_service_discount', -- 'multi_service_discount', 'distance_multiplier', 'urgency_surcharge'
    min_services INTEGER DEFAULT 2,
    discount_percentage NUMERIC(5,2) DEFAULT 0.00,
    discount_amount NUMERIC(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Create location address cache for reverse geocoding results
CREATE TABLE public.location_address_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    latitude NUMERIC(10,8) NOT NULL,
    longitude NUMERIC(11,8) NOT NULL,
    formatted_address TEXT NOT NULL,
    street_number TEXT,
    street_name TEXT,
    neighborhood TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days')
);

-- 6. Add indexes for performance
CREATE INDEX idx_admin_service_configurations_service_type ON public.admin_service_configurations(service_type);
CREATE INDEX idx_admin_service_configurations_is_active ON public.admin_service_configurations(is_active);
CREATE INDEX idx_admin_description_options_category ON public.admin_description_options(category);
CREATE INDEX idx_admin_description_options_service_type ON public.admin_description_options(service_type);
CREATE INDEX idx_service_request_items_request_id ON public.service_request_items(service_request_id);
CREATE INDEX idx_service_request_items_service_type ON public.service_request_items(service_type);
CREATE INDEX idx_service_request_descriptions_request_id ON public.service_request_descriptions(service_request_id);
CREATE INDEX idx_pricing_rules_rule_type ON public.pricing_rules(rule_type);
CREATE INDEX idx_pricing_rules_is_active ON public.pricing_rules(is_active);
CREATE INDEX idx_location_address_cache_coords ON public.location_address_cache(latitude, longitude);
CREATE INDEX idx_location_address_cache_expires ON public.location_address_cache(expires_at);

-- 7. Create functions for admin management
CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
)
$$;

CREATE OR REPLACE FUNCTION public.get_service_pricing(
    service_types_param public.service_type[],
    urgency_param public.urgency_level DEFAULT 'medium'
)
RETURNS TABLE(
    service_type public.service_type,
    base_price NUMERIC,
    final_price NUMERIC,
    total_discount NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    service_count INTEGER;
    multi_service_discount NUMERIC := 0;
    urgency_multiplier NUMERIC := 1.0;
BEGIN
    service_count := array_length(service_types_param, 1);
    
    -- Get multi-service discount
    IF service_count >= 2 THEN
        SELECT COALESCE(discount_percentage, 0) INTO multi_service_discount
        FROM public.pricing_rules
        WHERE rule_type = 'multi_service_discount'
        AND min_services <= service_count
        AND is_active = true
        ORDER BY min_services DESC
        LIMIT 1;
    END IF;
    
    -- Get urgency multiplier
    CASE urgency_param
        WHEN 'high' THEN urgency_multiplier := 1.25;
        WHEN 'emergency' THEN urgency_multiplier := 1.5;
        ELSE urgency_multiplier := 1.0;
    END CASE;
    
    RETURN QUERY
    SELECT 
        asc.service_type,
        asc.base_price,
        (asc.base_price * urgency_multiplier * (100 - multi_service_discount) / 100),
        (asc.base_price * multi_service_discount / 100)
    FROM public.admin_service_configurations asc
    WHERE asc.service_type = ANY(service_types_param)
    AND asc.is_active = true;
END;
$$;

-- 8. Enable RLS on new tables
ALTER TABLE public.admin_service_configurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_description_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_request_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_request_descriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pricing_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_address_cache ENABLE ROW LEVEL SECURITY;

-- 9. Create RLS policies for admin tables
CREATE POLICY "admins_manage_service_configurations"
ON public.admin_service_configurations
FOR ALL
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());

CREATE POLICY "everyone_can_read_service_configurations"
ON public.admin_service_configurations
FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "admins_manage_description_options"
ON public.admin_description_options
FOR ALL
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());

CREATE POLICY "everyone_can_read_description_options"
ON public.admin_description_options
FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "users_manage_own_service_request_items"
ON public.service_request_items
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_items.service_request_id
        AND sr.customer_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_items.service_request_id
        AND sr.customer_id = auth.uid()
    )
);

CREATE POLICY "drivers_view_assigned_service_items"
ON public.service_request_items
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        JOIN public.driver_profiles dp ON sr.driver_id = dp.id
        WHERE sr.id = service_request_items.service_request_id
        AND dp.user_id = auth.uid()
    )
);

CREATE POLICY "users_manage_own_service_descriptions"
ON public.service_request_descriptions
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_descriptions.service_request_id
        AND sr.customer_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_descriptions.service_request_id
        AND sr.customer_id = auth.uid()
    )
);

CREATE POLICY "admins_manage_pricing_rules"
ON public.pricing_rules
FOR ALL
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());

CREATE POLICY "everyone_can_read_pricing_rules"
ON public.pricing_rules
FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "everyone_manages_location_cache"
ON public.location_address_cache
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 10. Insert default admin configurations
DO $$
BEGIN
    -- Insert default service configurations
    INSERT INTO public.admin_service_configurations (service_type, display_name, base_price, icon_name, description) VALUES
        ('towing', 'Çekici Hizmeti', 180.00, 'local_shipping', 'Aracınızı güvenli bir şekilde istediğiniz yere çekeriz'),
        ('jumpstart', 'Akü Takviye', 80.00, 'battery_charging_full', 'Boşalmış aküyü çalıştırır, aracınızı yeniden hayata döndürürüz'),
        ('tire_change', 'Lastik Değişimi', 120.00, 'tire_repair', 'Patlak lastiğinizi yedek lastikle değiştiririz'),
        ('lockout', 'Kapı Açma', 100.00, 'lock_open', 'Anahtarınızı içerde unuttuğunuzda aracınızı açarız'),
        ('fuel_delivery', 'Yakıt Getirme', 150.00, 'local_gas_station', 'Yakıtınız bittiğinde size yakıt getiririz'),
        ('winch_service', 'Vinç Hizmeti', 250.00, 'construction', 'Çamura saplanan veya hendekte kalan aracınızı çıkarırız');

    -- Insert default description options
    INSERT INTO public.admin_description_options (category, service_type, option_text, display_order) VALUES
        -- Vehicle condition options
        ('vehicle_condition', NULL, 'Araç çalışmıyor', 1),
        ('vehicle_condition', NULL, 'Motor çalışıyor ama hareket etmiyor', 2),
        ('vehicle_condition', NULL, 'Araç tamamen arızalı', 3),
        ('vehicle_condition', 'tire_change', 'Ön sol lastik patlak', 4),
        ('vehicle_condition', 'tire_change', 'Ön sağ lastik patlak', 5),
        ('vehicle_condition', 'tire_change', 'Arka sol lastik patlak', 6),
        ('vehicle_condition', 'tire_change', 'Arka sağ lastik patlak', 7),
        ('vehicle_condition', 'jumpstart', 'Akü tamamen boş', 8),
        ('vehicle_condition', 'jumpstart', 'Marş sesi geliyor ama çalışmıyor', 9),
        ('vehicle_condition', 'lockout', 'Anahtarlar içerde kaldı', 10),
        ('vehicle_condition', 'lockout', 'Kapı kilidi bozuk', 11),
        
        -- Location details
        ('location_details', NULL, 'Ana yol kenarında', 1),
        ('location_details', NULL, 'Yan sokakta', 2),
        ('location_details', NULL, 'Otopark içinde', 3),
        ('location_details', NULL, 'Garaj içinde', 4),
        ('location_details', NULL, 'Trafik çok yoğun', 5),
        ('location_details', NULL, 'Çok sessiz bir bölge', 6),
        
        -- Urgency details
        ('urgency_details', NULL, 'Acil değil, zamanım var', 1),
        ('urgency_details', NULL, 'Mümkün olan en kısa sürede', 2),
        ('urgency_details', NULL, 'Çok acil, işe geç kalacağım', 3),
        ('urgency_details', NULL, 'Gece yarısı, güvenlik endişesi var', 4),
        
        -- Additional notes
        ('additional_notes', NULL, 'Çekici kamyon gerekli değil', 1),
        ('additional_notes', NULL, 'Büyük araç, özel ekipman gerekli', 2),
        ('additional_notes', NULL, 'Aracın üzerinde kargo var', 3),
        ('additional_notes', NULL, 'Sigortam var, evrak hazır', 4),
        ('additional_notes', NULL, 'Nakit ödeme yapacağım', 5),
        ('additional_notes', NULL, 'Kredi kartıyla ödeme yapacağım', 6);

    -- Insert default pricing rules
    INSERT INTO public.pricing_rules (name, rule_type, min_services, discount_percentage, discount_amount) VALUES
        ('İki Hizmet İndirimi', 'multi_service_discount', 2, 10.00, 0.00),
        ('Üç Hizmet İndirimi', 'multi_service_discount', 3, 15.00, 0.00),
        ('Dört ve Üzeri Hizmet İndirimi', 'multi_service_discount', 4, 20.00, 0.00);
END $$;