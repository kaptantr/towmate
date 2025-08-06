-- Location: supabase/migrations/20250805210000_towmate_admin_payment_improvements.sql
-- Schema Analysis: TowMate existing schema with payments, user_profiles, driver_profiles tables
-- Integration Type: Enhancement - Adding admin management and payment processing features
-- Dependencies: user_profiles, driver_profiles, payments, service_requests

-- Create payment_methods table for user payment method management
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('credit_card', 'debit_card', 'digital_wallet', 'bank_account')),
    provider TEXT NOT NULL, -- stripe, paypal, etc.
    last_four TEXT,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    card_brand TEXT, -- visa, mastercard, amex, etc.
    expiry_month INTEGER,
    expiry_year INTEGER,
    billing_address_line1 TEXT,
    billing_address_line2 TEXT,
    billing_city TEXT,
    billing_state TEXT,
    billing_postal_code TEXT,
    billing_country TEXT DEFAULT 'TR',
    provider_payment_method_id TEXT, -- Stripe payment method ID
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create payment_transactions table for detailed payment tracking
CREATE TABLE public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID REFERENCES public.payments(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('charge', 'refund', 'partial_refund', 'dispute')),
    amount NUMERIC(10,2) NOT NULL,
    currency TEXT DEFAULT 'TRY',
    provider_transaction_id TEXT,
    provider_intent_id TEXT,
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'succeeded', 'failed', 'canceled', 'requires_action')),
    failure_reason TEXT,
    provider_response JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ
);

-- Create driver_documents table for driver registration verification
CREATE TABLE public.driver_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID REFERENCES public.driver_profiles(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL CHECK (document_type IN ('drivers_license', 'vehicle_registration', 'insurance_certificate', 'tow_license', 'business_permit', 'vehicle_inspection', 'criminal_background')),
    document_number TEXT,
    file_path TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected', 'expired')),
    verified_by UUID REFERENCES public.user_profiles(id),
    verified_at TIMESTAMPTZ,
    expiry_date DATE,
    rejection_reason TEXT,
    uploaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create admin_activities table for admin action tracking
CREATE TABLE public.admin_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL CHECK (activity_type IN ('user_management', 'driver_verification', 'payment_management', 'system_config', 'content_moderation', 'data_export')),
    action TEXT NOT NULL,
    target_type TEXT, -- user, driver, payment, etc.
    target_id UUID,
    details JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create system_settings table for admin configuration
CREATE TABLE public.system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key TEXT NOT NULL UNIQUE,
    setting_value JSONB NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('payment', 'pricing', 'notification', 'system', 'feature_flags')),
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_by UUID REFERENCES public.user_profiles(id),
    updated_by UUID REFERENCES public.user_profiles(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create driver_verification_checklist for comprehensive verification tracking
CREATE TABLE public.driver_verification_checklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID REFERENCES public.driver_profiles(id) ON DELETE CASCADE,
    drivers_license_verified BOOLEAN DEFAULT false,
    vehicle_registration_verified BOOLEAN DEFAULT false,
    insurance_verified BOOLEAN DEFAULT false,
    background_check_completed BOOLEAN DEFAULT false,
    vehicle_inspection_passed BOOLEAN DEFAULT false,
    tow_license_verified BOOLEAN DEFAULT false,
    overall_status TEXT DEFAULT 'incomplete' CHECK (overall_status IN ('incomplete', 'pending', 'approved', 'rejected')),
    approved_by UUID REFERENCES public.user_profiles(id),
    approved_at TIMESTAMPTZ,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create essential indexes
CREATE INDEX idx_payment_methods_user_id ON public.payment_methods(user_id);
CREATE INDEX idx_payment_methods_is_default ON public.payment_methods(is_default);
CREATE INDEX idx_payment_transactions_payment_id ON public.payment_transactions(payment_id);
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(status);
CREATE INDEX idx_driver_documents_driver_id ON public.driver_documents(driver_id);
CREATE INDEX idx_driver_documents_verification_status ON public.driver_documents(verification_status);
CREATE INDEX idx_admin_activities_admin_id ON public.admin_activities(admin_id);
CREATE INDEX idx_admin_activities_activity_type ON public.admin_activities(activity_type);
CREATE INDEX idx_system_settings_category ON public.system_settings(category);
CREATE INDEX idx_driver_verification_checklist_driver_id ON public.driver_verification_checklist(driver_id);
CREATE INDEX idx_driver_verification_checklist_overall_status ON public.driver_verification_checklist(overall_status);

-- Enable RLS for all new tables
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_verification_checklist ENABLE ROW LEVEL SECURITY;

-- Create admin check function using auth metadata
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
         OR au.raw_app_meta_data->>'role' = 'admin')
) OR EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
)
$$;

-- RLS Policies using Pattern 1 and Pattern 2 (Simple User Ownership)

