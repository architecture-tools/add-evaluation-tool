import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'services/api_config.dart';
import 'services/auth_service.dart';
import 'services/diagram_repository.dart';
import 'theme/app_theme.dart';
import 'widgets/dashboard_header.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'network/src/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConfig.configure();
  runApp(const ArchitectureEvaluationTool());
}

class ArchitectureEvaluationTool extends StatelessWidget {
  const ArchitectureEvaluationTool({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchEval - Architecture Evaluator',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final _dashboardKey = GlobalKey<DashboardScreenState>();
  late DiagramRepository _diagramRepository;
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isInitializing = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _diagramRepository = DiagramRepository();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authService.initialize();
    setState(() {
      _isAuthenticated = _authService.isAuthenticated;
      _isInitializing = false;
    });
    // Recreate repository with authenticated API client
    if (_isAuthenticated) {
      _diagramRepository = DiagramRepository();
    }
  }

  Future<void> _handleLoginSuccess() async {
    // Recreate repository with authenticated API client
    _diagramRepository = DiagramRepository();
    setState(() {
      _isAuthenticated = true;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    setState(() {
      _isAuthenticated = false;
    });
  }

  Future<void> _handleUpload(BuildContext context) async {
    if (_isUploading) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['puml', 'plantuml', 'uml', 'txt'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final pickedFile = result.files.first;
    final bytes = pickedFile.bytes;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to read selected file.')),
      );
      return;
    }

    final filename =
        pickedFile.name.isNotEmpty ? pickedFile.name : 'diagram.puml';

    setState(() {
      _isUploading = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AlertDialog(
          content: SizedBox(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading and parsing diagram...'),
              ],
            ),
          ),
        );
      },
    );

    DiagramResponse? uploadedDiagram;
    Object? failure;

    try {
      uploadedDiagram = await _diagramRepository.uploadDiagram(
        bytes: Uint8List.fromList(bytes),
        filename: filename,
        displayName: pickedFile.name,
      );

      await _diagramRepository.parseDiagram(uploadedDiagram.id);
    } catch (error) {
      failure = error;
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
        setState(() {
          _isUploading = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $failure')),
      );
      return;
    }

    if (uploadedDiagram != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Diagram "${uploadedDiagram.name}" uploaded and parsed.')),
      );
      await _dashboardKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return LoginScreen(
        authService: _authService,
        onLoginSuccess: _handleLoginSuccess,
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          DashboardHeader(
            onUpload: _handleUpload,
            onLogout: _handleLogout,
            userEmail: _authService.currentUser?.email,
          ),

          // Content area
          Expanded(
            child: DashboardScreen(
              key: _dashboardKey,
              onUpload: _handleUpload,
            ),
          ),
        ],
      ),
    );
  }
}
