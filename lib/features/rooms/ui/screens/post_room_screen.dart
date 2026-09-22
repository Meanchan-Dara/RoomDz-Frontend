import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomdz_frontend/core/constants/app_colors.dart';
import 'package:roomdz_frontend/features/rooms/data/services/owner_room_service.dart';
import 'package:roomdz_frontend/core/widgets/app_alert.dart';
import 'package:roomdz_frontend/core/widgets/modern_button_loader.dart';

class PostRoomScreen extends StatefulWidget {
  const PostRoomScreen({super.key});

  @override
  State<PostRoomScreen> createState() => _PostRoomScreenState();
}

class _PostRoomScreenState extends State<PostRoomScreen> {
  final OwnerRoomService _roomService = OwnerRoomService();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _totalUnitsCtrl = TextEditingController(
    text: '1',
  );
  final TextEditingController _availableUnitsCtrl = TextEditingController(
    text: '1',
  );
  final TextEditingController _sizeCtrl = TextEditingController();
  final TextEditingController _floorCtrl = TextEditingController();
  final TextEditingController _depositCtrl = TextEditingController();
  final TextEditingController _depositPriceCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _customFacilityCtrl = TextEditingController();
  final TextEditingController _customRuleCtrl = TextEditingController();

  // Selections
  int? _selectedCategoryId;
  String _selectedType = 'Private Room';
  String _selectedPricePeriod = 'month';
  bool _isNegotiable = false;
  String _selectedStatus = 'AVAILABLE NOW';

  // Location
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  // Images
  XFile? _coverImage;
  final List<XFile> _galleryImages = [];

  // State
  bool _isSubmitting = false;
  bool _isLoadingCategories = true;
  List<Map<String, dynamic>> _apiCategories = [];

  // Facilities list
  final List<String> _availableFacilities = [
    'Wi-Fi ឥតគិតថ្លៃ',
    'ម៉ាស៊ីនត្រជាក់',
    'កង្ហារ',
    'ម៉ាស៊ីនទឹកក្តៅ',
    'ចំណតយានយន្ត',
    'យ៉របន្ទប់',
    'ផ្ទះបាយ',
    'ម៉ាស៊ីនបោកខោអាវ',
    'ទូខោអាវ',
    'សន្តិសុខ ២៤ម៉ោង',
    'កាមេរ៉ាសុវត្ថិភាព',
    'ជណ្តើរយន្ត',
  ];
  final Set<String> _selectedFacilities = {'Wi-Fi ឥតគិតថ្លៃ', 'ម៉ាស៊ីនត្រជាក់'};

