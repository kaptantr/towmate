# CallTowing - Professional Towing & Roadside Assistance Platform

A comprehensive Flutter application for towing and roadside assistance services, powered by Supabase backend.

## Features

### For Customers
- **Multi-Service Selection**: Choose from towing, jumpstart, tire change, lockout service, fuel delivery, and winch services
- **Real-time Location**: GPS-based pickup and destination selection
- **Service Tracking**: Track driver location and service progress in real-time
- **Payment Integration**: Secure payment processing with multiple payment methods
- **Service History**: View past service requests and receipts
- **Emergency Support**: Priority emergency service requests

### For Drivers
- **Driver Dashboard**: Comprehensive dashboard showing earnings, jobs, and statistics
- **Request Management**: Accept/reject service requests with detailed customer information
- **Location Tracking**: Real-time location updates for optimal dispatch
- **Earnings Tracking**: Detailed earnings breakdown with tips and bonuses
- **Status Management**: Toggle between online/offline/busy status
- **Navigation Integration**: Built-in navigation to customer locations

### For Administrators
- **Admin Control Panel**: Comprehensive system management and analytics
- **Service Configuration**: Manage service types, pricing, and availability
- **Driver Management**: Approve driver registrations and manage driver status
- **Analytics Dashboard**: Real-time system statistics and performance metrics
- **Payment Oversight**: Monitor all transactions and financial reports
- **User Management**: Handle customer support and user verification

## Technical Stack

- **Frontend**: Flutter 3.16.0+ with Material Design
- **Backend**: Supabase (PostgreSQL + Real-time subscriptions)
- **Authentication**: Supabase Auth with Row Level Security
- **Maps**: Google Maps integration with Places API
- **Payment**: Stripe integration for secure transactions
- **Location**: Real-time GPS tracking and geocoding
- **State Management**: Provider pattern with proper separation of concerns

## Architecture

### Database Schema
- **Users & Profiles**: Secure user management with role-based access
- **Service Requests**: Complete request lifecycle management
- **Driver Profiles**: Driver information, vehicle details, and availability
- **Payments & Earnings**: Financial transaction tracking
- **Admin Configuration**: Centralized service and pricing management

### Security Features
- Row Level Security (RLS) policies for data protection
- JWT-based authentication
- Secure API key management
- Input validation and sanitization
- Real-time data synchronization

## Setup Instructions

### Prerequisites
1. Flutter 3.16.0 or higher
2. Dart 3.2.0 or higher
3. Supabase account
4. Google Maps API key
5. Stripe account (for payments)

### Environment Configuration
1. Update `env.json` with your API keys:
   ```json
   {
     "SUPABASE_URL": "your-supabase-project-url",
     "SUPABASE_ANON_KEY": "your-supabase-anon-key",
     "GOOGLE_PLACES_API_KEY": "your-google-places-api-key",
     "GOOGLE_MAPS_API_KEY": "your-google-maps-api-key",
     "STRIPE_PUBLISHABLE_KEY": "your-stripe-publishable-key"
   }
   ```

### Database Setup
1. Run the migration files in order:
   ```bash
   # Run these in your Supabase SQL editor
   supabase/migrations/20250105190000_towmate_complete_schema.sql
   supabase/migrations/20250806010000_calltowing_missing_tables.sql
   ```

2. Enable Row Level Security for all tables
3. Set up Supabase storage buckets if using file uploads

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure platform-specific settings:
   
   **Android**: Update `android/app/src/main/AndroidManifest.xml` with location permissions
   
   **iOS**: Update `ios/Runner/Info.plist` with location usage descriptions

4. Run the application:
   ```bash
   flutter run --dart-define-from-file=env.json
   ```

## Key Services

### LocationService
- Global location support with fallback geocoding
- Google Places API integration for address autocomplete  
- Real-time driver location tracking
- Address caching for performance

### ServiceRequestService  
- Multi-service request creation
- Real-time request status updates
- Driver-customer communication
- Service configuration management

### AdminService
- System statistics and analytics
- User and driver management
- Data export functionality
- Activity logging

### DriverService
- Driver profile management
- Earnings and statistics tracking
- Request acceptance workflow
- Location and status updates

## Current Status

The application includes all core features with the following screens fully implemented:
- ✅ Splash Screen & Authentication
- ✅ Multi-Service Selection Hub  
- ✅ Customer Service Request Flow
- ✅ Driver Dashboard & Management
- ✅ Real-time Driver Matching & Tracking
- ✅ Payment Management System
- ✅ Admin Control Panel
- ✅ Profile Settings & Management
- ✅ Advanced Notification Center
- ✅ Insurance Claim Support
- ✅ Location Management System

## Recent Fixes Applied

1. **Environment Configuration**: Fixed SUPABASE_ANON_KEY placeholder
2. **Database Schema**: Added missing tables for admin configurations and multi-service support
3. **Package Dependencies**: Updated all packages to compatible versions
4. **Service Integration**: Fixed service methods to work with actual database schema
5. **Location Services**: Enhanced with caching and proper API key handling
6. **Admin Features**: Implemented complete admin service with statistics and management
7. **Driver Workflow**: Fixed earnings calculation and job completion flow

## Next Steps

1. Test all functionality with real Supabase project
2. Configure payment processing with actual Stripe keys
3. Set up push notifications for real-time updates
4. Add comprehensive error handling and user feedback
5. Implement automated testing suite
6. Deploy to production environment

## Support

For technical support or questions about implementation, please refer to the service documentation within the codebase or contact the development team.