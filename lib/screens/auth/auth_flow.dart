import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../repositories/app_repository.dart';
import '../../theme.dart';
import '../../widgets.dart';

const _socialAuthRedirectUrl = String.fromEnvironment(
  'SUPABASE_AUTH_REDIRECT_URL',
);

enum _OtpLoginMethod { phone, email }

class _PendingOtpLogin {
  final _OtpLoginMethod method;
  final String target;

  const _PendingOtpLogin({required this.method, required this.target});

  String get destinationLabel {
    return switch (method) {
      _OtpLoginMethod.phone => target,
      _OtpLoginMethod.email => target,
    };
  }
}

_PendingOtpLogin? _pendingOtpLogin;

class SplashScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const SplashScreen({super.key, required this.go});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) widget.go('login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthGradientShell(
      child: Column(
        children: [
          const Spacer(),
          _RepairMark(size: 116),
          const SizedBox(height: 24),
          Text(
            'Beresin',
            style: pj(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Foto masalah rumahmu, Beresin bantu cari tukangnya.',
              textAlign: TextAlign.center,
              style: pj(
                color: Colors.white.withValues(alpha: .84),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFFD89B),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Menyiapkan bantuan lokal terpercaya...',
                style: pj(
                  color: Colors.white.withValues(alpha: .76),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const LoginScreen({super.key, required this.go});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loading = false;
  OAuthProvider? _loadingProvider;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    final supabase = _supabaseClientOrNull();
    if (supabase == null) return;
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted || data.session == null) return;
      setState(() => _loadingProvider = null);
      unawaited(_ensureUserProfile(data.session!.user));
      widget.go('roleSelection');
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_loading) return;
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;
    if (!email.contains('@')) {
      _showAuthToast(context, 'Masukkan email yang valid.');
      return;
    }
    if (password.isEmpty) {
      _showAuthToast(context, 'Masukkan kata sandi.');
      return;
    }
    final supabase = _supabaseClientOrNull();
    if (supabase == null) {
      _showAuthToast(context, 'Supabase belum aktif.');
      return;
    }
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      // auth state listener handles navigation
    } on AuthException catch (error) {
      if (!mounted) return;
      _showAuthToast(context, _mapAuthError(error.message));
    } catch (_) {
      if (!mounted) return;
      _showAuthToast(context, 'Login gagal. Periksa koneksi internet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithProvider(OAuthProvider provider) async {
    if (_loadingProvider != null) return;
    final supabase = _supabaseClientOrNull();
    if (supabase == null) {
      _showAuthToast(
        context,
        'Supabase belum diinisialisasi. Tambahkan URL dan anon key sebelum login sosial.',
      );
      return;
    }
    setState(() => _loadingProvider = provider);
    try {
      final launched = await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: _socialAuthRedirectUrl.isEmpty
            ? null
            : _socialAuthRedirectUrl,
      );
      if (!mounted) return;
      if (!launched) {
        setState(() => _loadingProvider = null);
        _showAuthToast(context, 'Browser login gagal dibuka. Coba lagi.');
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _loadingProvider = null);
      _showAuthToast(context, error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProvider = null);
      _showAuthToast(context, 'Login sosial belum siap. Cek konfigurasi auth.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthPageScaffold(
      top: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrLogo(size: 42),
              const SizedBox(width: 10),
              Text(
                'Beresin',
                style: pj(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'Masuk ke Beresin',
            style: pj(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Masuk untuk booking layanan dan cari tukang terpercaya di sekitarmu.',
            style: pj(
              color: Colors.white.withValues(alpha: .82),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email',
            style: pj(
              fontSize: 12.5,
              color: AppColors.ink2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            style: pj(fontSize: 15, color: AppColors.ink),
            decoration: const InputDecoration(hintText: 'nama@email.com'),
          ),
          const SizedBox(height: 14),
          Text(
            'Kata Sandi',
            style: pj(
              fontSize: 12.5,
              color: AppColors.ink2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePass,
            autofillHints: const [AutofillHints.password],
            style: pj(fontSize: 15, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            onSubmitted: (_) => _signIn(),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  _showAuthToast(context, 'Fitur lupa kata sandi segera hadir.'),
              child: Text(
                'Lupa kata sandi?',
                style: pj(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          BrButton(
            label: _loading ? 'Masuk...' : 'Masuk',
            full: true,
            size: BrButtonSize.lg,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.login_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
            onPressed: _loading ? null : _signIn,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.line)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'atau',
                  style: pj(fontSize: 12, color: AppColors.muted),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.line)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SocialLoginButton(
                  label: 'Google',
                  asset: 'assets/google.png',
                  loading: _loadingProvider == OAuthProvider.google,
                  disabled: _loadingProvider != null,
                  onTap: () => _signInWithProvider(OAuthProvider.google),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SocialLoginButton(
                  label: 'Facebook',
                  asset: 'assets/facebook.png',
                  loading: _loadingProvider == OAuthProvider.facebook,
                  disabled: _loadingProvider != null,
                  onTap: () => _signInWithProvider(OAuthProvider.facebook),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Dengan masuk, kamu menyetujui Syarat Layanan dan Kebijakan Privasi Beresin.',
            style: pj(fontSize: 11.5, color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Belum punya akun?',
                style: pj(fontSize: 13, color: AppColors.ink2),
              ),
              TextButton(
                onPressed: () => widget.go('register'),
                child: Text(
                  'Daftar',
                  style: pj(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const RegisterScreen({super.key, required this.go});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;
    setState(() {
      _nameError = name.isEmpty ? 'Nama lengkap wajib diisi' : null;
      _emailError =
          !RegExp(r'^[\w.+\-]+@([\w\-]+\.)+[a-z]{2,}$').hasMatch(email)
              ? 'Format email tidak valid'
              : null;
      _passwordError =
          pass.length < 8 ? 'Kata sandi minimal 8 karakter' : null;
      _confirmError =
          confirm != pass ? 'Konfirmasi kata sandi tidak cocok' : null;
    });
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  Future<void> _register() async {
    if (!_validate() || _loading) return;
    final supabase = _supabaseClientOrNull();
    if (supabase == null) {
      _showAuthToast(context, 'Supabase belum aktif.');
      return;
    }
    setState(() => _loading = true);
    try {
      final name = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim().toLowerCase();
      final phone =
          _normalizeIndonesianPhone(_phoneCtrl.text) ?? _phoneCtrl.text.trim();

      final response = await supabase.auth.signUp(
        email: email,
        password: _passwordCtrl.text,
        data: {'full_name': name, 'phone': phone},
      );

      if (!mounted) return;

      final user = response.user;
      if (user == null) {
        _showAuthToast(context, 'Pendaftaran gagal. Coba lagi.');
        return;
      }

      if (user.identities?.isEmpty == true) {
        _showAuthToast(context, 'Email sudah terdaftar. Silakan masuk.');
        return;
      }

      if (response.session != null) {
        await _ensureUserProfile(user);
        if (!mounted) return;
        widget.go('roleSelection');
      } else {
        _pendingOtpLogin = _PendingOtpLogin(
          method: _OtpLoginMethod.email,
          target: email,
        );
        widget.go('otp');
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      _showAuthToast(context, _mapAuthError(error.message));
    } catch (_) {
      if (!mounted) return;
      _showAuthToast(context, 'Pendaftaran gagal. Periksa koneksi internet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? error,
    bool obscure = false,
    bool showToggle = false,
    VoidCallback? onToggleObscure,
    List<String> autofill = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: pj(
            fontSize: 12.5,
            color: AppColors.ink2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          autofillHints: autofill.isEmpty ? null : autofill,
          style: pj(fontSize: 15, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            suffixIcon: showToggle
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AuthPageScaffold(
      top: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrLogo(size: 42),
              const SizedBox(width: 10),
              Text(
                'Beresin',
                style: pj(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            'Daftar ke Beresin',
            style: pj(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Buat akun untuk booking layanan dan cari tukang terpercaya di sekitarmu.',
            style: pj(
              color: Colors.white.withValues(alpha: .82),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            controller: _nameCtrl,
            label: 'Nama Lengkap',
            hint: 'Contoh: Budi Santoso',
            keyboardType: TextInputType.name,
            error: _nameError,
            autofill: const [AutofillHints.name],
          ),
          const SizedBox(height: 14),
          _field(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'nama@email.com',
            keyboardType: TextInputType.emailAddress,
            error: _emailError,
            autofill: const [AutofillHints.email],
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nomor WhatsApp',
                style: pj(
                  fontSize: 12.5,
                  color: AppColors.ink2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+62',
                      style: pj(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: pj(fontSize: 15, color: AppColors.ink),
                      decoration: const InputDecoration(
                        hintText: '812-3456-7890',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _field(
            controller: _passwordCtrl,
            label: 'Kata Sandi',
            hint: '••••••••',
            obscure: _obscurePass,
            error: _passwordError,
            showToggle: true,
            onToggleObscure: () =>
                setState(() => _obscurePass = !_obscurePass),
            autofill: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 14),
          _field(
            controller: _confirmCtrl,
            label: 'Konfirmasi Kata Sandi',
            hint: '••••••••',
            obscure: _obscureConfirm,
            error: _confirmError,
            showToggle: true,
            onToggleObscure: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 20),
          BrButton(
            label: _loading ? 'Mendaftarkan...' : 'Daftar',
            full: true,
            size: BrButtonSize.lg,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.person_add_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
            onPressed: _loading ? null : _register,
          ),
          const SizedBox(height: 14),
          Text(
            'Dengan mendaftar, kamu menyetujui Syarat Layanan dan Kebijakan Privasi Beresin.',
            style: pj(fontSize: 11.5, color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sudah punya akun?',
                style: pj(fontSize: 13, color: AppColors.ink2),
              ),
              TextButton(
                onPressed: () => widget.go('login'),
                child: Text(
                  'Masuk',
                  style: pj(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

SupabaseClient? _supabaseClientOrNull() {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

String? _normalizeIndonesianPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('0')) {
    digits = '62${digits.substring(1)}';
  } else if (digits.startsWith('8')) {
    digits = '62$digits';
  }
  if (!digits.startsWith('62') || digits.length < 10) return null;
  return '+$digits';
}

String _mapAuthError(String message) {
  if (message.contains('Invalid login credentials') ||
      message.contains('invalid_credentials')) {
    return 'Email atau kata sandi salah.';
  }
  if (message.contains('Email not confirmed')) {
    return 'Email belum dikonfirmasi. Cek inbox email kamu.';
  }
  if (message.contains('User already registered') ||
      message.contains('already been registered')) {
    return 'Email sudah terdaftar. Silakan masuk.';
  }
  if (message.contains('Password should be at least')) {
    return 'Kata sandi terlalu pendek (minimal 6 karakter).';
  }
  if (message.contains('rate limit') ||
      message.contains('over_email_send_rate_limit')) {
    return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
  }
  if (message.contains('signup_disabled')) {
    return 'Pendaftaran sedang dinonaktifkan. Hubungi admin.';
  }
  if (message.contains('Email logins are disabled')) {
    return 'Login email belum diaktifkan di pengaturan Supabase.';
  }
  return message;
}

Future<void> _ensureUserProfile(User user) async {
  final supabase = _supabaseClientOrNull();
  if (supabase == null) return;
  final metadata = user.userMetadata ?? const <String, dynamic>{};
  final name =
      (metadata['full_name'] ??
              metadata['name'] ??
              user.email ??
              user.phone ??
              '')
          .toString();
  final displayName = name.isEmpty ? 'Customer Beresin' : name;
  try {
    final rows = await supabase
        .from('users')
        .upsert({
          'auth_user_id': user.id,
          'email': user.email,
          'phone_number': user.phone ??
          (metadata['phone'] as String?) ??
          (metadata['phone_number'] as String?),
          'role': 'customer',
          'name': displayName,
          'area': 'Tebet, Jakarta Selatan',
        }, onConflict: 'auth_user_id')
        .select('user_id');

    if (rows.isEmpty) return;
    final userId = rows.first['user_id'] as String;

    await supabase.from('customers').upsert({
      'customer_id': userId,
      'is_active': true,
    }, onConflict: 'customer_id');

    unawaited(
      (appRepository as HybridBeresinRepository).loadFromSupabase(userId),
    );
  } catch (_) {
    // Profile persistence should not block auth completion during setup.
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final String asset;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.label,
    required this.asset,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled && !loading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: disabled && !loading ? AppColors.bg : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: .05),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                SizedBox(
                  width: 22,
                  height: 22,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      asset,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: pj(
                    fontSize: 13,
                    color: disabled && !loading
                        ? AppColors.muted
                        : AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const OtpScreen({super.key, required this.go});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final code = TextEditingController();
  bool verifying = false;
  int _seconds = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _seconds = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (verifying) return;
    final pending = _pendingOtpLogin;
    final token = code.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (pending == null) {
      _showAuthToast(context, 'Mulai ulang login untuk meminta OTP baru.');
      return;
    }
    if (token.length != 6) {
      _showAuthToast(context, 'Masukkan 6 digit kode OTP.');
      return;
    }

    final supabase = _supabaseClientOrNull();
    if (supabase == null) {
      _showAuthToast(context, 'Supabase belum aktif.');
      return;
    }

    setState(() => verifying = true);
    try {
      final response = await supabase.auth.verifyOTP(
        email: pending.method == _OtpLoginMethod.email ? pending.target : null,
        phone: pending.method == _OtpLoginMethod.phone ? pending.target : null,
        token: token,
        type: pending.method == _OtpLoginMethod.email
            ? OtpType.email
            : OtpType.sms,
      );
      if (response.user != null) {
        await _ensureUserProfile(response.user!);
      }
      if (!mounted) return;
      widget.go('roleSelection');
    } on AuthException catch (error) {
      if (!mounted) return;
      _showAuthToast(context, error.message);
    } catch (_) {
      if (!mounted) return;
      _showAuthToast(context, 'Kode OTP tidak valid atau sudah kedaluwarsa.');
    } finally {
      if (mounted) setState(() => verifying = false);
    }
  }

  Future<void> _resend() async {
    final pending = _pendingOtpLogin;
    final supabase = _supabaseClientOrNull();
    if (pending == null || supabase == null) {
      _showAuthToast(context, 'Mulai ulang login untuk meminta OTP baru.');
      return;
    }
    try {
      if (pending.method == _OtpLoginMethod.email) {
        await supabase.auth.signInWithOtp(
          email: pending.target,
          shouldCreateUser: true,
        );
      } else {
        await supabase.auth.signInWithOtp(
          phone: pending.target,
          shouldCreateUser: true,
          channel: OtpChannel.sms,
        );
      }
      if (!mounted) return;
      _startCountdown();
      _showAuthToast(context, 'Kode OTP baru dikirim.');
    } on AuthException catch (error) {
      if (!mounted) return;
      _showAuthToast(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SimpleAuthScaffold(
      title: 'Masukkan Kode OTP',
      subtitle: _pendingOtpLogin == null
          ? 'Masukkan kode 6 digit dari Supabase Auth.'
          : 'Kode 6 digit sudah dikirim ke ${_pendingOtpLogin!.destinationLabel}.',
      onBack: () => widget.go('login'),
      children: [
        TextField(
          controller: code,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: pj(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            hintText: '000000',
            counterText: '',
          ),
        ),
        const SizedBox(height: 16),
        BrButton(
          label: verifying ? 'Memverifikasi...' : 'Verifikasi',
          full: true,
          size: BrButtonSize.lg,
          icon: verifying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : null,
          onPressed: verifying ? null : _verify,
        ),
        const SizedBox(height: 14),
        Center(
          child: _seconds > 0
              ? Text(
                  'Kirim ulang dalam $_seconds detik',
                  style: pj(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : TextButton(
                  onPressed: _resend,
                  child: Text(
                    'Kirim ulang kode',
                    style: pj(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
        ),
        Center(
          child: TextButton(
            onPressed: () => widget.go('login'),
            child: Text(
              'Ganti nomor',
              style: pj(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const RoleSelectionScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    return _SimpleAuthScaffold(
      title: 'Kamu mau pakai Beresin untuk apa?',
      subtitle:
          'Tenang, kamu bisa menambah atau mengganti mode kapan saja dari Profil.',
      children: [
        _RoleCard(
          icon: Icons.home_repair_service_outlined,
          title: 'Cari bantuan rumah',
          subtitle:
              'Untuk warga yang ingin cari tukang, cek harga wajar, dan booking layanan.',
          examples: 'AC bocor, pipa mampet, listrik mati, bersih rumah',
          cta: 'Masuk sebagai Customer',
          recommended: true,
          onTap: () => go('customerOnboarding'),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          icon: Icons.handyman_outlined,
          title: 'Daftar sebagai Tukang',
          subtitle:
              'Untuk pekerja lokal yang ingin mendapatkan order dari warga sekitar.',
          examples:
              'Teknisi AC, tukang ledeng, cleaning, tukang kebun, tukang cat',
          cta: 'Daftar jadi Mitra',
          onTap: () => go('workerOnboarding1'),
        ),
        const SizedBox(height: 14),
        const _TrustNote(
          icon: Icons.swap_horiz,
          text: 'Satu akun bisa punya dua mode.',
        ),
      ],
    );
  }
}

class CustomerOnboardingScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const CustomerOnboardingScreen({super.key, required this.go});

  @override
  State<CustomerOnboardingScreen> createState() =>
      _CustomerOnboardingScreenState();
}

class _CustomerOnboardingScreenState extends State<CustomerOnboardingScreen> {
  final location = TextEditingController();
  final interests = <String>{};

  @override
  void dispose() {
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const chips = [
      'AC',
      'Pipa',
      'Listrik',
      'Cleaning',
      'Kebun',
      'Cat',
      'Tukang',
    ];
    return _SimpleAuthScaffold(
      title: 'Bantu kami mengenal lokasimu',
      subtitle:
          'Beresin memakai lokasi untuk menampilkan tukang terdekat dan estimasi harga lokal.',
      onBack: () => widget.go('roleSelection'),
      children: [
        BrCard(
          padding: const EdgeInsets.all(14),
          color: AppColors.primary50,
          border: Border.all(color: AppColors.primary100),
          child: Row(
            children: [
              const Icon(Icons.my_location, color: AppColors.primaryDark),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Izinkan lokasi supaya rekomendasi tukang lebih dekat dan harga lebih akurat.',
                  style: pj(
                    fontSize: 12.5,
                    color: AppColors.primaryDark,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BrButton(
          label: 'Gunakan Lokasi Saat Ini',
          full: true,
          icon: const Icon(
            Icons.near_me_outlined,
            color: Colors.white,
            size: 17,
          ),
          onPressed: () {
            location.text = 'Tebet, Jakarta Selatan';
            _showAuthToast(context, 'Lokasi saat ini dipakai: Tebet.');
          },
        ),
        const SizedBox(height: 10),
        BrButton(
          label: 'Pilih lokasi manual',
          full: true,
          variant: BrButtonVariant.secondary,
          onPressed: () => _showAuthToast(context, 'Pilih area manual dibuka.'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: location,
          decoration: const InputDecoration(
            labelText: 'Alamat / area tersimpan',
            hintText: 'Contoh: Tebet, Jakarta Selatan',
          ),
        ),
        const SectionTitle('Kebutuhan yang sering kamu pakai'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((chip) {
            return BrChip(
              label: chip,
              active: interests.contains(chip),
              variant: 'primary',
              onTap: () {
                setState(() {
                  if (interests.contains(chip)) {
                    interests.remove(chip);
                  } else {
                    interests.add(chip);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        BrButton(
          label: 'Mulai Pakai Beresin',
          full: true,
          size: BrButtonSize.lg,
          onPressed: () => widget.go('home'),
        ),
      ],
    );
  }
}

class WorkerOnboardingStep1Screen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const WorkerOnboardingStep1Screen({super.key, required this.go});

  @override
  State<WorkerOnboardingStep1Screen> createState() =>
      _WorkerOnboardingStep1ScreenState();
}

class _WorkerOnboardingStep1ScreenState
    extends State<WorkerOnboardingStep1Screen> {
  bool photoReady = false;

  @override
  Widget build(BuildContext context) {
    return _WorkerStepScaffold(
      title: 'Daftar Jadi Mitra Beresin',
      subtitle: 'Lengkapi profil agar warga sekitar bisa menemukan layananmu.',
      progress: 'Langkah 1 dari 4',
      onBack: () => widget.go('roleSelection'),
      children: [
        const _AuthField(label: 'Nama lengkap', initial: 'Rudi Hartono'),
        const SizedBox(height: 10),
        const _AuthField(
          label: 'Nama panggilan / nama usaha',
          initial: 'Pak Rudi',
        ),
        const SizedBox(height: 10),
        const _AuthField(label: 'Nomor WhatsApp', initial: '+62 812-1110-0001'),
        const SizedBox(height: 10),
        _UploadTile(
          title: 'Foto profil',
          subtitle: photoReady
              ? 'Foto profil siap dipakai'
              : 'Upload foto wajah atau logo usaha',
          active: photoReady,
          onTap: () => setState(() => photoReady = true),
        ),
        const SizedBox(height: 10),
        const _AuthField(
          label: 'Domisili / area kerja utama',
          initial: 'Tebet, Jakarta Selatan',
        ),
        const SizedBox(height: 18),
        BrButton(
          label: 'Lanjut',
          full: true,
          size: BrButtonSize.lg,
          onPressed: () => widget.go('workerOnboarding2'),
        ),
      ],
    );
  }
}

class WorkerOnboardingStep2Screen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const WorkerOnboardingStep2Screen({super.key, required this.go});

  @override
  State<WorkerOnboardingStep2Screen> createState() =>
      _WorkerOnboardingStep2ScreenState();
}

class _WorkerOnboardingStep2ScreenState
    extends State<WorkerOnboardingStep2Screen> {
  final services = <String>{'Teknisi AC', 'Tukang Ledeng'};
  String experience = '5+ tahun';

  @override
  Widget build(BuildContext context) {
    const allServices = [
      'Teknisi AC',
      'Tukang Ledeng',
      'Tukang Listrik',
      'Cleaning Service',
      'Tukang Kebun',
      'Tukang Cat',
      'Tukang Bangunan',
      'Jasa Harian',
      'Lainnya',
    ];
    return _WorkerStepScaffold(
      title: 'Layanan apa yang kamu tawarkan?',
      subtitle:
          'Pilih satu atau beberapa layanan yang benar-benar kamu kuasai.',
      progress: 'Langkah 2 dari 4',
      onBack: () => widget.go('workerOnboarding1'),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allServices.map((service) {
            return BrChip(
              label: service,
              active: services.contains(service),
              variant: 'primary',
              onTap: () {
                setState(() {
                  if (services.contains(service)) {
                    services.remove(service);
                  } else {
                    services.add(service);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SectionTitle('Pengalaman kerja'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['<1 tahun', '1-3 tahun', '3-5 tahun', '5+ tahun'].map((
            item,
          ) {
            return BrChip(
              label: item,
              active: experience == item,
              variant: 'primary',
              onTap: () => setState(() => experience = item),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const _AuthField(
          label: 'Area kerja',
          initial: 'Tebet, Pancoran, Manggarai, Setiabudi',
          maxLines: 2,
        ),
        const SizedBox(height: 18),
        BrButton(
          label: 'Lanjut',
          full: true,
          size: BrButtonSize.lg,
          onPressed: () => widget.go('workerOnboarding3'),
        ),
      ],
    );
  }
}

class WorkerOnboardingStep3Screen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const WorkerOnboardingStep3Screen({super.key, required this.go});

  @override
  State<WorkerOnboardingStep3Screen> createState() =>
      _WorkerOnboardingStep3ScreenState();
}

class _WorkerOnboardingStep3ScreenState
    extends State<WorkerOnboardingStep3Screen> {
  String visit = '';
  String payment = '';
  bool emergency = false;

  @override
  Widget build(BuildContext context) {
    return _WorkerStepScaffold(
      title: 'Atur harga dan ketersediaan',
      subtitle: 'Bantu warga tahu kisaran biaya sebelum menghubungi kamu.',
      progress: 'Langkah 3 dari 4',
      onBack: () => widget.go('workerOnboarding2'),
      children: [
        const _AuthField(label: 'Harga mulai dari', initial: 'Rp80.000'),
        const SectionTitle('Estimasi kunjungan'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Bisa hari ini', 'Besok', 'By schedule'].map((item) {
            return BrChip(
              label: item,
              active: visit == item,
              variant: 'primary',
              onTap: () => setState(() => visit = item),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        const _AuthField(label: 'Jam kerja', initial: '09.00-18.00'),
        const SizedBox(height: 12),
        _SwitchRow(
          title: 'Bisa panggilan darurat',
          value: emergency,
          onChanged: (value) => setState(() => emergency = value),
        ),
        const SectionTitle('Preferensi pembayaran'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Bayar setelah selesai', 'Booking fee', 'QRIS / Transfer']
              .map((item) {
                return BrChip(
                  label: item,
                  active: payment == item,
                  variant: 'primary',
                  onTap: () => setState(() => payment = item),
                );
              })
              .toList(),
        ),
        const SizedBox(height: 18),
        BrButton(
          label: 'Lanjut',
          full: true,
          size: BrButtonSize.lg,
          onPressed: () => widget.go('workerOnboarding4'),
        ),
      ],
    );
  }
}

class WorkerOnboardingStep4Screen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const WorkerOnboardingStep4Screen({super.key, required this.go});

  @override
  State<WorkerOnboardingStep4Screen> createState() =>
      _WorkerOnboardingStep4ScreenState();
}

class _WorkerOnboardingStep4ScreenState
    extends State<WorkerOnboardingStep4Screen> {
  final uploaded = <String>{'Nomor WhatsApp aktif'};

  @override
  Widget build(BuildContext context) {
    const items = [
      'Upload KTP',
      'Selfie wajah',
      'Nomor WhatsApp aktif',
      'Foto contoh pekerjaan',
      'Referensi pelanggan optional',
    ];
    return _WorkerStepScaffold(
      title: 'Verifikasi untuk membangun kepercayaan',
      subtitle: 'Data ini membantu warga merasa aman saat booking layanan.',
      progress: 'Langkah 4 dari 4',
      onBack: () => widget.go('workerOnboarding3'),
      children: [
        BrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final active = uploaded.contains(item);
              return _ChecklistRow(
                title: item,
                active: active,
                showBorder: index < items.length - 1,
                onTap: () {
                  setState(() {
                    if (active) {
                      uploaded.remove(item);
                    } else {
                      uploaded.add(item);
                    }
                  });
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        const _TrustNote(
          icon: Icons.privacy_tip_outlined,
          text:
              "Data KTP tidak akan ditampilkan ke publik. Beresin hanya menampilkan status 'Identitas terverifikasi'.",
        ),
        const SizedBox(height: 18),
        BrButton(
          label: 'Kirim Pendaftaran',
          full: true,
          size: BrButtonSize.lg,
          onPressed: () => widget.go('workerSubmitted'),
        ),
      ],
    );
  }
}

class WorkerApplicationSubmittedScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const WorkerApplicationSubmittedScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    return _SimpleAuthScaffold(
      title: 'Pendaftaran Terkirim',
      subtitle:
          'Tim Beresin akan meninjau profilmu sebelum ditampilkan ke warga sekitar.',
      children: [
        BrCard(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary50,
          border: Border.all(color: AppColors.primary100),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top, color: AppColors.primaryDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menunggu verifikasi',
                      style: pj(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Estimasi: 1-2 hari kerja',
                      style: pj(fontSize: 12, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Status pendaftaran'),
        BrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _StatusStep(title: 'Profil diterima', active: true),
              _StatusStep(title: 'Dokumen dicek'),
              _StatusStep(title: 'Layanan diverifikasi'),
              _StatusStep(title: 'Profil aktif', last: true),
            ],
          ),
        ),
        const SizedBox(height: 18),
        BrButton(
          label: 'Lihat Dashboard Mitra',
          full: true,
          size: BrButtonSize.lg,
          onPressed: () => go('workerDashboard'),
        ),
        const SizedBox(height: 10),
        BrButton(
          label: 'Kembali ke Mode Customer',
          full: true,
          variant: BrButtonVariant.secondary,
          onPressed: () => go('home'),
        ),
      ],
    );
  }
}

class ExistingModeSwitchScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const ExistingModeSwitchScreen({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    return _SimpleAuthScaffold(
      title: 'Mau lanjut sebagai siapa?',
      subtitle:
          'Akun ini punya dua mode. Kamu bisa ganti lagi kapan saja dari Profil.',
      onBack: () => go('login'),
      children: [
        BrCard(
          padding: const EdgeInsets.all(13),
          color: AppColors.primary50,
          border: Border.all(color: AppColors.primary100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perilaku akun lama',
                style: pj(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              _ExistingRuleRow(
                title: 'Hanya Customer',
                subtitle: 'Setelah OTP langsung masuk ke Beranda.',
                onTap: () => go('home'),
              ),
              const Divider(color: AppColors.primary100),
              _ExistingRuleRow(
                title: 'Hanya Mitra',
                subtitle: 'Setelah OTP langsung masuk ke Dashboard Mitra.',
                onTap: () => go('workerDashboard'),
              ),
            ],
          ),
        ),
        const SectionTitle('Akun dengan dua mode'),
        _ModeCard(
          title: 'Customer Mode',
          subtitle: 'Cari dan booking layanan',
          tag: 'Terakhir digunakan: Customer',
          icon: Icons.home_outlined,
          onTap: () => go('home'),
        ),
        const SizedBox(height: 12),
        _ModeCard(
          title: 'Mitra Mode',
          subtitle: 'Kelola order dan profil tukang',
          icon: Icons.handyman_outlined,
          onTap: () => go('workerDashboard'),
        ),
      ],
    );
  }
}

class _ExistingRuleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExistingRuleRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              const Icon(
                Icons.login_rounded,
                color: AppColors.primaryDark,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pj(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: pj(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkerDashboardScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;

  const WorkerDashboardScreen({super.key, required this.go});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  bool accepting = true;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 18;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).viewPadding.top + 18,
        18,
        bottom,
      ),
      children: [
        Row(
          children: [
            const Avatar(name: 'Pak Rudi', size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Mitra',
                    style: pj(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Halo, Pak Rudi',
                    style: pj(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            _IconButton(
              icon: Icons.person_outline,
              onTap: () => widget.go('profileWorkerMode'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BrCard(
          padding: const EdgeInsets.all(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.transparent),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terima order hari ini',
                      style: pj(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      accepting
                          ? 'Profilmu tampil untuk warga sekitar.'
                          : 'Order baru sedang dijeda sementara.',
                      style: pj(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: .78),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: accepting,
                activeThumbColor: const Color(0xFFFFD89B),
                activeTrackColor: Colors.white.withValues(alpha: .28),
                onChanged: (value) => setState(() => accepting = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.45,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _DashboardMetric(value: '3', label: 'Order baru'),
            _DashboardMetric(value: '1', label: 'Order aktif'),
            _DashboardMetric(value: '4.9', label: 'Rating'),
            _DashboardMetric(value: 'Rp3,2jt', label: 'Pendapatan bulan ini'),
          ],
        ),
        const SectionTitle('Order masuk'),
        BrCard(
          padding: const EdgeInsets.all(14),
          border: Border.all(color: AppColors.accent, width: 1.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ServiceIcon(kind: 'AC', size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AC bocor - Tebet',
                          style: pj(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rp75.000-Rp150.000',
                          style: pj(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const BrTag(label: '1.2 km', color: 'accent'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Rumah pagar hitam, AC kamar utama netes sejak kemarin.',
                style: pj(fontSize: 12.5, color: AppColors.muted, height: 1.45),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BrButton(
                      label: 'Tolak',
                      full: true,
                      size: BrButtonSize.sm,
                      variant: BrButtonVariant.secondary,
                      onPressed: () =>
                          _showAuthToast(context, 'Order ditolak.'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BrButton(
                      label: 'Terima',
                      full: true,
                      size: BrButtonSize.sm,
                      onPressed: () =>
                          _showAuthToast(context, 'Order diterima.'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionTitle('Kelola mitra'),
        _DashboardMenu(
          items: [
            _DashItem(
              Icons.event_available_outlined,
              'Jadwal hari ini',
              '2 kunjungan terjadwal',
            ),
            _DashItem(
              Icons.badge_outlined,
              'Profil layanan',
              'Teknisi AC, ledeng',
            ),
            _DashItem(
              Icons.payments_outlined,
              'Harga layanan',
              'Mulai Rp80.000',
            ),
            _DashItem(
              Icons.verified_user_outlined,
              'Verifikasi',
              'Identitas terverifikasi',
            ),
            _DashItem(
              Icons.star_border_rounded,
              'Ulasan pelanggan',
              '186 ulasan warga',
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthGradientShell extends StatelessWidget {
  final Widget child;

  const _AuthGradientShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class _AuthPageScaffold extends StatelessWidget {
  final Widget top;
  final Widget child;

  const _AuthPageScaffold({required this.top, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              18,
              MediaQuery.of(context).viewPadding.top + 24,
              18,
              56,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E8E6C), Color(0xFF0A6E54)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: top,
          ),
          Transform.translate(
            offset: const Offset(0, -34),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: BrCard(padding: const EdgeInsets.all(18), child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleAuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final List<Widget> children;

  const _SimpleAuthScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom + 18;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FloatingBackScaffold(
        onBack: onBack,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            18,
            MediaQuery.of(context).viewPadding.top + (onBack != null ? 72 : 14),
            18,
            bottom,
          ),
          children: [
            Text(
              title,
              style: pj(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: pj(fontSize: 13.5, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _WorkerStepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String progress;
  final VoidCallback onBack;
  final List<Widget> children;

  const _WorkerStepScaffold({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.onBack,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return _SimpleAuthScaffold(
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      children: [
        _ProgressPill(progress),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _RepairMark extends StatelessWidget {
  final double size;

  const _RepairMark({this.size = 86});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(size * .28),
        border: Border.all(color: Colors.white.withValues(alpha: .24)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.home_rounded, color: Colors.white, size: size * .48),
          Positioned(
            right: size * .18,
            bottom: size * .18,
            child: Container(
              width: size * .34,
              height: size * .34,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD89B),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build_rounded,
                color: AppColors.ink,
                size: size * .18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String examples;
  final String cta;
  final bool recommended;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.examples,
    required this.cta,
    required this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(15),
      border: Border.all(
        color: recommended
            ? AppColors.primary
            : Colors.black.withValues(alpha: .04),
        width: recommended ? 1.4 : 1,
      ),
      color: recommended ? AppColors.primary50 : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: recommended ? Colors.white : AppColors.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: pj(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (recommended) const BrTag(label: 'Umum', color: 'success'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: pj(fontSize: 12.5, color: AppColors.ink2, height: 1.45),
          ),
          const SizedBox(height: 8),
          Text(
            examples,
            style: pj(fontSize: 11.5, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          BrButton(
            label: cta,
            full: true,
            size: BrButtonSize.sm,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? tag;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: pj(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: pj(fontSize: 12, color: AppColors.muted)),
                if (tag != null) ...[
                  const SizedBox(height: 7),
                  BrTag(label: tag!, color: 'accent'),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final String label;
  final String initial;
  final int maxLines;

  const _AuthField({
    required this.label,
    required this.initial,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      maxLines: maxLines,
      style: pj(fontSize: 13.5, color: AppColors.ink, height: 1.4),
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  const _UploadTile({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: active ? AppColors.primary50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? AppColors.primary100 : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              Icon(
                active ? Icons.check_circle : Icons.add_a_photo_outlined,
                color: active ? AppColors.primaryDark : AppColors.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pj(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: pj(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: pj(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary100,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String title;
  final bool active;
  final bool showBorder;
  final VoidCallback onTap;

  const _ChecklistRow({
    required this.title,
    required this.active,
    required this.showBorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            border: Border(
              bottom: showBorder
                  ? const BorderSide(color: AppColors.line2)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: [
              Icon(
                active ? Icons.check_circle : Icons.radio_button_unchecked,
                color: active ? AppColors.primary : AppColors.muted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: pj(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustNote extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(12),
      color: AppColors.primary50,
      border: Border.all(color: AppColors.primary100),
      boxShadow: const [],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: pj(
                fontSize: 11.8,
                color: AppColors.primaryDark,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final String label;

  const _ProgressPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BrTag(label: label, color: 'success'),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: switch (label) {
                'Langkah 1 dari 4' => .25,
                'Langkah 2 dari 4' => .5,
                'Langkah 3 dari 4' => .75,
                _ => 1,
              },
              backgroundColor: AppColors.line,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String title;
  final bool active;
  final bool last;

  const _StatusStep({
    required this.title,
    this.active = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border(
          bottom: last
              ? BorderSide.none
              : const BorderSide(color: AppColors.line2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle : Icons.radio_button_unchecked,
            color: active ? AppColors.primary : AppColors.muted,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: pj(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(icon, color: AppColors.ink, size: 22),
        ),
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final String value;
  final String label;

  const _DashboardMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: pj(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: pj(fontSize: 11.5, color: AppColors.muted, height: 1.25),
          ),
        ],
      ),
    );
  }
}

class _DashItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DashItem(this.icon, this.title, this.subtitle);
}

class _DashboardMenu extends StatelessWidget {
  final List<_DashItem> items;

  const _DashboardMenu({required this.items});

  @override
  Widget build(BuildContext context) {
    return BrCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showAuthToast(context, '${item.title} dibuka.'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index < items.length - 1
                        ? const BorderSide(color: AppColors.line2)
                        : BorderSide.none,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(item.icon, size: 17, color: AppColors.ink2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: pj(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: pj(fontSize: 11.2, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.muted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

void _showAuthToast(BuildContext context, String message) {
  final messenger = context.findAncestorStateOfType<ScaffoldMessengerState>();
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(
    SnackBar(
      content: Text(message, style: pj(color: Colors.white)),
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1500),
    ),
  );
}
