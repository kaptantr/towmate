-- Location: supabase/migrations/20250805220000_calltowing_enhanced_features.sql
-- Schema Analysis: Existing CallTowing database with user_profiles, service_requests, driver_profiles, payments tables
-- Integration Type: Enhancement - Adding advanced notification and insurance claim features
-- Dependencies: user_profiles, service_requests, driver_profiles tables

-- Only create NEW objects that don't exist in schema
-- Reference existing objects from schema analysis

-- Create notification categories enum
CREATE TYPE public.notification_category AS ENUM (
    'service_updates', 
    'system_alerts', 
    'promotions', 
    'emergency'
);

-- Create notification priority enum  
CREATE TYPE public.notification_priority AS ENUM (
    'low',
    'medium', 
    'high',
    'emergency'
);

-- Create insurance claim status enum
CREATE TYPE public.claim_status AS ENUM (
    'draft',
    'submitted',
    'under_review',
    'approved',
    'rejected',
    'payment_processing',
    'completed'
);

-- Create damage severity enum
CREATE TYPE public.damage_severity AS ENUM (
    'minor',
    'moderate',
    'severe',
    'total_loss'
);

-- Create notifications table
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    category public.notification_category NOT NULL DEFAULT 'system_alerts',
    priority public.notification_priority NOT NULL DEFAULT 'medium',
    is_read BOOLEAN DEFAULT false,
    is_starred BOOLEAN DEFAULT false,
    has_media BOOLEAN DEFAULT false,
    action_required BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}',
    location_data JSONB DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ DEFAULT NULL,
    acknowledged_at TIMESTAMPTZ DEFAULT NULL
);

-- Create insurance companies table
CREATE TABLE public.insurance_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    logo_url TEXT,
    claim_phone TEXT,
    online_portal TEXT,
    supported_languages TEXT[] DEFAULT ARRAY['tr', 'en'],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create insurance claims table
CREATE TABLE public.insurance_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_number TEXT NOT NULL UNIQUE,
    customer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    service_request_id UUID REFERENCES public.service_requests(id) ON DELETE SET NULL,
    insurance_company_id UUID REFERENCES public.insurance_companies(id) ON DELETE SET NULL,
    status public.claim_status DEFAULT 'draft',
    incident_type TEXT NOT NULL,
    incident_description TEXT NOT NULL,
    incident_date DATE NOT NULL,
    incident_time TIME NOT NULL,
    location_address TEXT NOT NULL,
    location_coordinates POINT,
    weather_condition TEXT,
    police_report_number TEXT,
    witness_name TEXT,
    witness_phone TEXT,
    damage_severity public.damage_severity,
    estimated_cost DECIMAL(10,2),
    final_amount DECIMAL(10,2),
    repair_timeframe TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

-- Create claim documents table
CREATE TABLE public.claim_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID REFERENCES public.insurance_claims(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    uploaded_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create claim damage areas table (for tracking multiple damaged parts)
CREATE TABLE public.claim_damage_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID REFERENCES public.insurance_claims(id) ON DELETE CASCADE,
    area_name TEXT NOT NULL,
    damage_description TEXT,
    estimated_repair_cost DECIMAL(10,2)
);

