import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const TNPSCNovaAI());
}

class TNPSCNovaAI extends StatelessWidget {
  const TNPSCNovaAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TNPSC Nova AI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _applyAuthInputContrast(),
        ),
      )
      ..loadRequest(Uri.parse('https://tnpsc-ai.streamlit.app'));
  }

  Future<void> _applyAuthInputContrast() async {
    await controller.runJavaScript(r'''
      (function () {
        if (!document.getElementById('tnpsc-auth-contrast-style')) {
          const style = document.createElement('style');
          style.id = 'tnpsc-auth-contrast-style';
          style.textContent = `
            body.tnpsc-auth-contrast-active input,
            body.tnpsc-auth-contrast-active textarea,
            body.tnpsc-auth-contrast-active [contenteditable="true"] {
              background: #FFFFFF !important;
              color: #111827 !important;
              -webkit-text-fill-color: #111827 !important;
              caret-color: #000000 !important;
              border: 1px solid #2563EB !important;
              border-radius: 10px !important;
              box-shadow: none !important;
            }

            body.tnpsc-auth-contrast-active input::placeholder,
            body.tnpsc-auth-contrast-active textarea::placeholder {
              color: #6B7280 !important;
              opacity: 1 !important;
              -webkit-text-fill-color: #6B7280 !important;
            }

            body.tnpsc-auth-contrast-active label,
            body.tnpsc-auth-contrast-active label *,
            body.tnpsc-auth-contrast-active div[data-testid="stTextInput"] label,
            body.tnpsc-auth-contrast-active div[data-testid="stTextInput"] label *,
            body.tnpsc-auth-contrast-active div[data-testid="stTextArea"] label,
            body.tnpsc-auth-contrast-active div[data-testid="stTextArea"] label * {
              color: #FFFFFF !important;
              -webkit-text-fill-color: #FFFFFF !important;
            }

            body.tnpsc-auth-contrast-active button,
            body.tnpsc-auth-contrast-active button *,
            body.tnpsc-auth-contrast-active div[data-testid="stButton"] button,
            body.tnpsc-auth-contrast-active div[data-testid="stButton"] button * {
              color: #FFFFFF !important;
              -webkit-text-fill-color: #FFFFFF !important;
            }

            body.tnpsc-auth-contrast-active div[data-testid="stButton"] button,
            body.tnpsc-auth-contrast-active button[kind="primary"] {
              background-color: #2563EB !important;
              border-color: #1D4ED8 !important;
            }
          `;
          document.head.appendChild(style);
        }

        const syncAuthContrast = function () {
          const text = (document.body.innerText || '').toLowerCase();
          const hasPasswordInput = Boolean(
            document.querySelector('input[type="password"]')
          );
          const hasAuthCopy =
            /\blog\s*in\b/.test(text) ||
            /\bsign\s*up\b/.test(text) ||
            /\bsignup\b/.test(text) ||
            /\bregister\b/.test(text);

          document.body.classList.toggle(
            'tnpsc-auth-contrast-active',
            hasPasswordInput && hasAuthCopy
          );
        };

        syncAuthContrast();

        if (!window.tnpscAuthContrastObserver) {
          window.tnpscAuthContrastObserver = new MutationObserver(syncAuthContrast);
          window.tnpscAuthContrastObserver.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['type', 'placeholder', 'style', 'class'],
          });
        }
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