  // House Rules list
  final List<String> _availableRules = [
    'ហាមជក់បារីក្នុងបន្ទប់',
    'ហាមចិញ្ចឹមសត្វ',
    'រក្សាភាពស្ងប់ស្ងាត់ក្រោយម៉ោង ១០យប់',
    'មិនអនុញ្ញាតឱ្យជប់លៀង',
    'អនុញ្ញាតឱ្យចម្អិនអាហារ',
    'បង់ថ្លៃឈ្នួលទៀងទាត់',
  ];
  final Set<String> _selectedRules = {'ហាមជក់បារីក្នុងបន្ទប់'};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _addressCtrl.dispose();
    _totalUnitsCtrl.dispose();
    _availableUnitsCtrl.dispose();
    _sizeCtrl.dispose();
    _floorCtrl.dispose();
    _depositCtrl.dispose();
    _depositPriceCtrl.dispose();
    _descriptionCtrl.dispose();
    _customFacilityCtrl.dispose();
    _customRuleCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _roomService.getCategories();
      if (!mounted) return;
      setState(() {
        _apiCategories = cats;
        _isLoadingCategories = false;
        if (_apiCategories.isNotEmpty) {
          _selectedCategoryId = _apiCategories.first['id'] as int?;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickCoverImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _coverImage = picked);
      }
    } catch (e) {
      AppAlert.error('បរាជ័យ', 'មិនអាចជ្រើសរើសរូបភាពបានទេ: $e');
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      final pickedList = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedList.isNotEmpty && mounted) {
        setState(() {
          _galleryImages.addAll(pickedList);
        });
      }
    } catch (e) {
      AppAlert.error('បរាជ័យ', 'មិនអាចជ្រើសរើសរូបភាពបានទេ: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppAlert.warning(
          'សេវាទីតាំង',
          'សូមបើក Location Service នៅលើទូរស័ព្ទរបស់អ្នក',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppAlert.warning('ការអនុញ្ញាត', 'ការចូលប្រើទីតាំងត្រូវបានបដិសេធ');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppAlert.warning(
          'ការអនុញ្ញាត',
          'សូមបើកសិទ្ធិចូលប្រើទីតាំងនៅក្នុង Settings',
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
        AppAlert.success('ជោគជ័យ', 'ទទួលបានកូអរដោនេទីតាំងបច្ចុប្បន្នរួចរាល់');
      }
    } catch (e) {
      AppAlert.error('បរាជ័យ', 'មិនអាចទាញយកទីតាំងបានទេ: $e');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _submitRoom() async {
    if (!_formKey.currentState!.validate()) {
      AppAlert.warning(
        'ព័ត៌មានមិនទាន់គ្រប់គ្រាន់',
        'សូមបំពេញចន្លោះដែលតម្រូវឱ្យបានត្រឹមត្រូវ',
      );
      return;
    }

    if (_coverImage == null) {
      AppAlert.warning(
        'ត្រូវការរូបភាព',
        'សូមជ្រើសរើសរូបភាពតំណាងបន្ទប់យ៉ាងហោចណាស់ ១ សន្លឹក',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
      final totalUnits = int.tryParse(_totalUnitsCtrl.text.trim()) ?? 1;
      final availableUnits =
          int.tryParse(_availableUnitsCtrl.text.trim()) ?? totalUnits;

      await _roomService.createRoom(
        name: _nameCtrl.text.trim(),
        price: price,
        address: _addressCtrl.text.trim(),
        categoryId: _selectedCategoryId,
        type: _selectedType,
        pricePeriod: _selectedPricePeriod,
        status: _selectedStatus,
        totalUnits: totalUnits,
        availableUnits: availableUnits,
        isNegotiable: _isNegotiable,
        description: _descriptionCtrl.text.trim(),
        size: _sizeCtrl.text.trim().isNotEmpty ? _sizeCtrl.text.trim() : null,
        floor: _floorCtrl.text.trim().isNotEmpty
            ? _floorCtrl.text.trim()
            : null,
        deposit: _depositCtrl.text.trim().isNotEmpty
            ? _depositCtrl.text.trim()
            : null,
        depositPrice: double.tryParse(_depositPriceCtrl.text.trim()),
        facilities: _selectedFacilities.toList(),
        houseRules: _selectedRules.toList(),
        latitude: _latitude,
        longitude: _longitude,
        mainImagePath: _coverImage?.path,
        galleryImagePaths: _galleryImages.map((e) => e.path).toList(),
      );

      if (!mounted) return;

      AppAlert.success('ជោគជ័យ', 'បន្ទប់របស់អ្នកត្រូវបានបង្ហោះដោយជោគជ័យ!');

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppAlert.error('បរាជ័យ', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ជ្រើសរើសប្រភពរូបភាព',
                style: GoogleFonts.battambang(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: Text('ថតរូបពីកាមេរ៉ា', style: GoogleFonts.battambang()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickCoverImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFDF2F8),
                  child: Icon(Icons.photo_library, color: Colors.pinkAccent),
                ),
                title: Text(
                  'ជ្រើសរើសពីរូបភាពទូរស័ព្ទ',
                  style: GoogleFonts.battambang(),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickCoverImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.neutral,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'បង្ហោះបន្ទប់ថ្មី',
          style: GoogleFonts.battambang(
            color: AppColors.neutral,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // 1. Photos Section
            _buildSectionCard(
              title: 'រូបថតបន្ទប់ (Photos)',
              subtitle: 'រូបភាពច្បាស់ និងទាក់ទាញ ជួយឱ្យមានការចាប់អារម្មណ៍ច្រើន',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image
                  Text(
                    'រូបភាពតំណាង (Cover Photo) *',
                    style: GoogleFonts.battambang(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showImagePickerSheet,
                    child: _coverImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  File(_coverImage!.path),
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    onPressed: _showImagePickerSheet,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'រូបភាពតំណាង',
                                    style: GoogleFonts.battambang(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Color(0xFFE2E8F0),
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: AppColors.primary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ចុចដើម្បីជ្រើសរើសរូបភាពតំណាង',
                                  style: GoogleFonts.battambang(
                                    color: const Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ទ្រទ្រង់ JPG, PNG (រូបភាពទំហំធំ ច្បាស់)',
                                  style: GoogleFonts.battambang(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Gallery Images
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'រូបថតបន្ថែម (${_galleryImages.length} សន្លឹក)',
                        style: GoogleFonts.battambang(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickGalleryImages,
                        icon: const Icon(Icons.add_photo_alternate, size: 18),
                        label: Text(
                          'បន្ថែមរូបភាព',
                          style: GoogleFonts.battambang(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  if (_galleryImages.isNotEmpty)
                    SizedBox(
                      height: 85,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _galleryImages.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final img = _galleryImages[idx];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(img.path),
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _galleryImages.removeAt(idx);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _pickGalleryImages,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            '+ បន្ថែមរូបភាពបន្ទប់ទឹក បន្ទប់ទទួលភ្ញៀវ ឬយ៉រ',
                            style: GoogleFonts.battambang(
                              color: const Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Room Basic Details
            _buildSectionCard(
              title: 'ព័ត៌មានបន្ទប់ (Room Information)',
              subtitle: 'បញ្ជាក់ព័ត៌មានលម្អិតនៃបន្ទប់ ឬផ្ទះជួល',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Name
                  _buildLabel('ឈ្មោះបន្ទប់ ឬចំណងជើង *'),
                  TextFormField(
                    controller: _nameCtrl,
                    style: GoogleFonts.battambang(),
                    decoration: _inputDecoration(
                      hint: 'ឧ. បន្ទប់ជួលស្អាត ក្បែរផ្សារទួលទំពូង',
                      prefixIcon: Icons.home_work_outlined,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'សូមបញ្ចូលឈ្មោះបន្ទប់';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Category Selector
                  _buildLabel('ប្រភេទអគារ/បន្ទប់ (Category)'),
                  if (_isLoadingCategories)
                    const LinearProgressIndicator()
                  else
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      style: GoogleFonts.battambang(
                        color: AppColors.neutral,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: 'ជ្រើសរើសប្រភេទបន្ទប់',
                        prefixIcon: Icons.category_outlined,
                      ),
                      items: _apiCategories.isNotEmpty
                          ? _apiCategories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat['id'] as int?,
                                child: Text(cat['name']?.toString() ?? ''),
                              );
                            }).toList()
                          : [
                              const DropdownMenuItem<int>(
                                value: 1,
                                child: Text('បន្ទប់ជួល (Private Room)'),
                              ),
                              const DropdownMenuItem<int>(
                                value: 2,
                                child: Text('ស្ទូឌីយោ (Studio Apartment)'),
                              ),
                              const DropdownMenuItem<int>(
                                value: 3,
                                child: Text('បន្ទប់រួម (Shared Room)'),
                              ),
                              const DropdownMenuItem<int>(
                                value: 4,
                                child: Text('ខុនដូ (Condo)'),
                              ),
                            ],
                      onChanged: (val) {
                        setState(() => _selectedCategoryId = val);
                      },
                    ),

                  const SizedBox(height: 14),

                  // Room Type
                  _buildLabel('ប្រភេទការស្នាក់នៅ (Room Type)'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSelectableChip(
                        label: 'បន្ទប់ឯកជន (Private)',
                        value: 'Private Room',
                        groupValue: _selectedType,
                        onSelected: (v) => setState(() => _selectedType = v),
                      ),
                      _buildSelectableChip(
                        label: 'ផ្ទះទាំងមូល (Entire Unit)',
                        value: 'Entire Unit',
                        groupValue: _selectedType,
                        onSelected: (v) => setState(() => _selectedType = v),
                      ),
                      _buildSelectableChip(
                        label: 'បន្ទប់រួម (Shared Room)',
                        value: 'Shared Room',
                        groupValue: _selectedType,
                        onSelected: (v) => setState(() => _selectedType = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Price & Period
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(r'តម្លៃជួល ($) *'),
                            TextFormField(
                              controller: _priceCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: GoogleFonts.battambang(
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: _inputDecoration(
                                hint: '120.00',
                                prefixIcon: Icons.attach_money,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'សូមបញ្ចូលតម្លៃ';
                                }
                                if (double.tryParse(val.trim()) == null) {
                                  return 'តម្លៃមិនត្រឹមត្រូវ';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ក្នុងមួយ'),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPricePeriod,
                              style: GoogleFonts.battambang(
                                color: AppColors.neutral,
                                fontSize: 13,
                              ),
                              decoration: _inputDecoration(hint: 'ខែ'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'month',
                                  child: Text('/ ខែ'),
                                ),
                                DropdownMenuItem(
                                  value: 'night',
                                  child: Text('/ យប់'),
                                ),
                                DropdownMenuItem(
                                  value: 'year',
                                  child: Text('/ ឆ្នាំ'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedPricePeriod = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Negotiable toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.handshake_outlined,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'តម្លៃអាចចរចាបាន (Negotiable)',
                            style: GoogleFonts.battambang(
                              fontSize: 13,
                              color: AppColors.neutral,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isNegotiable,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isNegotiable = val),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Total and Available Units
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ចំនួនបន្ទប់សរុប'),
                            TextFormField(
                              controller: _totalUnitsCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.battambang(),
                              decoration: _inputDecoration(
                                hint: '1',
                                prefixIcon: Icons.apartment_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ចំនួនបន្ទប់ទំនេរ'),
                            TextFormField(
                              controller: _availableUnitsCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.battambang(),
                              decoration: _inputDecoration(
                                hint: '1',
                                prefixIcon: Icons.meeting_room_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Status
                  _buildLabel('ស្ថានភាពបន្ទប់ (Status)'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    style: GoogleFonts.battambang(
                      color: AppColors.neutral,
                      fontSize: 13,
                    ),
                    decoration: _inputDecoration(
                      hint: 'ជ្រើសរើសស្ថានភាព',
                      prefixIcon: Icons.info_outline,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'AVAILABLE NOW',
                        child: Text('ទំនេរ (AVAILABLE)'),
                      ),
                      DropdownMenuItem(
                        value: 'BOOKED',
                        child: Text('ត្រូវបានកក់ (BOOKED)'),
                      ),
                      DropdownMenuItem(
                        value: 'OCCUPIED',
                        child: Text('ត្រូវបានជួល (OCCUPIED)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Specifications (Size, Floor, Deposit)
            _buildSectionCard(
              title: 'លក្ខណៈបន្ទប់ (Specifications)',
              subtitle: 'ព័ត៌មានបន្ថែមជួយឱ្យអ្នកជួលយល់កាន់តែច្បាស់',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ទំហំបន្ទប់'),
                            TextFormField(
                              controller: _sizeCtrl,
                              style: GoogleFonts.battambang(),
                              decoration: _inputDecoration(
                                hint: 'ឧ. 4m x 6m (24 m²)',
                                prefixIcon: Icons.straighten_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ជាន់ទី (Floor)'),
                            TextFormField(
                              controller: _floorCtrl,
                              style: GoogleFonts.battambang(),
                              decoration: _inputDecoration(
                                hint: 'ឧ. ជាន់ទី ២',
                                prefixIcon: Icons.layers_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('ប្រាក់កក់ (Deposit General)'),
                  TextFormField(
                    controller: _depositCtrl,
                    style: GoogleFonts.battambang(),
                    decoration: _inputDecoration(
                      hint: 'ឧ. ១ ខែ ឬ មិនតម្រូវឱ្យកក់',
                      prefixIcon: Icons.shield_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('ប្រាក់កក់សម្រាប់កក់បន្ទប់តាម Bakong KHQR (\$)'),
                  TextFormField(
                    controller: _depositPriceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.battambang(),
                    decoration: _inputDecoration(
                      hint: 'ឧ. 20 (ចំនួនទឹកប្រាក់ដែល Customer ត្រូវកក់)',
                      prefixIcon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '* អតិថិជននឹងបង់ប្រាក់កក់ចំនួននេះតាម Bakong KHQR ចូលគណនីបាគងរបស់អ្នកដោយផ្ទាល់ ដើម្បីចាក់សោកក់បន្ទប់នេះ។',
                    style: GoogleFonts.battambang(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Facilities & Amenities
            _buildSectionCard(
              title: 'បរិក្ខារ និងសម្ភារៈ (Facilities)',
              subtitle: 'ចុចលើបរិក្ខារដែលមាននៅក្នុងបន្ទប់ ឬអគារ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableFacilities.map((facility) {
                      final isSelected = _selectedFacilities.contains(facility);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(
                          facility,
                          style: GoogleFonts.battambang(
                            color: isSelected
                                ? Colors.white
                                : AppColors.neutral,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: const Color(0xFFF1F5F9),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFacilities.add(facility);
                            } else {
                              _selectedFacilities.remove(facility);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Add custom facility
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customFacilityCtrl,
                          style: GoogleFonts.battambang(fontSize: 13),
                          decoration: _inputDecoration(
                            hint: '+ បញ្ចូលបរិក្ខារផ្សេងៗបន្ថែម...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final text = _customFacilityCtrl.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              _availableFacilities.add(text);
                              _selectedFacilities.add(text);
                              _customFacilityCtrl.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'ថែម',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. House Rules
            _buildSectionCard(
              title: 'វិន័យ និងបម្រាម (House Rules)',
              subtitle: 'កម្រិត និងការអនុញ្ញាតផ្សេងៗ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableRules.map((rule) {
                      final isSelected = _selectedRules.contains(rule);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(
                          rule,
                          style: GoogleFonts.battambang(
                            color: isSelected
                                ? Colors.white
                                : AppColors.neutral,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selectedColor: const Color(0xFFE11D48),
                        backgroundColor: const Color(0xFFF1F5F9),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFE11D48)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedRules.add(rule);
                            } else {
                              _selectedRules.remove(rule);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customRuleCtrl,
                          style: GoogleFonts.battambang(fontSize: 13),
                          decoration: _inputDecoration(
                            hint: '+ បញ្ចូលវិន័យបន្ថែម...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final text = _customRuleCtrl.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              _availableRules.add(text);
                              _selectedRules.add(text);
                              _customRuleCtrl.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'ថែម',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 6. Address & GPS Location
            _buildSectionCard(
              title: 'ទីតាំង និងអាសយដ្ឋាន (Location)',
              subtitle: 'អាសយដ្ឋានច្បាស់លាស់ជួយឱ្យអ្នកជួលងាយស្រួលរកឃើញ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('អាសយដ្ឋានលម្អិត *'),
                  TextFormField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    style: GoogleFonts.battambang(),
                    decoration: _inputDecoration(
                      hint:
                          'ឧ. ផ្ទះលេខ ១២, ផ្លូវ ៣១០, សង្កាត់បឹងកេងកង ១, ខណ្ឌចំការមន, ភ្នំពេញ',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'សូមបញ្ចូលអាសយដ្ឋាន';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // GPS Coordinates auto-detect
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _latitude != null && _longitude != null
                                    ? 'GPS: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                                    : 'ទាញយកទីតាំង GPS បច្ចុប្បន្ន',
                                style: GoogleFonts.battambang(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _latitude != null
                                      ? Colors.green.shade700
                                      : AppColors.neutral,
                                ),
                              ),
                              Text(
                                _latitude != null
                                    ? 'ទីតាំងត្រូវបានកំណត់លើផែនទី'
                                    : 'ជួយឱ្យបន្ទប់របស់អ្នកបង្ហាញលើ Map របស់អតិថិជន',
                                style: GoogleFonts.battambang(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isGettingLocation
                              ? null
                              : _getCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          child: _isGettingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _latitude != null
                                      ? 'ផ្លាស់ប្តូរ'
                                      : 'កំណត់ GPS',
                                  style: GoogleFonts.battambang(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 7. Description
            _buildSectionCard(
              title: 'ការពិពណ៌នាបន្ថែម (Description)',
              subtitle:
                  'ព័ត៌មានលម្អិតជុំវិញបន្ទប់ ទីតាំងជិតផ្សារ សាលារៀន ឬលក្ខខណ្ឌពិសេស',
              child: TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                style: GoogleFonts.battambang(fontSize: 13),
                decoration: _inputDecoration(
                  hint:
                      'ឧ. បន្ទប់ធំទូលាយ មានពន្លឺថ្ងៃគ្រប់គ្រាន់ សុវត្ថិភាពខ្ពស់ ជិតសាកលវិទ្យាល័យ...',
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 8. Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: ModernButtonContent(
                  isLoading: _isSubmitting,
                  text: 'បង្ហោះបន្ទប់ឥឡូវនេះ',
                  loadingText: 'កំពុងបង្ហោះបន្ទប់',
                  icon: Icons.cloud_upload_outlined,
                  iconSize: 22,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.battambang(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.battambang(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.battambang(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required String value,
    required String groupValue,
    required Function(String) onSelected,
  }) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.battambang(
          color: isSelected ? Colors.white : AppColors.neutral,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
        ),
      ),
      onSelected: (_) => onSelected(value),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.battambang(
        color: const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF64748B), size: 20)
          : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