-- Create claim timeline table
CREATE TABLE public.claim_timeline (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID REFERENCES public.insurance_claims(id) ON DELETE CASCADE,
    step_name TEXT NOT NULL,
    step_description TEXT,
    completed_at TIMESTAMPTZ,
    expected_completion TIMESTAMPTZ,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create notification settings table
CREATE TABLE public.notification_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    push_notifications BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    sound_enabled BOOLEAN DEFAULT true,
    vibration_enabled BOOLEAN DEFAULT true,
    quiet_hours_enabled BOOLEAN DEFAULT false,
    quiet_hours_start TIME DEFAULT '22:00:00',
    quiet_hours_end TIME DEFAULT '07:00:00',
    preferred_language TEXT DEFAULT 'tr',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_category ON public.notifications(category);
CREATE INDEX idx_notifications_priority ON public.notifications(priority);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = false;

CREATE INDEX idx_insurance_claims_customer_id ON public.insurance_claims(customer_id);
CREATE INDEX idx_insurance_claims_status ON public.insurance_claims(status);
CREATE INDEX idx_insurance_claims_claim_number ON public.insurance_claims(claim_number);
CREATE INDEX idx_insurance_claims_created_at ON public.insurance_claims(created_at DESC);

CREATE INDEX idx_claim_documents_claim_id ON public.claim_documents(claim_id);
CREATE INDEX idx_claim_damage_areas_claim_id ON public.claim_damage_areas(claim_id);
CREATE INDEX idx_claim_timeline_claim_id ON public.claim_timeline(claim_id);

-- Enable RLS for all new tables
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insurance_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insurance_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.claim_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.claim_damage_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.claim_timeline ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies using Pattern 2 (Simple User Ownership)
CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_insurance_claims"
ON public.insurance_claims
FOR ALL
TO authenticated
USING (customer_id = auth.uid())
WITH CHECK (customer_id = auth.uid());

CREATE POLICY "users_manage_own_notification_settings"
ON public.notification_settings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Insurance companies are public read, admin manage
CREATE POLICY "public_can_read_insurance_companies"
ON public.insurance_companies
FOR SELECT
TO public
USING (true);

-- Claim documents - users can manage documents for their own claims
CREATE OR REPLACE FUNCTION public.user_owns_claim(claim_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.insurance_claims ic
    WHERE ic.id = claim_uuid AND ic.customer_id = auth.uid()
)
$$;

CREATE POLICY "users_manage_own_claim_documents"
ON public.claim_documents
FOR ALL
TO authenticated
USING (public.user_owns_claim(claim_id))
WITH CHECK (public.user_owns_claim(claim_id));

CREATE POLICY "users_manage_own_claim_damage_areas"
ON public.claim_damage_areas
FOR ALL
TO authenticated
USING (public.user_owns_claim(claim_id))
WITH CHECK (public.user_owns_claim(claim_id));

CREATE POLICY "users_manage_own_claim_timeline"
ON public.claim_timeline
FOR ALL
TO authenticated
USING (public.user_owns_claim(claim_id))
WITH CHECK (public.user_owns_claim(claim_id));

-- Function to generate claim numbers
CREATE OR REPLACE FUNCTION public.generate_claim_number()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    year_str TEXT := EXTRACT(YEAR FROM CURRENT_DATE)::TEXT;
    sequence_num INTEGER;
    claim_number TEXT;
BEGIN
    -- Get next sequence number for this year
    SELECT COALESCE(MAX(
        CASE 
            WHEN claim_number LIKE 'CLM-' || year_str || '-%' 
            THEN (split_part(claim_number, '-', 3))::INTEGER
            ELSE 0
        END
    ), 0) + 1
    INTO sequence_num
    FROM public.insurance_claims;
    
    -- Format: CLM-YYYY-NNN
    claim_number := 'CLM-' || year_str || '-' || LPAD(sequence_num::TEXT, 3, '0');
    
    RETURN claim_number;
END;
$$;

-- Function to create claim timeline steps
CREATE OR REPLACE FUNCTION public.create_claim_timeline(claim_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.claim_timeline (claim_id, step_name, step_description, expected_completion, is_completed)
    VALUES 
        (claim_uuid, 'Claim Submitted', 'Claim has been submitted and received', CURRENT_TIMESTAMP, true),
        (claim_uuid, 'Documents Reviewed', 'All submitted documents are being reviewed', CURRENT_TIMESTAMP + INTERVAL '2 days', false),
        (claim_uuid, 'Damage Assessment', 'Professional damage assessment in progress', CURRENT_TIMESTAMP + INTERVAL '5 days', false),
        (claim_uuid, 'Insurance Approval', 'Waiting for insurance company approval', CURRENT_TIMESTAMP + INTERVAL '10 days', false),
        (claim_uuid, 'Payment Processing', 'Approved claim payment is being processed', CURRENT_TIMESTAMP + INTERVAL '15 days', false);
END;
$$;

-- Trigger to auto-generate claim number and timeline
CREATE OR REPLACE FUNCTION public.handle_new_insurance_claim()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Generate claim number if not provided
    IF NEW.claim_number IS NULL OR NEW.claim_number = '' THEN
        NEW.claim_number := public.generate_claim_number();
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_insurance_claim_created
    BEFORE INSERT ON public.insurance_claims
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_insurance_claim();

-- Trigger to create timeline after claim is inserted
CREATE OR REPLACE FUNCTION public.handle_claim_timeline_creation()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM public.create_claim_timeline(NEW.id);
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_claim_timeline_creation
    AFTER INSERT ON public.insurance_claims
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_claim_timeline_creation();

-- Insert sample insurance companies
INSERT INTO public.insurance_companies (name, logo_url, claim_phone, online_portal, supported_languages) VALUES
    ('Allianz Sigorta', 'https://images.unsplash.com/photo-1560472354-b7c632a7af0b?w=100', '+90 850 222 78 78', 'https://allianz.com.tr', ARRAY['tr', 'en']),
    ('Axa Sigorta', 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=100', '+90 444 1 999', 'https://axa.com.tr', ARRAY['tr', 'en', 'fr']),
    ('Mapfre Sigorta', 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=100', '+90 444 62 73', 'https://mapfre.com.tr', ARRAY['tr', 'en', 'es']),
    ('Aksigorta', 'https://images.unsplash.com/photo-1554224154-22dec7ec8818?w=100', '+90 444 4 995', 'https://aksigorta.com.tr', ARRAY['tr', 'en']),
    ('HDI Sigorta', 'https://images.unsplash.com/photo-1554224154-26032fced1bd?w=100', '+90 444 4 434', 'https://hdi.com.tr', ARRAY['tr', 'en', 'de']);

-- Create mock data for demonstration
DO $$
DECLARE
    existing_user_id UUID;
    existing_service_request_id UUID;
    allianz_company_id UUID;
    sample_claim_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user and service request IDs (don't create new ones)
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    SELECT id INTO existing_service_request_id FROM public.service_requests LIMIT 1;
    SELECT id INTO allianz_company_id FROM public.insurance_companies WHERE name = 'Allianz Sigorta' LIMIT 1;
    
    -- Only create mock data if we have existing users
    IF existing_user_id IS NOT NULL THEN
        -- Insert sample notifications
        INSERT INTO public.notifications (user_id, title, body, category, priority, has_media, action_required, metadata)
        VALUES
            (existing_user_id, 'New Service Request', 'A customer needs towing service in downtown area. Tap to view details.', 'service_updates', 'high', true, true, '{"location": {"lat": 41.0082, "lng": 28.978}}'),
            (existing_user_id, 'Payment Received', '₺450 payment received for service request #TR-2024-001', 'service_updates', 'medium', false, false, '{}'),
            (existing_user_id, 'System Maintenance', 'Scheduled maintenance will occur tonight from 2:00 AM to 4:00 AM.', 'system_alerts', 'medium', false, false, '{}'),
            (existing_user_id, 'Emergency Alert', 'Weather warning: Heavy snow expected. Drive carefully.', 'emergency', 'emergency', false, true, '{}');

        -- Insert sample notification settings
        INSERT INTO public.notification_settings (user_id, push_notifications, email_notifications, preferred_language)
        VALUES (existing_user_id, true, true, 'tr');

        -- Insert sample insurance claim if we have both user and service request
        IF existing_service_request_id IS NOT NULL AND allianz_company_id IS NOT NULL THEN
            INSERT INTO public.insurance_claims (
                id, customer_id, service_request_id, insurance_company_id, 
                incident_type, incident_description, incident_date, incident_time,
                location_address, weather_condition, damage_severity, estimated_cost, status
            ) VALUES (
                sample_claim_id, existing_user_id, existing_service_request_id, allianz_company_id,
                'Vehicle Collision', 'Rear-end collision at traffic light during rush hour', 
                CURRENT_DATE - INTERVAL '3 days', '08:30:00',
                'Taksim Meydanı, Beyoğlu/İstanbul', 'clear', 'moderate', 12500.00, 'under_review'
            );

            -- Insert sample damage areas
            INSERT INTO public.claim_damage_areas (claim_id, area_name, damage_description, estimated_repair_cost)
            VALUES
                (sample_claim_id, 'Rear Bumper', 'Significant denting and scratches', 3500.00),
                (sample_claim_id, 'Trunk', 'Minor dents and paint damage', 2000.00),
                (sample_claim_id, 'Taillights', 'Left taillight cracked', 1200.00);
        END IF;
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;