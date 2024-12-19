import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ログイン画面',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: true, // デバッグバナーを非表示
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;  // ローディング中フラグ
  String? _errorMessage;    // エラーメッセージ
  
  Future<void> _login() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    
    // 入力検証 (例: 空チェック)
    if (code.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '行政コードとパスワードを入力してください';
      });
      return;
    }
    // if entered rokafox, rokafox, then it will be successful
    // REMOVE THIS IN PRODUCTION
    if (code == 'rokafox' && password == 'rokafox') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NextPage()),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // ここで実際のAPIエンドポイントを指定
      // final url = Uri.parse('https://example.com/login');
      // use a local server for testing
      final url = Uri.parse('http://localhost:8000/login');  
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        // 例: {"success": true, "token": "xxxxxx"} など
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // ログイン成功時は次の画面へ遷移
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NextPage()),
          );
        } else {
          setState(() {
            _errorMessage = 'ログインに失敗しました。コードまたはパスワードを確認してください。';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'サーバーエラーが発生しました。しばらくお待ちください。';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ネットワークエラーが発生しました。接続を確認してください。';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('ログイン画面'),
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      // ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 300, // フォームの幅
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black), // 外枠の線
              borderRadius: BorderRadius.circular(8), // 角を丸くする
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ログイン',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // 行政コード入力欄
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '行政コード',
                  ),
                ),
                const SizedBox(height: 20),
                // パスワード入力欄
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'パスワード',
                  ),
                ),
                const SizedBox(height: 20),
                // エラーメッセージ表示欄
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                ],
                // ローディング中はプログレスインジケータを表示
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('ログイン'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum DisasterType {
  fire('火災'),
  forestFire('山火事'),
  earthquake('地震'),
  sinkhole('地盤沈下'),
  earthstrike('土砂災害'),
  tsunami('津波'),
  flood('洪水'),
  typhoon('台風'),
  tornado('竜巻'),
  heavyRain('豪雨'),
  heavySnow('大雪'),
  volcanicEruption('火山噴火'),
  humanerror('人為事故'),
  bearassault('熊襲撃'),
  militaryattack('軍事'),
  other('その他');

  final String label;
  const DisasterType(this.label);
}

class NextPage extends StatefulWidget {
  const NextPage({super.key});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  int _selectedIndex = 0;

  // 入力値を保持する変数
  DisasterType? _selectedDisaster;
  String _description = '';
  bool _isImportant = false;
  File? _selectedImage;


  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web環境なら、Web対応のパッケージで処理
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        // Webの場合、pathがnullの場合はbytesから画像を扱うなど別途処理が必要
      }
    } else {
      // WebではないのでPlatform判定可能
      if (Platform.isAndroid || Platform.isIOS) {
        // モバイルはimage_pickerを使用
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      } else {
        // デスクトップ(Windows/Linux/macOS)用
        final result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _selectedImage = File(result.files.first.path!);
          });
        }
      }
    }
  }


  Widget _buildReportForm() {
    // DisasterType用のDropdownMenuEntryを作成
    final List<DropdownMenuEntry<DisasterType>> disasterEntries = DisasterType.values
        .map((d) => DropdownMenuEntry<DisasterType>(value: d, label: d.label))
        .toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 災害タイプ選択ドロップダウン
          DropdownMenu<DisasterType>(
            width: double.infinity,
            label: const Text('どんな災害ですか？'),
            dropdownMenuEntries: disasterEntries,
            onSelected: (DisasterType? disaster) {
              setState(() {
                _selectedDisaster = disaster;
              });
            },
          ),
          const SizedBox(height: 16),
          // 説明用テキストフィールド（複数行）
          TextFormField(
            decoration: const InputDecoration(
              labelText: '詳細情報を教えてくれませんか？',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            onChanged: (value) {
              setState(() {
                _description = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // 重要チェックボックス
          CheckboxListTile(
            title: const Text('急を要する案件です。'),
            value: _isImportant,
            onChanged: (value) {
              setState(() {
                _isImportant = value ?? false;
              });
            },
          ),
          const SizedBox(height: 16),
          // 画像アップロードボタンとプレビュー
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('画像を選択'),
              ),
              const SizedBox(width: 16),
              _selectedImage == null
                  ? const Text('画像が選択されていません')
                  : Row(
                      children: [
                        Image.file(
                          _selectedImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ],
                    ),
            ],
          ),
          const SizedBox(height: 16),
          // 送信ボタン
          ElevatedButton(
            onPressed: () {
              // ここで実際の送信処理を記述
              // 例: APIへPOST、バリデーションチェックなど
              // 簡易的に入力値を確認表示するなど
              debugPrint('Disaster: $_selectedDisaster');
              debugPrint('Description: $_description');
              debugPrint('Is Important: $_isImportant');
              debugPrint('Image: $_selectedImage');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('報告を送信しました。')),
              );
            },
            child: const Text('送信'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        // 災害情報報告用フォームを返す
        return _buildReportForm();
      case 1:
        return const Center(child: Text('報告一覧'));
      default:
        return const Center(child: Text('不明な画面'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FBDR - Federal Bureau of Disaster Response'),
      ),
      body: _buildPageContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report),
            label: '災害情報報告',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '報告一覧',
          ),
        ],
      ),
    );
  }
}
