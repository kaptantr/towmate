-- Location: supabase/migrations/20250805230000_multi_service_admin_enhancements.sql
-- Schema Analysis: Existing service_requests table supports single service_type, need multi-service support
-- Integration Type: enhancement
-- Dependencies: service_requests, user_profiles tables

-- Create new tables for enhanced functionality
CREATE TABLE public.service_request_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    service_type public.service_type NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Admin-managed description options
CREATE TABLE public.service_description_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type public.service_type NOT NULL,
    option_text TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Selected description options for each request
CREATE TABLE public.service_request_description_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE CASCADE,
    description_option_id UUID REFERENCES public.service_description_options(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Admin service configuration
CREATE TABLE public.admin_service_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type public.service_type NOT NULL UNIQUE,
    base_price NUMERIC(10,2) DEFAULT 0.00,
    price_per_km NUMERIC(10,2) DEFAULT 0.00,
    minimum_price NUMERIC(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    service_icon TEXT,
    service_description TEXT,
    estimated_duration_minutes INTEGER DEFAULT 30,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Essential indexes
CREATE INDEX idx_service_request_services_request_id ON public.service_request_services(service_request_id);
CREATE INDEX idx_service_request_services_service_type ON public.service_request_services(service_type);
CREATE INDEX idx_service_description_options_service_type ON public.service_description_options(service_type);
CREATE INDEX idx_service_description_options_active ON public.service_description_options(is_active);
CREATE INDEX idx_service_request_description_options_request_id ON public.service_request_description_options(service_request_id);
CREATE INDEX idx_admin_service_config_service_type ON public.admin_service_config(service_type);
CREATE INDEX idx_admin_service_config_active ON public.admin_service_config(is_active);

-- Enable RLS
ALTER TABLE public.service_request_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_description_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_request_description_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_service_config ENABLE ROW LEVEL SECURITY;

-- Helper function for admin check using auth metadata
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin'
         OR EXISTS (
             SELECT 1 FROM public.user_profiles up 
             WHERE up.id = au.id AND up.role = 'admin'
         ))
)
$$;

-- RLS Policies - Service Request Services
CREATE POLICY "customers_manage_own_service_request_services"
ON public.service_request_services
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id AND sr.customer_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id AND sr.customer_id = auth.uid()
    )
);

CREATE POLICY "drivers_view_assigned_service_request_services"
ON public.service_request_services
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id AND sr.driver_id = auth.uid()
    )
);

CREATE POLICY "admins_manage_all_service_request_services"
ON public.service_request_services
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- RLS Policies - Service Description Options
CREATE POLICY "public_can_read_service_description_options"
ON public.service_description_options
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admins_manage_service_description_options"
ON public.service_description_options
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- RLS Policies - Service Request Description Options
CREATE POLICY "customers_manage_own_service_request_description_options"
ON public.service_request_description_options
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id AND sr.customer_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id AND sr.customer_id = auth.uid()
    )
);

CREATE POLICY "drivers_view_service_request_description_options"
ON public.service_request_description_options
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id AND sr.driver_id = auth.uid()
    )
);

CREATE POLICY "admins_manage_all_service_request_description_options"
ON public.service_request_description_options
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- RLS Policies - Admin Service Config
CREATE POLICY "public_can_read_active_admin_service_config"
ON public.admin_service_config
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admins_manage_admin_service_config"
ON public.admin_service_config
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Sample admin service configurations
DO $$
BEGIN
    INSERT INTO public.admin_service_config (service_type, base_price, price_per_km, minimum_price, service_icon, service_description, estimated_duration_minutes, display_order)
    VALUES
        ('towing'::public.service_type, 100.00, 8.50, 150.00, 'local_shipping', 'Profesyonel çekici hizmeti - aracınızı güvenle istediğiniz yere taşıyoruz', 45, 1),
        ('jumpstart'::public.service_type, 80.00, 0.00, 80.00, 'battery_charging_full', 'Akü takviye servisi - boşalan aküyünüzü hemen şarj ediyoruz', 15, 2),
        ('tire_change'::public.service_type, 120.00, 0.00, 120.00, 'tire_repair', 'Lastik değişimi - patlak lastiğinizi yeni lastik ile değiştiriyoruz', 25, 3),
        ('lockout'::public.service_type, 90.00, 0.00, 90.00, 'lock_open', 'Kapı açma servisi - aracınızın kilitli kapısını hasar vermeden açıyoruz', 20, 4),
        ('fuel_delivery'::public.service_type, 70.00, 5.00, 100.00, 'local_gas_station', 'Yakıt getirme - bulunduğunuz yere yakıt getiriyoruz', 30, 5),
        ('winch_service'::public.service_type, 150.00, 12.00, 200.00, 'construction', 'Vinç hizmeti - sıkışan aracınızı güvenle çıkarıyoruz', 60, 6);

    -- Sample quick description options for each service
    INSERT INTO public.service_description_options (service_type, option_text, display_order)
    VALUES
        -- Towing service options
        ('towing'::public.service_type, 'Araç çalışmıyor, çekici gerekli', 1),
        ('towing'::public.service_type, 'Kaza sonrası çekici talebi', 2),
        ('towing'::public.service_type, 'Motor arızası, hareket edemiyor', 3),
        ('towing'::public.service_type, 'Lastik patladı, yedek yok', 4),
        ('towing'::public.service_type, 'Yakıt bitti, en yakın istasyona', 5),
        
        -- Jumpstart service options
        ('jumpstart'::public.service_type, 'Akü boş, motor çalışmıyor', 1),
        ('jumpstart'::public.service_type, 'Farlar açık kalmış, akü bitmiş', 2),
        ('jumpstart'::public.service_type, 'Soğuk havada akü bitti', 3),
        ('jumpstart'::public.service_type, 'Uzun süre kullanılmamış araç', 4),
        
        -- Tire change options
        ('tire_change'::public.service_type, 'Lastik patladı, yedek var', 1),
        ('tire_change'::public.service_type, 'Lastik patladı, yedek yok', 2),
        ('tire_change'::public.service_type, 'Lastik havalı değil', 3),
        ('tire_change'::public.service_type, 'Jant zarar gördü', 4),
        
        -- Lockout options
        ('lockout'::public.service_type, 'Anahtarlar araçta kaldı', 1),
        ('lockout'::public.service_type, 'Anahtar kırıldı', 2),
        ('lockout'::public.service_type, 'Kumanda çalışmıyor', 3),
        ('lockout'::public.service_type, 'Çocuk kilidi aktif', 4),
        
        -- Fuel delivery options
        ('fuel_delivery'::public.service_type, 'Benzin bitti, istasyona gidemiyorum', 1),
        ('fuel_delivery'::public.service_type, 'Dizel yakıt gerekli', 2),
        ('fuel_delivery'::public.service_type, 'LPG tüpü boş', 3),
        ('fuel_delivery'::public.service_type, 'Yanlış yakıt konuldu', 4),
        
        -- Winch service options
        ('winch_service'::public.service_type, 'Araç çamura saplandı', 1),
        ('winch_service'::public.service_type, 'Kara saplanmış araç', 2),
        ('winch_service'::public.service_type, 'Hendekten çıkarma', 3),
        ('winch_service'::public.service_type, 'Buzda kaymış araç', 4);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Bağımlılık hatası: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Benzersizlik hatası: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Beklenmeyen hata: %', SQLERRM;
END $$;