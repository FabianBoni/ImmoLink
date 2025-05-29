import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/property/domain/models/property.dart';
import 'package:immolink/features/property/presentation/providers/property_providers.dart';
import 'package:uuid/uuid.dart';

class AddPropertyPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends ConsumerState<AddPropertyPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _rentController = TextEditingController();
  final _sizeController = TextEditingController();
  final _roomsController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  List<String> selectedAmenities = [];
  List<String> selectedImages = [];
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<String> amenitiesList = [
    'Parking', 'Elevator', 'Balcony', 'Garden', 'Furnished', 
    'Pet Friendly', 'Storage', 'Laundry', 'Swimming Pool', 
    'Gym', 'Air Conditioning', 'Heating', 'Dishwasher', 
    'Internet', 'Security System'
  ];

  // Modern design system colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF2F2F2);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color accent = Color(0xFF007AFF);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF212121);
  static const Color textCaption = Color(0xFF8E8E93);
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    _sizeController.dispose();
    _roomsController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add Property',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: 1 - (_slideAnimation.value / 30),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20.0),
                        children: [
                          _buildHeaderSection(),
                          const SizedBox(height: 32),
                          _buildLocationCard(),
                          const SizedBox(height: 24),
                          _buildDetailsCard(),
                          const SizedBox(height: 24),
                          _buildAmenitiesCard(),
                          const SizedBox(height: 24),
                          _buildImagesCard(),
                          const SizedBox(height: 40),
                          _buildSubmitButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Creating property...',
            style: TextStyle(
              color: textCaption,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New Property',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add property details to get started',
          style: TextStyle(
            fontSize: 16,
            color: textCaption,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return _buildCard(
      title: 'Location',
      children: [
        _buildTextField(
          controller: _addressController,
          label: 'Street Address',
          validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                validator: (value) => value?.isEmpty ?? true ? 'City is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _postalCodeController,
                label: 'Postal Code',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return _buildCard(
      title: 'Property Details',
      children: [
        _buildTextField(
          controller: _rentController,
          label: 'Monthly Rent (CHF)',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Rent amount is required';
            if (double.tryParse(value!) == null) return 'Invalid amount';
            return null;
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _sizeController,
                label: 'Size (m²)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _roomsController,
                label: 'Rooms',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesCard() {
    return _buildCard(
      title: 'Amenities',
      children: [
        Text(
          'Select available amenities',
          style: TextStyle(
            fontSize: 14,
            color: textCaption,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenitiesList.map((amenity) {
            final isSelected = selectedAmenities.contains(amenity);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    selectedAmenities.remove(amenity);
                  } else {
                    selectedAmenities.add(amenity);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? accent : surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: divider, width: 1),
                ),
                child: Text(
                  amenity,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagesCard() {
    return _buildCard(
      title: 'Images',
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 120,
            decoration: BoxDecoration(
              color: selectedImages.isEmpty ? surface : accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedImages.isEmpty ? divider : accent.withOpacity(0.3), 
                width: 1.5,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedImages.isEmpty ? Icons.cloud_upload_outlined : Icons.check_circle_outline,
                    size: 28,
                    color: selectedImages.isEmpty ? textCaption : accent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedImages.isEmpty 
                        ? 'Tap to upload images' 
                        : '${selectedImages.length} image(s) selected',
                    style: TextStyle(
                      color: selectedImages.isEmpty ? textCaption : accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textCaption,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(
              color: textCaption,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
        ),
        child: const Text(
          'Create Property',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      HapticFeedback.lightImpact();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          selectedImages = result.files.map((file) => file.path ?? '').toList();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} image(s) selected'),
            backgroundColor: success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error selecting images'),
          backgroundColor: error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = ref.read(currentUserProvider);
        final landlordId = currentUser?.id.toString() ?? '';

        final property = Property(
          id: const Uuid().v4(),
          landlordId: landlordId,
          tenantIds: [],
          address: Address(
            street: _addressController.text,
            city: _cityController.text,
            postalCode: _postalCodeController.text,
            country: 'Switzerland',
          ),
          rentAmount: double.parse(_rentController.text),
          details: PropertyDetails(
            size: double.tryParse(_sizeController.text) ?? 0,
            rooms: int.tryParse(_roomsController.text) ?? 0,
            amenities: selectedAmenities,
          ),
          status: 'available',
        );

        await ref.read(propertyServiceProvider).addProperty(property);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Property created successfully!'),
            backgroundColor: success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        context.pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}