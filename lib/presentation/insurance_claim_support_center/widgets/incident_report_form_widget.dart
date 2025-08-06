import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class IncidentReportFormWidget extends StatefulWidget {
  final bool isListening;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final Function(Map<String, dynamic>) onDataChanged;

  const IncidentReportFormWidget({
    Key? key,
    required this.isListening,
    required this.onStartListening,
    required this.onStopListening,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<IncidentReportFormWidget> createState() =>
      _IncidentReportFormWidgetState();
}

class _IncidentReportFormWidgetState extends State<IncidentReportFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _incidentDescriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _policeReportController = TextEditingController();
  final _witnessNameController = TextEditingController();
  final _witnessPhoneController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedIncidentType = 'collision';
  String _selectedWeatherCondition = 'clear';

  final List<Map<String, String>> _incidentTypes = [
    {'value': 'collision', 'label': 'Vehicle Collision'},
    {'value': 'weather', 'label': 'Weather Damage'},
    {'value': 'theft', 'label': 'Theft/Vandalism'},
    {'value': 'fire', 'label': 'Fire Damage'},
    {'value': 'flood', 'label': 'Flood Damage'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _weatherConditions = [
    {'value': 'clear', 'label': 'Clear'},
    {'value': 'rainy', 'label': 'Rainy'},
    {'value': 'snowy', 'label': 'Snowy'},
    {'value': 'foggy', 'label': 'Foggy'},
    {'value': 'stormy', 'label': 'Stormy'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _updateFormData();
  }

  void _updateFormData() {
    widget.onDataChanged({
      'incidentType': _selectedIncidentType,
      'incidentDescription': _incidentDescriptionController.text,
      'location': _locationController.text,
      'incidentDate': _selectedDate,
      'incidentTime': _selectedTime,
      'weatherCondition': _selectedWeatherCondition,
      'policeReportNumber': _policeReportController.text,
      'witnessName': _witnessNameController.text,
      'witnessPhone': _witnessPhoneController.text,
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 30)),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _updateFormData();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
        context: context, initialTime: _selectedTime ?? TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _updateFormData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Incident Details',
                  style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900])),
              SizedBox(height: 8.h),
              Text(
                  'Provide detailed information about the incident with voice-to-text support',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp, color: Colors.grey[600], height: 1.4)),
              SizedBox(height: 24.h),

              // Incident Type
              Text('Incident Type *',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700])),
              SizedBox(height: 8.h),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!)),
                  child: DropdownButtonFormField<String>(
                      value: _selectedIncidentType,
                      decoration: InputDecoration(border: InputBorder.none),
                      items: _incidentTypes.map((type) {
                        return DropdownMenuItem<String>(
                            value: type['value'],
                            child: Text(type['label']!,
                                style: GoogleFonts.inter(fontSize: 14.sp)));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedIncidentType = value!;
                        });
                        _updateFormData();
                      })),
              SizedBox(height: 16.h),

              // Date and Time
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Date *',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700])),
                      SizedBox(height: 8.h),
                      InkWell(
                          onTap: _selectDate,
                          child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!)),
                              child: Row(children: [
                                Icon(Icons.calendar_today,
                                    size: 20.sp, color: Colors.grey[600]),
                                SizedBox(width: 8.w),
                                Text(
                                    _selectedDate != null
                                        ? DateFormat('MMM dd, yyyy')
                                            .format(_selectedDate!)
                                        : 'Select date',
                                    style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        color: Colors.grey[900])),
                              ]))),
                    ])),
                SizedBox(width: 12.w),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Time *',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700])),
                      SizedBox(height: 8.h),
                      InkWell(
                          onTap: _selectTime,
                          child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!)),
                              child: Row(children: [
                                Icon(Icons.access_time,
                                    size: 20.sp, color: Colors.grey[600]),
                                SizedBox(width: 8.w),
                                Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : 'Select time',
                                    style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        color: Colors.grey[900])),
                              ]))),
                    ])),
              ]),
              SizedBox(height: 16.h),

              // Location
              Text('Location *',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700])),
              SizedBox(height: 8.h),
              TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                      hintText: 'Enter incident location',
                      prefixIcon:
                          Icon(Icons.location_on, color: Colors.grey[600]),
                      suffixIcon: IconButton(
                          icon:
                              Icon(Icons.my_location, color: Colors.blue[700]),
                          onPressed: () {
                            // Get current location
                            _locationController.text = 'Current Location (GPS)';
                            _updateFormData();
                          }),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green[700]!))),
                  onChanged: (value) => _updateFormData(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the incident location';
                    }
                    return null;
                  }),
              SizedBox(height: 16.h),

              // Weather Condition
              Text('Weather Condition',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700])),
              SizedBox(height: 8.h),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!)),
                  child: DropdownButtonFormField<String>(
                      value: _selectedWeatherCondition,
                      decoration: InputDecoration(border: InputBorder.none),
                      items: _weatherConditions.map((weather) {
                        return DropdownMenuItem<String>(
                            value: weather['value'],
                            child: Text(weather['label']!,
                                style: GoogleFonts.inter(fontSize: 14.sp)));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWeatherCondition = value!;
                        });
                        _updateFormData();
                      })),
              SizedBox(height: 16.h),

              // Incident Description
              Text('Incident Description *',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700])),
              SizedBox(height: 8.h),
              TextFormField(
                  controller: _incidentDescriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                      hintText: 'Describe what happened in detail...',
                      suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),
                            IconButton(
                                icon: Icon(
                                    widget.isListening
                                        ? Icons.mic
                                        : Icons.mic_none,
                                    color: widget.isListening
                                        ? Colors.red[700]
                                        : Colors.grey[600]),
                                onPressed: widget.isListening
                                    ? widget.onStopListening
                                    : widget.onStartListening),
                          ]),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green[700]!))),
                  onChanged: (value) => _updateFormData(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a description of the incident';
                    }
                    return null;
                  }),
              if (widget.isListening)
                Container(
                    margin: EdgeInsets.only(top: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[200]!)),
                    child: Row(children: [
                      Icon(Icons.mic, color: Colors.red[700], size: 16.sp),
                      SizedBox(width: 8.w),
                      Text('Listening... Speak now',
                          style: GoogleFonts.inter(
                              fontSize: 12.sp, color: Colors.red[700])),
                    ])),
              SizedBox(height: 16.h),

              // Police Report Number
              Text('Police Report Number',
                  style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700])),
              SizedBox(height: 8.h),
              TextFormField(
                  controller: _policeReportController,
                  decoration: InputDecoration(
                      hintText: 'Enter police report number (if available)',
                      prefixIcon:
                          Icon(Icons.local_police, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green[700]!))),
                  onChanged: (value) => _updateFormData()),
              SizedBox(height: 16.h),

              // Witness Information
              Text('Witness Information',
                  style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900])),
              SizedBox(height: 12.h),
              TextFormField(
                  controller: _witnessNameController,
                  decoration: InputDecoration(
                      labelText: 'Witness Name',
                      prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green[700]!))),
                  onChanged: (value) => _updateFormData()),
              SizedBox(height: 12.h),
              TextFormField(
                  controller: _witnessPhoneController,
                  decoration: InputDecoration(
                      labelText: 'Witness Phone',
                      prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green[700]!))),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _updateFormData()),
            ])));
  }

  @override
  void dispose() {
    _incidentDescriptionController.dispose();
    _locationController.dispose();
    _policeReportController.dispose();
    _witnessNameController.dispose();
    _witnessPhoneController.dispose();
    super.dispose();
  }
}
