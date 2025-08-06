import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class DriverRegistrationService {
  static DriverRegistrationService? _instance;
  static DriverRegistrationService get instance =>
      _instance ??= DriverRegistrationService._();

  DriverRegistrationService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  // Register new driver
  Future<Map<String, dynamic>> registerDriver({
    required Map<String, dynamic> driverData,
    required Map<String, dynamic> vehicleData,
  }) async {
    try {
      final userId = _client.auth.currentUser!.id;

      // Create driver profile
      final driverProfileData = {
        'user_id': userId,
        'license_number': driverData['license_number'],
        'license_expiry_date': driverData['license_expiry_date'],
        'insurance_number': vehicleData['insurance_number'],
        'insurance_expiry_date': vehicleData['insurance_expiry_date'],
        'vehicle_make': vehicleData['vehicle_make'],
        'vehicle_model': vehicleData['vehicle_model'],
        'vehicle_year': vehicleData['vehicle_year'],
        'vehicle_type': vehicleData['vehicle_type'],
        'license_plate': vehicleData['license_plate'],
        'is_available': false, // Will be set to true after verification
      };

      final driverProfile = await _client
          .from('driver_profiles')
          .insert(driverProfileData)
          .select()
          .single();

      // Update user role to driver
      await _client
          .from('user_profiles')
          .update({'role': 'driver'}).eq('id', userId);

      return driverProfile;
    } catch (error) {
      print('Register driver error: $error');
      throw Exception('Driver registration failed');
    }
  }

  // Upload driver document
  Future<Map<String, dynamic>> uploadDriverDocument({
    required String driverId,
    required String documentType,
    required String filePath,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      final userId = _client.auth.currentUser!.id;
      final file = File(filePath);
      final fileName = file.path.split('/').last;
      final fileSize = await file.length();

      // Generate unique storage path
      final storagePath =
          '$userId/$documentType/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Upload file to Supabase Storage
      await _client.storage.from('driver-documents').upload(storagePath, file);

      // Get file info
      final mimeType = _getMimeType(fileName);

      // Save document record
      final documentData = {
        'driver_id': driverId,
        'document_type': documentType,
        'document_number': documentNumber,
        'file_path': storagePath,
        'file_name': fileName,
        'file_size': fileSize,
        'mime_type': mimeType,
        'expiry_date': expiryDate?.toIso8601String(),
        'verification_status': 'pending',
      };

      final documentRecord = await _client
          .from('driver_documents')
          .insert(documentData)
          .select()
          .single();

      return documentRecord;
    } catch (error) {
      print('Upload document error: $error');
      throw Exception('Document upload failed');
    }
  }

  // Pick and upload document
  Future<Map<String, dynamic>?> pickAndUploadDocument({
    required String driverId,
    required String documentType,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final pickedFile = result.files.first;

      // For web, use bytes; for mobile, use path
      if (kIsWeb && pickedFile.bytes != null) {
        return await _uploadDocumentFromBytes(
          driverId: driverId,
          documentType: documentType,
          fileName: pickedFile.name,
          fileBytes: pickedFile.bytes!,
          documentNumber: documentNumber,
          expiryDate: expiryDate,
        );
      } else if (pickedFile.path != null) {
        return await uploadDriverDocument(
          driverId: driverId,
          documentType: documentType,
          filePath: pickedFile.path!,
          documentNumber: documentNumber,
          expiryDate: expiryDate,
        );
      }

      throw Exception('Unable to process selected file');
    } catch (error) {
      print('Pick and upload document error: $error');
      throw Exception('Failed to upload document');
    }
  }

  // Upload document from bytes (for web)
  Future<Map<String, dynamic>> _uploadDocumentFromBytes({
    required String driverId,
    required String documentType,
    required String fileName,
    required Uint8List fileBytes,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      final userId = _client.auth.currentUser!.id;

      // Generate unique storage path
      final storagePath =
          '$userId/$documentType/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Upload file to Supabase Storage
      await _client.storage
          .from('driver-documents')
          .uploadBinary(storagePath, fileBytes);

      // Get file info
      final mimeType = _getMimeType(fileName);

      // Save document record
      final documentData = {
        'driver_id': driverId,
        'document_type': documentType,
        'document_number': documentNumber,
        'file_path': storagePath,
        'file_name': fileName,
        'file_size': fileBytes.length,
        'mime_type': mimeType,
        'expiry_date': expiryDate?.toIso8601String(),
        'verification_status': 'pending',
      };

      final documentRecord = await _client
          .from('driver_documents')
          .insert(documentData)
          .select()
          .single();

      return documentRecord;
    } catch (error) {
      print('Upload document from bytes error: $error');
      throw Exception('Document upload failed');
    }
  }

  // Get driver documents
  Future<List<Map<String, dynamic>>> getDriverDocuments(String driverId) async {
    try {
      final response = await _client
          .from('driver_documents')
          .select('*')
          .eq('driver_id', driverId)
          .order('uploaded_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Get driver documents error: $error');
      throw Exception('Failed to load driver documents');
    }
  }

  // Get driver verification status
  Future<Map<String, dynamic>?> getDriverVerificationStatus(
      String driverId) async {
    try {
      final response = await _client
          .from('driver_verification_checklist')
          .select('*')
          .eq('driver_id', driverId)
          .single();

      return response;
    } catch (error) {
      print('Get verification status error: $error');
      return null;
    }
  }

  // Update driver profile information
  Future<void> updateDriverProfile({
    required String driverId,
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? vehicleInfo,
  }) async {
    try {
      if (personalInfo != null) {
        await _client
            .from('driver_profiles')
            .update(personalInfo)
            .eq('id', driverId);
      }

      if (vehicleInfo != null) {
        await _client
            .from('driver_profiles')
            .update(vehicleInfo)
            .eq('id', driverId);
      }
    } catch (error) {
      print('Update driver profile error: $error');
      throw Exception('Failed to update driver profile');
    }
  }

  // Delete driver document
  Future<void> deleteDriverDocument(String documentId) async {
    try {
      // Get document info first
      final document = await _client
          .from('driver_documents')
          .select('file_path')
          .eq('id', documentId)
          .single();

      // Delete from storage
      await _client.storage
          .from('driver-documents')
          .remove([document['file_path']]);

      // Delete from database
      await _client.from('driver_documents').delete().eq('id', documentId);
    } catch (error) {
      print('Delete document error: $error');
      throw Exception('Failed to delete document');
    }
  }

  // Get document download URL
  Future<String> getDocumentDownloadUrl(String filePath) async {
    try {
      final url =
          _client.storage.from('driver-documents').getPublicUrl(filePath);

      return url;
    } catch (error) {
      print('Get download URL error: $error');
      throw Exception('Failed to get document URL');
    }
  }

  // Download document
  Future<Uint8List> downloadDocument(String filePath) async {
    try {
      final response =
          await _client.storage.from('driver-documents').download(filePath);

      return response;
    } catch (error) {
      print('Download document error: $error');
      throw Exception('Failed to download document');
    }
  }

  // Check if all required documents are uploaded
  Future<Map<String, bool>> checkRequiredDocuments(String driverId) async {
    try {
      final documents = await getDriverDocuments(driverId);

      final requiredTypes = [
        'drivers_license',
        'vehicle_registration',
        'insurance_certificate',
        'tow_license',
        'vehicle_inspection',
      ];

      final uploadedTypes =
          documents.map((doc) => doc['document_type'] as String).toSet();

      final status = <String, bool>{};
      for (final type in requiredTypes) {
        status[type] = uploadedTypes.contains(type);
      }

      return status;
    } catch (error) {
      print('Check required documents error: $error');
      throw Exception('Failed to check document requirements');
    }
  }

  // Submit driver for verification
  Future<void> submitForVerification(String driverId) async {
    try {
      // Check if all required documents are uploaded
      final docStatus = await checkRequiredDocuments(driverId);
      final allUploaded = docStatus.values.every((uploaded) => uploaded);

      if (!allUploaded) {
        throw Exception(
            'Please upload all required documents before submitting');
      }

      // Update verification status
      await _client.from('driver_verification_checklist').update({
        'overall_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('driver_id', driverId);
    } catch (error) {
      print('Submit for verification error: $error');
      throw Exception('Failed to submit for verification');
    }
  }

  // Get document verification requirements
  Map<String, Map<String, dynamic>> getDocumentRequirements() {
    return {
      'drivers_license': {
        'title': 'Driver\'s License',
        'description': 'Valid driver\'s license with commercial endorsement',
        'required': true,
        'hasExpiry': true,
      },
      'vehicle_registration': {
        'title': 'Vehicle Registration',
        'description': 'Current vehicle registration document',
        'required': true,
        'hasExpiry': true,
      },
      'insurance_certificate': {
        'title': 'Insurance Certificate',
        'description': 'Commercial vehicle insurance certificate',
        'required': true,
        'hasExpiry': true,
      },
      'tow_license': {
        'title': 'Tow Truck License',
        'description': 'Commercial tow truck operator license',
        'required': true,
        'hasExpiry': true,
      },
      'vehicle_inspection': {
        'title': 'Vehicle Inspection Report',
        'description': 'Recent vehicle safety inspection report',
        'required': true,
        'hasExpiry': true,
      },
      'business_permit': {
        'title': 'Business Permit',
        'description': 'Business operation permit (if applicable)',
        'required': false,
        'hasExpiry': true,
      },
      'criminal_background': {
        'title': 'Background Check',
        'description': 'Criminal background check report',
        'required': false,
        'hasExpiry': false,
      },
    };
  }

  // Helper method to determine MIME type
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  // Get driver profile by user ID
  Future<Map<String, dynamic>?> getDriverProfileByUserId(String userId) async {
    try {
      final response = await _client
          .from('driver_profiles')
          .select('*')
          .eq('user_id', userId)
          .single();

      return response;
    } catch (error) {
      print('Get driver profile error: $error');
      return null;
    }
  }

  // Check if user is already registered as driver
  Future<bool> isUserRegisteredAsDriver(String userId) async {
    try {
      final profile = await getDriverProfileByUserId(userId);
      return profile != null;
    } catch (error) {
      print('Check driver registration error: $error');
      return false;
    }
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }
}
