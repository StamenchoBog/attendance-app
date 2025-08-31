import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:attendance_app/data/services/auth_service.dart';
import 'package:attendance_app/data/models/user.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/core/services/permission_service.dart';
import 'package:logger/logger.dart';

class CasLoginScreen extends StatefulWidget {
  final Function(User) onLoginSuccess;

  const CasLoginScreen({super.key, required this.onLoginSuccess});

  @override
  _CasLoginScreenState createState() => _CasLoginScreenState();
}

class _CasLoginScreenState extends State<CasLoginScreen> {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();
  bool _isLoading = true;
  String? _errorMessage;
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    final String casLoginUrl = '${dotenv.env['CAS_URL'] ?? ''}/login?service=${dotenv.env['SERVICE_URL'] ?? ''}';

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
              onNavigationRequest: (NavigationRequest request) {
                // Check if it's the redirect URL with the ticket
                if (request.url.startsWith(dotenv.env['SERVICE_URL'] ?? '')) {
                  _handleRedirect(request.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(casLoginUrl));
  }

  Future<void> _handleRedirect(String url) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final Uri uri = Uri.parse(url);
      final ticket = uri.queryParameters['ticket'];

      if (ticket == null) {
        throw AuthenticationException('Authentication failed: No authentication ticket received.');
      }

      _logger.i('Validating authentication ticket...');

      // Validate ticket with backend
      final user = await _authService.validateTicket(ticket);

      _logger.i('Authentication successful for user: ${user.email}');

      // Check permissions before proceeding
      _logger.i('Checking required permissions after successful login...');
      final permissionsGranted = await PermissionService.arePermissionsGranted();

      if (!permissionsGranted) {
        _logger.i('Permissions not granted, requesting permissions...');
        final granted = await PermissionService.requestInitialPermissions(context);

        if (!granted) {
          _logger.w('User denied permissions after login');
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Permissions are required for the app to function properly. Please grant the required permissions to continue.';
          });
          return;
        }
      }

      // Store user in provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUser(user);

      // Call success callback
      widget.onLoginSuccess(user);
    } on AuthenticationException catch (e) {
      _logger.e('Authentication error: ${e.message}');
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      _logger.e('Unexpected error during authentication: $e');
      // Use ErrorHandler to get appropriate error message
      final errorMessage = ErrorHandler.getErrorMessage(e);
      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'University Login',
          style: AppTextStyles.heading3.copyWith(color: ColorPalette.pureWhite, fontWeight: FontWeight.w600),
        ),
        backgroundColor: ColorPalette.darkBlue,
        foregroundColor: ColorPalette.pureWhite,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // WebView for CAS authentication
          WebViewWidget(controller: _controller),

          // Loading indicator
          if (_isLoading)
            Container(
              color: ColorPalette.pureWhite.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: ColorPalette.darkBlue),
                    UIHelpers.verticalSpace(AppConstants.spacing16),
                    Text(
                      'Connecting to university login...',
                      style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textPrimary),
                    ),
                  ],
                ),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Container(
              color: ColorPalette.pureWhite,
              padding: EdgeInsets.all(AppConstants.spacing20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: ColorPalette.errorColor, size: AppConstants.iconSizeXLarge),
                    UIHelpers.verticalSpace(AppConstants.spacing16),
                    Text(
                      'Authentication Failed',
                      style: AppTextStyles.heading3.copyWith(
                        color: ColorPalette.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    UIHelpers.verticalSpace(AppConstants.spacing8),
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    UIHelpers.verticalSpace(AppConstants.spacing24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.buttonBackgroundLight,
                              foregroundColor: ColorPalette.textPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Go Back',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        UIHelpers.horizontalSpace(AppConstants.spacing12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.darkBlue,
                              foregroundColor: ColorPalette.pureWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                                _controller.reload();
                              });
                            },
                            child: Text(
                              'Try Again',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
