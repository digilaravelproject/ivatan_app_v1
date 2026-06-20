import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String url;

  const PaymentWebViewPage({super.key, required this.url});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            
            if (url.contains("/payment/callback/phonepe")) {
              final uri = Uri.tryParse(url);
              if (uri != null) {
                final code = uri.queryParameters['code'];
                if (code == 'PAYMENT_SUCCESS') {
                  debugPrint("WebView URL indicates successful payment callback: $url");
                  Navigator.of(context).pop(true);
                  return;
                } else if (code == 'PAYMENT_ERROR') {
                  debugPrint("WebView URL indicates failed payment callback: $url");
                  Navigator.of(context).pop(false);
                  return;
                }
              }

              // Fallback: Try extracting the body text to see if payment succeeded/failed
              try {
                final dynamic result = await _controller.runJavaScriptReturningResult("document.body.innerText");
                final String content = result.toString().replaceAll('"', '').trim();
                
                debugPrint("WebView content check: $content");
                
                if (content.contains("Payment Successful")) {
                  Navigator.of(context).pop(true);
                } else if (content.contains("Payment Failed")) {
                  // Double check if the URL code was SUCCESS (in case of DB delay)
                  if (url.contains("code=PAYMENT_SUCCESS")) {
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(context).pop(false);
                  }
                }
              } catch (e) {
                debugPrint("Error extracting body text: $e");
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            debugPrint("WebView navigating to: $url");
            
            if (url.startsWith("upi:") || 
                url.startsWith("phonepe:") || 
                url.startsWith("paytm:") || 
                url.startsWith("gpay:") ||
                url.startsWith("tez:")) {
              try {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint("Could not launch payment URI: $url");
                }
              } catch (e) {
                debugPrint("Error launching payment URI: $e");
              }
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Secure Payment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(null); // Cancelled
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
