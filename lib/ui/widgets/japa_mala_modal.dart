import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_state.dart';

class JapaMalaModal extends StatefulWidget {
  final VoidCallback? onClose;

  const JapaMalaModal({super.key, this.onClose});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const JapaMalaModal(),
    );
  }

  @override
  State<JapaMalaModal> createState() => _JapaMalaModalState();
}

class _JapaMalaModalState extends State<JapaMalaModal> {
  final AppState _appState = AppState.instance;
  List<Map<String, dynamic>> _namavali = [];
  bool _isSoundEnabled = true;
  late int _activeBead;

  @override
  void initState() {
    super.initState();
    _activeBead = _appState.japaCount;
    _loadNamavali();
  }

  Future<void> _loadNamavali() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/govinda_namas.json');
      final list = json.decode(jsonStr) as List;
      if (mounted) {
        setState(() {
          _namavali = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (_) {
      // Fallback first few names if asset not yet bundled
      if (mounted) {
        setState(() {
          _namavali = [
            {
              "namaTe": "ఓం వేంకటేశాయ నమః",
              "namaEn": "Om Venkateshaya Namaha (Lord of Venkatadri who dispels all sins)",
              "blessingTe": "పాపాలను పరిహరించే శ్రీ వేంకటేశ్వరుని దివ్య నామస్మరణతో మీ సర్వ దోషాలు తొలగి, జీవితంలో దివ్య శాంతి వెల్లివిరియుగాక.",
              "blessingEn": "May Lord Venkateswara, the dispeller of all sins, remove every adversity and bless your life with divine serenity.",
            }
          ];
        });
      }
    }
  }

  void _onChantTap() {
    HapticFeedback.lightImpact();
    _appState.incrementJapa();
    setState(() {
      _activeBead = _appState.japaCount;
    });
  }

  void _onStep(int delta) {
    HapticFeedback.selectionClick();
    int next = _activeBead + delta;
    if (next < 1) next = 108;
    if (next > 108) next = 1;
    setState(() {
      _activeBead = next;
    });
    _appState.setJapaCount(next);
  }

  Map<String, dynamic> _getCurrentNama() {
    if (_namavali.isEmpty) {
      return {
        "namaTe": "ఓం వేంకటేశాయ నమః",
        "namaEn": "Om Venkateshaya Namaha (Lord of Venkatadri who dispels all sins)",
        "blessingTe": "పాపాలను పరిహరించే శ్రీ వేంకటేశ్వరుని దివ్య నామస్మరణతో మీ సర్వ దోషాలు తొలగి, జీవితంలో దివ్య శాంతి వెల్లివిరియుగాక.",
        "blessingEn": "May Lord Venkateswara, the dispeller of all sins, remove every adversity and bless your life with divine serenity.",
      };
    }
    final index = (_activeBead - 1) % _namavali.length;
    return _namavali[index];
  }

  @override
  Widget build(BuildContext context) {
    final nama = _getCurrentNama();
    final percent = ((_activeBead / 108.0) * 100).round();

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                // Tirunamam Emblem
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFC89B3C).withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(20, 24),
                      painter: _NamamPainter(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'SRIVARI 108 SACRED JAPA MALA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFDE68A),
                          letterSpacing: 0.5,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sacred Devotional Chanting Sadhana',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Audio Toggle
                InkWell(
                  onTap: () {
                    setState(() => _isSoundEnabled = !_isSoundEnabled);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Icon(
                      _isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      size: 16,
                      color: const Color(0xFFFDE68A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Close Button
                InkWell(
                  onTap: () {
                    if (widget.onClose != null) widget.onClose!();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Bead Track Line
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Golden Guideline
                Container(
                  height: 2,
                  color: const Color(0xFFB45309).withValues(alpha: 0.4),
                ),
                // Bead sequence
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTrackBead((_activeBead - 3) > 0 ? _activeBead - 3 : _activeBead - 3 + 108, false),
                    const SizedBox(width: 8),
                    _buildTrackBead((_activeBead - 2) > 0 ? _activeBead - 2 : _activeBead - 2 + 108, false),
                    const SizedBox(width: 8),
                    _buildTrackBead((_activeBead - 1) > 0 ? _activeBead - 1 : _activeBead - 1 + 108, false),
                    const SizedBox(width: 12),
                    // Active Glowing Sphere
                    _buildActiveSphere(_activeBead),
                    const SizedBox(width: 12),
                    _buildTrackBead((_activeBead + 1) <= 108 ? _activeBead + 1 : _activeBead + 1 - 108, false),
                    const SizedBox(width: 8),
                    _buildTrackBead((_activeBead + 2) <= 108 ? _activeBead + 2 : _activeBead + 2 - 108, false),
                    const SizedBox(width: 8),
                    _buildTrackBead((_activeBead + 3) <= 108 ? _activeBead + 3 : _activeBead + 3 - 108, false),
                  ],
                ),
              ],
            ),
          ),

          // Central Devotional Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 0.9,
                    colors: [
                      Color(0xFF1E293B),
                      Color(0xFF0F172A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFC89B3C).withValues(alpha: 0.35), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC89B3C).withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Step navigation & Bead Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => _onStep(-1),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155).withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 20),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF78350F).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                            ),
                            child: Text(
                              'BEAD #$_activeBead OF 108',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFDE68A),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _onStep(1),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155).withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Main Telugu Sacred Name
                      Text(
                        nama['namaTe'] ?? 'ఓం వేంకటేశాయ నమః',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.2,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Transliteration & Meaning
                      Text(
                        nama['namaEn'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFCBD5E1),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sacred Triple Glyphs (Conch, Namam, Chakra)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 1,
                            color: const Color(0xFFC89B3C).withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.wb_sunny_rounded, size: 16, color: Color(0xFFFEF3C7)),
                          const SizedBox(width: 8),
                          CustomPaint(
                            size: const Size(16, 20),
                            painter: _NamamPainter(),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.brightness_medium_rounded, size: 16, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          Container(
                            width: 30,
                            height: 1,
                            color: const Color(0xFFC89B3C).withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Divine Blessing Heading
                      const Text(
                        'DIVINE BLESSING & GRACE:',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFDE68A),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Telugu Blessing
                      Text(
                        '"${nama['blessingTe'] ?? ''}"',
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF8FAFC),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // English Translation
                      Text(
                        '"${nama['blessingEn'] ?? ''}"',
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF94A3B8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Mala Progress & Chant Trigger
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                // Progress labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mala Progress: $_activeBead/ 108 Beads',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFDE68A),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFDE68A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Linear Gold Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _activeBead / 108.0,
                    minHeight: 5,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE9801D)),
                  ),
                ),
                const SizedBox(height: 14),

                // Primary Chant Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _onChantTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFFFDE68A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFC89B3C), width: 1.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFFFDE68A)),
                        SizedBox(width: 8),
                        Text(
                          'Tap, Swipe, or Press Spacebar to Chant',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackBead(int number, bool isActive) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSphere(int number) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.3),
          radius: 0.8,
          colors: [
            Color(0xFFFEF08A),
            Color(0xFFD97706),
            Color(0xFF78350F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: const Color(0xFFFFFBEB), width: 1.5),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NamamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final redPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // White 'U' Namam
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.1);
    path.lineTo(size.width * 0.15, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.95,
      size.width * 0.85,
      size.height * 0.65,
    );
    path.lineTo(size.width * 0.85, size.height * 0.1);
    canvas.drawPath(path, whitePaint);

    // Red center line (Kasturi / Tilakam)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.5, size.height * 0.75),
      redPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
