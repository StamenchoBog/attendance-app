import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:attendance_app/data/services/auth_service.dart';
import 'package:attendance_app/data/models/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';

class CasLoginScreen extends StatefulWidget {
  final Function(User) onLoginSuccess;
  
  const CasLoginScreen({super.key, required this.onLoginSuccess});
  
  @override
  _CasLoginScreenState createState() => _CasLoginScreenState();
}

class _CasLoginScreenState extends State<CasLoginScreen> {
  final AuthService _authService = AuthService();
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
    
    _controller = WebViewController()
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
        throw Exception('No ticket found in the response');
      }
      
      // Validate ticket with backend
      final user = await _authService.validateTicket(ticket);
      
      // Store user in provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUser(user);
      
      // Call success callback
      widget.onLoginSuccess(user);
      
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('University Login'),
        backgroundColor: ColorPalette.darkBlue,
      ),
      body: Stack(
        children: [
          // WebView for CAS authentication
          WebViewWidget(controller: _controller),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white70,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: ColorPalette.darkBlue,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Connecting to university login...',
                      style: TextStyle(fontSize: 14.sp),
                    )
                  ],
                ),
              ),
            ),
            
          // Error message
          if (_errorMessage != null)
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20.w),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.darkBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _controller.reload();
                        });
                      },
                      child: Text('Try Again'),
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