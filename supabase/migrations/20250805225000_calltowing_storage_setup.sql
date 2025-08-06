-- Location: supabase/migrations/20250805225000_calltowing_storage_setup.sql
-- Storage setup for CallTowing insurance claim documents and driver verification files

-- Create storage buckets for CallTowing
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    (
        'claim-documents',
        'claim-documents', 
        false,
        10485760, -- 10MB limit
        ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'image/jpeg', 'image/png', 'image/jpg']
    ),
    (
        'driver-documents',
        'driver-documents',
        false, 
        5242880, -- 5MB limit
        ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/jpg']
    ),
    (
        'incident-photos',
        'incident-photos',
        false,
        5242880, -- 5MB limit  
        ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp']
    );

-- RLS Policies for claim-documents bucket
CREATE POLICY "users_view_own_claim_documents"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'claim-documents' 
    AND owner = auth.uid()
);

CREATE POLICY "users_upload_own_claim_documents"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'claim-documents'
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "users_update_own_claim_documents"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'claim-documents' AND owner = auth.uid())
WITH CHECK (bucket_id = 'claim-documents' AND owner = auth.uid());

CREATE POLICY "users_delete_own_claim_documents"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'claim-documents' AND owner = auth.uid());

-- RLS Policies for driver-documents bucket
CREATE POLICY "drivers_view_own_driver_documents"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'driver-documents'
    AND owner = auth.uid()
);

CREATE POLICY "drivers_upload_own_driver_documents"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'driver-documents'
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "drivers_update_own_driver_documents"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'driver-documents' AND owner = auth.uid())
WITH CHECK (bucket_id = 'driver-documents' AND owner = auth.uid());

CREATE POLICY "drivers_delete_own_driver_documents"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'driver-documents' AND owner = auth.uid());

-- RLS Policies for incident-photos bucket
CREATE POLICY "users_view_own_incident_photos"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'incident-photos'
    AND owner = auth.uid()
);

CREATE POLICY "users_upload_own_incident_photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'incident-photos'
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "users_update_own_incident_photos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'incident-photos' AND owner = auth.uid())
WITH CHECK (bucket_id = 'incident-photos' AND owner = auth.uid());

CREATE POLICY "users_delete_own_incident_photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'incident-photos' AND owner = auth.uid());

-- Admin policies for all buckets (admins can manage all files)
CREATE POLICY "admins_manage_all_claim_documents"
ON storage.objects
FOR ALL
TO authenticated
USING (
    bucket_id = 'claim-documents'
    AND EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
)
WITH CHECK (
    bucket_id = 'claim-documents'
    AND EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
);

CREATE POLICY "admins_manage_all_driver_documents"
ON storage.objects
FOR ALL
TO authenticated
USING (
    bucket_id = 'driver-documents'
    AND EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
)
WITH CHECK (
    bucket_id = 'driver-documents'
    AND EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
);

CREATE POLICY "admins_manage_all_incident_photos"
ON storage.objects
FOR ALL
TO authenticated
USING (
    bucket_id = 'incident-photos'
    AND EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
)
WITH CHECK (
    bucket_id = 'incident-photos'
    AND EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
);