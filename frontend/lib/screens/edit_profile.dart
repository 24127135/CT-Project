import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _emailController;
  String? _selectedGender;

  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Nguyễn Sơn Lộc');
    _phoneController = TextEditingController(text: '0374941152');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _emailController = TextEditingController(text: 'sonloc@gmail.com');
    _selectedGender = 'male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Lưu ý',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bạn chưa lưu thông tin hồ sơ\nXác nhận thoát ra?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF697282),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF2D4930), // xanh lá đậm
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text(
                            'Từ chối',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF36AE19), // xanh lá sáng
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return shouldLeave ?? false;
  }

  void _handleBackPressed() async {
    final canPop = await _onWillPop();
    if (canPop && mounted) Navigator.of(context).pop();
  }

  void _handleSave() {
    // TODO: call API / bloc to save profile
    setState(() {
      _isDirty = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu thông tin hồ sơ'),
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildHeader() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(1, 1),
          end: Alignment(-1, -1),
          colors: [
            Color(0xFF53BB30), // Highlight
            Color(0xFF0D1711),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Tùy chỉnh hồ sơ',
                style: const TextStyle(
                  color: Color(0xFFF8F5F2),
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 4,
              child: IconButton(
                onPressed: _handleBackPressed,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        children: [
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(width: 4, color: Colors.white),
            ),
            child: const CircleAvatar(
              backgroundColor: Color(0xFFD9D9D9),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  width: 1,
                  color: Color(0xFFE5E7EB),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(9999),
                onTap: () {
                  // TODO: mở gallery / camera
                },
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: Color(0xFF101727),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return const Text(
      'App Trek Guide được tạo ra bởi nhóm Five Point Crew\n'
          'Là một đồ án đại học\n'
          'Không có giá trị thương mại!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF040404),
        fontSize: 10,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5F2),
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAvatar(),
                        const SizedBox(height: 32),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Thông tin cá nhân',
                            style: const TextStyle(
                              color: Color(0xFF101727),
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          onChanged: (_) => _markDirty(),
                          decoration: _inputDecoration('Họ và tên'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          onChanged: (_) => _markDirty(),
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration('Số điện thoại'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _currentPasswordController,
                          onChanged: (_) => _markDirty(),
                          obscureText: true,
                          decoration: _inputDecoration('Mật khẩu hiện tại'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newPasswordController,
                          onChanged: (_) => _markDirty(),
                          obscureText: true,
                          decoration: _inputDecoration('Mật khẩu mới'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          onChanged: (_) => _markDirty(),
                          obscureText: true,
                          decoration: _inputDecoration('Nhập lại mật khẩu mới'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          onChanged: (_) => _markDirty(),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration('Email'),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: _inputDecoration('Giới tính'),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Nam'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Nữ'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Khác'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                              _markDirty();
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 169,
                          height: 53,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC2CDBF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _handleSave,
                            child: const Text(
                              'Xác nhận',
                              style: TextStyle(
                                color: Color(0xFF0B3800),
                                fontSize: 20,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 12),
                  child: _buildFooterNote(),
                ),
              ],
            ),
            if (_isDirty)
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: SizedBox(
                  height: 53,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF36AE19),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _handleSave,
                    child: const Text(
                      'Lưu thay đổi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFC2CDBF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFC2CDBF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF36AE19),
        ),
      ),
    );
  }
}