-- Payment methods - users manage their own
CREATE POLICY "users_manage_own_payment_methods"
ON public.payment_methods
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Payment transactions - users view their own, admins manage all
CREATE POLICY "users_view_own_payment_transactions"
ON public.payment_transactions
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.payments p
        WHERE p.id = payment_id AND p.customer_id = auth.uid()
    )
);

CREATE POLICY "admins_manage_all_payment_transactions"
ON public.payment_transactions
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Driver documents - drivers manage their own, admins manage all
CREATE POLICY "drivers_manage_own_documents"
ON public.driver_documents
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.id = driver_id AND dp.user_id = auth.uid()
    )
);

CREATE POLICY "admins_manage_all_driver_documents"
ON public.driver_documents
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Admin activities - admins only
CREATE POLICY "admins_manage_admin_activities"
ON public.admin_activities
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- System settings - admins manage all, users view public settings
CREATE POLICY "public_view_public_settings"
ON public.system_settings
FOR SELECT
TO authenticated
USING (is_public = true);

CREATE POLICY "admins_manage_all_settings"
ON public.system_settings
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Driver verification checklist - drivers view their own, admins manage all
CREATE POLICY "drivers_view_own_verification"
ON public.driver_verification_checklist
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.id = driver_id AND dp.user_id = auth.uid()
    )
);

CREATE POLICY "admins_manage_all_verifications"
ON public.driver_verification_checklist
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Create storage bucket for driver documents
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'driver-documents',
    'driver-documents',
    false,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/jpg', 'application/pdf', 'image/webp']
);

-- Storage RLS policies for driver documents
CREATE POLICY "drivers_upload_own_documents"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'driver-documents'
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "drivers_view_own_documents"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'driver-documents'
    AND owner = auth.uid()
);

CREATE POLICY "admins_manage_driver_documents"
ON storage.objects
FOR ALL
TO authenticated
USING (
    bucket_id = 'driver-documents'
    AND public.is_admin_from_auth()
);

-- Create function to automatically create verification checklist for new drivers
CREATE OR REPLACE FUNCTION public.create_driver_verification_checklist()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.driver_verification_checklist (driver_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$;

-- Trigger to create verification checklist when driver profile is created
CREATE TRIGGER on_driver_profile_created
    AFTER INSERT ON public.driver_profiles
    FOR EACH ROW EXECUTE FUNCTION public.create_driver_verification_checklist();

-- Insert default system settings
INSERT INTO public.system_settings (setting_key, setting_value, category, description, is_public, created_by) VALUES
    ('base_service_fee', '{"amount": 25.00, "currency": "TRY"}'::jsonb, 'pricing', 'Base fee for tow services', true, (SELECT id FROM public.user_profiles WHERE role = 'admin' LIMIT 1)),
    ('distance_rate_per_km', '{"amount": 3.50, "currency": "TRY"}'::jsonb, 'pricing', 'Rate per kilometer for towing', true, (SELECT id FROM public.user_profiles WHERE role = 'admin' LIMIT 1)),
    ('emergency_service_multiplier', '{"multiplier": 1.5}'::jsonb, 'pricing', 'Emergency service price multiplier', true, (SELECT id FROM public.user_profiles WHERE role = 'admin' LIMIT 1)),
    ('payment_methods_enabled', '["credit_card", "debit_card", "digital_wallet"]'::jsonb, 'payment', 'Enabled payment methods', true, (SELECT id FROM public.user_profiles WHERE role = 'admin' LIMIT 1)),
    ('max_service_radius_km', '{"radius": 50}'::jsonb, 'system', 'Maximum service radius in kilometers', false, (SELECT id FROM public.user_profiles WHERE role = 'admin' LIMIT 1));

-- Mock data for demonstration
DO $$
DECLARE
    existing_user_id UUID;
    existing_driver_id UUID;
    sample_payment_method_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user and driver IDs
    SELECT id INTO existing_user_id FROM public.user_profiles WHERE role = 'customer' LIMIT 1;
    SELECT id INTO existing_driver_id FROM public.driver_profiles LIMIT 1;

    -- Create sample payment method
    IF existing_user_id IS NOT NULL THEN
        INSERT INTO public.payment_methods (id, user_id, type, provider, last_four, is_default, card_brand, expiry_month, expiry_year, billing_city, billing_country) VALUES
            (sample_payment_method_id, existing_user_id, 'credit_card', 'stripe', '4242', true, 'visa', 12, 2025, 'Istanbul', 'TR');
    END IF;

    -- Create sample driver documents
    IF existing_driver_id IS NOT NULL THEN
        INSERT INTO public.driver_documents (driver_id, document_type, document_number, file_path, file_name, file_size, mime_type, verification_status) VALUES
            (existing_driver_id, 'drivers_license', 'TR123456789', '/documents/license.pdf', 'drivers_license.pdf', 1024000, 'application/pdf', 'verified'),
            (existing_driver_id, 'vehicle_registration', 'REG987654321', '/documents/registration.pdf', 'vehicle_registration.pdf', 512000, 'application/pdf', 'pending');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data creation failed: %', SQLERRM;
END $$;