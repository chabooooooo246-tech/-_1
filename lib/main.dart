import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const InsanApp());
}

// ============================================================
// إنسان - تطبيق محادثة عربي
// نسخة تجريبية كاملة بملف واحد
// ============================================================

class InsanApp extends StatefulWidget {
  const InsanApp({super.key});

  @override
  State<InsanApp> createState() => _InsanAppState();
}

class _InsanAppState extends State<InsanApp> {
  bool darkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إنسان',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'sans',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(
          darkMode: darkMode,
          onThemeChanged: (value) {
            setState(() {
              darkMode = value;
            });
          },
        ),
      ),
    );
  }
}

// ============================================================
// نموذج الرسالة
// ============================================================

class ChatMessage {
  final String text;
  final bool fromMe;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.fromMe,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

// ============================================================
// الصفحة الرئيسية
// ============================================================

class HomePage extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String currentContact = 'كرار';
  bool isTyping = false;
  bool searching = false;

  final List<String> contacts = [
    'كرار',
    'محمد',
  ];

  final Map<String, List<ChatMessage>> chats = {
    'كرار': [
      ChatMessage(
        text: 'هلا بيك 👋',
        fromMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        text: 'شلونك؟ شنو أخبارك؟',
        fromMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
    ],
    'محمد': [
      ChatMessage(
        text: 'هلا والله 🌹',
        fromMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ],
  };

  List<ChatMessage> get currentMessages => chats[currentContact] ?? [];

  @override
  void dispose() {
    messageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      currentMessages.add(
        ChatMessage(
          text: text,
          fromMe: true,
        ),
      );

      messageController.clear();
      isTyping = true;
    });

    // رد تجريبي حتى نربطه بالذكاء الاصطناعي لاحقًا
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      String reply = generateDemoReply(text);

      setState(() {
        isTyping = false;

        currentMessages.add(
          ChatMessage(
            text: reply,
            fromMe: false,
          ),
        );
      });
    });
  }

  String generateDemoReply(String text) {
    final lower = text.toLowerCase();

    if (text.contains('هلا') || text.contains('سلام')) {
      return 'هلا وغلا بيك ❤️';
    }

    if (text.contains('شلونك') || text.contains('كيفك')) {
      return 'تمام الحمدلله 😄 إنت شلونك؟';
    }

    if (text.contains('منو انت') || text.contains('من أنت')) {
      return 'أنا إنسان 🤖، مساعدك داخل التطبيق.';
    }

    if (text.contains('كرة') || text.contains('فوتبول')) {
      return 'أحب أحچي وياك عن كرة القدم ⚽🔥';
    }

    if (lower.contains('hello')) {
      return 'Hello! 👋';
    }

    return 'وصلتني رسالتك: "$text"\n\nهذا رد تجريبي من إنسان 🤖';
  }

  void changeContact(String name) {
    setState(() {
      currentContact = name;
      isTyping = false;
    });

    Navigator.pop(context);
  }

  void clearChat() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف المحادثة'),
          content: const Text(
            'هل تريد حذف جميع رسائل هذه المحادثة؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  currentMessages.clear();
                });
                Navigator.pop(context);
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          darkMode: widget.darkMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  void showAISettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AISettingsPage(),
      ),
    );
  }

  void showCustomInstructions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomInstructionsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: currentMessages.isEmpty
                ? buildEmptyChat()
                : buildMessages(),
          ),
          if (isTyping) buildTypingIndicator(),
          buildMessageInput(),
        ],
      ),
    );
  }

  // ==========================================================
  // الشريط العلوي
  // ==========================================================

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: Colors.blue,
            child: Text(
              currentContact.isNotEmpty ? currentContact[0] : 'إ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentContact,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isTyping ? 'يكتب...' : 'متصل الآن',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'بحث',
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              searching = !searching;
            });
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'clear') {
              clearChat();
            }

            if (value == 'info') {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(currentContact),
                  content: const Text(
                    'جهة اتصال داخل تطبيق إنسان.\n\nالحالة: متصل الآن',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 10),
                  Text('معلومات'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 10),
                  Text('حذف المحادثة'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // القائمة الجانبية
  // ==========================================================

  Widget buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.blue,
                    child: const Text(
                      'إ',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'إنسان',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'تطبيق محادثة ذكي',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('المحادثات'),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('جهات الاتصال'),
              onTap: () {
                Navigator.pop(context);

                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView(
                        shrinkWrap: true,
                        children: contacts.map((name) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(name[0]),
                            ),
                            title: Text(name),
                            subtitle: const Text('متصل الآن'),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                currentContact = name;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('إعدادات الذكاء الاصطناعي'),
              onTap: () {
                Navigator.pop(context);
                showAISettings();
              },
            ),

            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('التعليمات المخصصة'),
              onTap: () {
                Navigator.pop(context);
                showCustomInstructions();
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('الإعدادات'),
              onTap: () {
                Navigator.pop(context);
                showSettings();
              },
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('حول إنسان'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'إنسان',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'تطبيق تجريبي',
                  children: const [
                    SizedBox(height: 15),
                    Text(
                      'إنسان هو تطبيق محادثة عربي يتم تطويره باستخدام Flutter.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // شاشة عدم وجود رسائل
  // ==========================================================

  Widget buildEmptyChat() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                size: 45,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ابدأ المحادثة',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أرسل رسالة إلى $currentContact',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // الرسائل
  // ==========================================================

  Widget buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 15),
      reverse: false,
      itemCount: currentMessages.length,
      itemBuilder: (context, index) {
        final message = currentMessages[index];

        return MessageBubble(
          message: message,
          onCopy: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديد الرسالة للنسخ'),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // مؤشر الكتابة
  // ==========================================================

  Widget buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(
          right: 14,
          bottom: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'يكتب...  •••',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // مربع إرسال الرسائل
  // ==========================================================

  Widget buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Wrap(
                            spacing: 25,
                            runSpacing: 20,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.image),
                                label: const Text('صورة'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.videocam),
                                label: const Text('فيديو'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.insert_drive_file),
                                label: const Text('ملف'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            Expanded(
              child: TextField(
                controller: messageController,
                textDirection: TextDirection.rtl,
                minLines: 1,
                maxLines: 5,
                onSubmitted: (_) => sendMessage(),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            FloatingActionButton.small(
              heroTag: 'send',
              onPressed: sendMessage,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// فقاعة الرسالة
// ============================================================

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onCopy;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onCopy,
  });

  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.fromMe ? Alignment.centerLeft : Alignment.centerRight;

    final color = message.fromMe
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    final textColor =
        message.fromMe ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onLongPress: onCopy,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .78,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(13, 9, 13, 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(
                message.fromMe ? 18 : 4,
              ),
              bottomRight: Radius.circular(
                message.fromMe ? 4 : 18,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                formatTime(message.time),
                style: TextStyle(
                  color: message.fromMe
                      ? Colors.white70
                      : Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// إعدادات التطبيق
// ============================================================

class SettingsPage extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPage({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool notifications;
  late bool sounds;

  @override
  void initState() {
    super.initState();
    notifications = true;
    sounds = true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
        ),
        body: ListView(
          children: [
            const SectionTitle(title: 'المظهر'),

            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('الوضع الداكن'),
              subtitle: const Text('تغيير مظهر التطبيق'),
              value: widget.darkMode,
              onChanged: widget.onThemeChanged,
            ),

            const Divider(),

            const SectionTitle(title: 'الإشعارات'),

            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('الإشعارات'),
              value: notifications,
              onChanged: (value) {
                setState(() {
                  notifications = value;
                });
              },
            ),

            SwitchListTile(
              secondary: const Icon(Icons.volume_up_outlined),
              title: const Text('أصوات الرسائل'),
              value: sounds,
              onChanged: (value) {
                setState(() {
                  sounds = value;
                });
              },
            ),

            const Divider(),

            const SectionTitle(title: 'التطبيق'),

            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('اللغة'),
              subtitle: const Text('العربية'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('البيانات والتخزين'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('الخصوصية والأمان'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('عن التطبيق'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'إنسان',
                  applicationVersion: '1.0.0',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// إعدادات الذكاء الاصطناعي
// ============================================================

class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  final TextEditingController apiController = TextEditingController();

  bool enabled = true;
  bool saveKey = true;

  @override
  void dispose() {
    apiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الذكاء الاصطناعي'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 55,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'مساعد إنسان',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'إعدادات الذكاء الاصطناعي',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text('تفعيل الذكاء الاصطناعي'),
              value: enabled,
              onChanged: (value) {
                setState(() {
                  enabled = value;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: apiController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'مفتاح API',
                hintText: 'ضع المفتاح هنا',
                prefixIcon: const Icon(Icons.key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            SwitchListTile(
              title: const Text('حفظ المفتاح'),
              subtitle: const Text(
                'سيتم استخدامه لاحقًا للاتصال بخدمة الذكاء الاصطناعي',
              ),
              value: saveKey,
              onChanged: (value) {
                setState(() {
                  saveKey = value;
                });
              },
            ),

            const SizedBox(height: 15),

            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حفظ الإعدادات'),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
            ),

            const SizedBox(height: 20),

            const Text(
              'ملاحظة: الاتصال الحقيقي بالذكاء الاصطناعي يحتاج إضافة طلب API مناسب. هذه الصفحة حاليًا واجهة إعداد فقط.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// التعليمات المخصصة
// ============================================================

class CustomInstructionsPage extends StatefulWidget {
  const CustomInstructionsPage({super.key});

  @override
  State<CustomInstructionsPage> createState() =>
      _CustomInstructionsPageState();
}

class _CustomInstructionsPageState
    extends State<CustomInstructionsPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التعليمات المخصصة'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Text(
                'اكتب كيف تريد من المساعد أن يتصرف أثناء المحادثة.',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText:
                        'مثال:\nاحچي وياي باللهجة العراقية وبشكل مختصر...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حفظ التعليمات'),
                      ),
                    );
                  },
                  child: const Text('حفظ التعليمات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// عنوان الأقسام
// ============================================================

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}