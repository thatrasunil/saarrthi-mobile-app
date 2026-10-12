import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../data/local_repository.dart';
import '../../data/supabase_repository.dart';
import '../../models/alert_item.dart';
import 'darshan_screen.dart';
import 'essentials_screen.dart';
import '../widgets/skeleton_shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  final LocalRepository? localRepo;
  final SupabaseRepository? supabaseRepo;
  final Function(int)? onTabChange;

  const NotificationsScreen({
    super.key,
    this.localRepo,
    this.supabaseRepo,
    this.onTabChange,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'High Priority',
    'Advisory',
    'Information',
  ];
  bool _isLoading = false;

  Future<void> _refreshNotifications() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _isLoading = false);
  }

  void _triggerSimulatedAlert(AppState appState) {
    final isTelugu = appState.isTelugu;
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final simulated = AlertItem(
      id: 'simulated-${now.millisecondsSinceEpoch}',
      titleEn: 'Live Advisory: Additional Laddu Counters Opened',
      titleTe: 'ప్రత్యేక సమాచారం: అదనపు లడ్డూ కౌంటర్లు ప్రారంభం',
      descEn: 'TTD has opened 4 additional laddu disbursement counters near PAC-4 to reduce wait times during peak rush. Operational until 10:30 PM.',
      descTe: 'రద్దీని తగ్గించేందుకు పీఏసీ-4 వద్ద అదనంగా 4 లడ్డూ వితరణ కౌంటర్లను టీటీడీ ప్రారంభించింది. ఇవి రాత్రి 10:30 వరకు పనిచేస్తాయి.',
      category: 'Information',
      severity: 'Low',
      cta: 'Open Essentials',
      timeAgo: 'Just now ($timeStr)',
      timeAgoTe: 'ఇప్పుడే ($timeStr)',
      isRead: false,
    );

    appState.addSimulatedAlert(simulated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isTelugu
              ? 'కొత్త లైవ్ నోటిఫికేషన్ విజయవంతంగా చేర్చబడింది!'
              : 'Live simulated alert generated and delivered!',
        ),
        backgroundColor: const Color(0xFF0F5132),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleCta(String cta, BuildContext context, AppState appState) async {
    if (cta == 'Open Queue') {
      Navigator.push(
        context,
        AppTransitions.smoothSlideRoute(
          DarshanScreen(supabaseRepo: widget.supabaseRepo ?? SupabaseRepository()),
        ),
      );
    } else if (cta == 'Open Essentials') {
      if (widget.onTabChange != null) {
        widget.onTabChange!(1);
        Navigator.pop(context);
      } else {
        Navigator.push(
          context,
          AppTransitions.smoothSlideRoute(const EssentialsScreen()),
        );
      }
    } else if (cta == 'Open Maps') {
      final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=13.6833,79.3473');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appState.isTelugu
                    ? 'మ్యాప్స్ మార్గం: తిరుమల ఘాట్ రోడ్ (అలిపిరి గేట్)'
                    : 'Destination: Tirumala Ghat Road (Alipiri Toll Gate)',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isTelugu = appState.isTelugu;
        final allAlerts = appState.alerts;

        final filteredAlerts = _selectedCategory == 'All'
            ? allAlerts
            : allAlerts.where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

        final unreadCount = appState.activeAlertsCount;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F5132)),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.t('notifications'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F5132),
                  ),
                ),
                Text(
                  unreadCount > 0
                      ? (isTelugu ? '$unreadCount కొత్త నోటీసులు ఉన్నాయి' : '$unreadCount unread notices')
                      : (isTelugu ? 'అన్నీ చదివారు' : 'All caught up'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: unreadCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            actions: [
              if (unreadCount > 0)
                TextButton.icon(
                  onPressed: () => appState.markAllAlertsAsRead(),
                  icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF0F5132)),
                  label: Text(
                    appState.t('mark_all_read'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F5132),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: _isLoading
              ? const NotificationsScreenSkeleton()
              : Column(
                  children: [
              // Filter Chips Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      final count = cat == 'All'
                          ? allAlerts.length
                          : allAlerts.where((a) => a.category.toLowerCase() == cat.toLowerCase()).length;

                      String label = cat;
                      if (isTelugu) {
                        if (cat == 'All') label = appState.t('filter_all');
                        if (cat == 'High Priority') label = appState.t('filter_high');
                        if (cat == 'Advisory') label = appState.t('filter_advisory');
                        if (cat == 'Information') label = appState.t('filter_info');
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('$label ($count)'),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                          selectedColor: const Color(0xFF0F5132),
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF0F5132) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Simulation Banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 20, color: Color(0xFF0F5132)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isTelugu
                            ? 'టీటీడీ లైవ్ నోటిఫికేషన్ నమూనాను ఇక్కడ పరీక్షించండి'
                            : 'Test real-time TTD announcement delivery dynamically',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _triggerSimulatedAlert(appState),
                      icon: const Icon(Icons.notification_add_rounded, size: 14),
                      label: Text(
                        isTelugu ? 'పరీక్షించు' : 'Simulate',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5132),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List of Alerts
              Expanded(
                child: _isLoading
                    ? const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: NotificationsScreenSkeleton(),
                      )
                    : filteredAlerts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  size: 40,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                appState.t('no_notifications'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isTelugu
                                    ? 'మీ యాత్రకు అవసరమైన అన్ని తాజా సమాచారాలు ఇక్కడ కనిపిస్తాయి.'
                                    : 'Live TTD advisories, queue updates, and safety instructions will appear here.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshNotifications,
                        color: AppTheme.emerald,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filteredAlerts.length,
                          itemBuilder: (context, index) {
                            final alert = filteredAlerts[index];
                            return _buildAlertCard(context, alert, appState);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertItem alert, AppState appState) {
    final isTelugu = appState.isTelugu;
    final isHigh = alert.category.toLowerCase().contains('high') || alert.severity.toLowerCase() == 'high';
    final isAdvisory = alert.category.toLowerCase().contains('advisory') || alert.severity.toLowerCase() == 'medium';

    final Color severityColor = isHigh
        ? const Color(0xFFDC2626)
        : (isAdvisory ? const Color(0xFFD97706) : const Color(0xFF166534));

    final Color badgeBg = isHigh
        ? const Color(0xFFFEF2F2)
        : (isAdvisory ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4));

    final Color badgeBorder = isHigh
        ? const Color(0xFFFECACA)
        : (isAdvisory ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0));

    final Color badgeText = severityColor;

    final IconData categoryIcon = isHigh
        ? Icons.warning_amber_rounded
        : (isAdvisory ? Icons.info_outline_rounded : Icons.campaign_rounded);

    return Dismissible(
      key: Key('alert-${alert.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        appState.dismissAlert(alert.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isTelugu ? 'నోటీసు తీసివేయబడింది' : 'Notice dismissed'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            SizedBox(width: 6),
            Text(
              'Dismiss',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: alert.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
            width: alert.isRead ? 1 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: severityColor.withValues(alpha: alert.isRead ? 0.03 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  color: severityColor,
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => appState.markAlertAsRead(alert.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Category Badge + Timestamp + Unread Dot
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon, size: 13, color: badgeText),
                            const SizedBox(width: 4),
                            Text(
                              alert.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: badgeText,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTelugu ? alert.timeAgoTe : alert.timeAgo,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0F5132),
                            shape: BoxShape.circle,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Dismiss',
                        onPressed: () => appState.dismissAlert(alert.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    isTelugu ? alert.titleTe : alert.titleEn,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.bold,
                      color: const Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    isTelugu ? alert.descTe : alert.descEn,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.45,
                    ),
                  ),

                  // Action Button CTA if available
                  if (alert.cta != 'None') ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isTelugu ? 'ధర్మసందేహం పరిష్కారం' : 'Official Guidance',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            appState.markAlertAsRead(alert.id);
                            _handleCta(alert.cta, context, appState);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatCtaText(alert.cta, isTelugu),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F5132),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: Color(0xFF0F5132),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
),
),
);
}

  String _formatCtaText(String cta, bool isTelugu) {
    if (cta == 'Open Queue') {
      return isTelugu ? 'క్యూ లైవ్ స్టేటస్ చూడండి' : 'Open Queue Status';
    }
    if (cta == 'Open Essentials') {
      return isTelugu ? 'అవసరాల వివరాలు తెరవండి' : 'Open Essentials Guide';
    }
    if (cta == 'Open Maps') {
      return isTelugu ? 'ఘాట్ రోడ్డు మార్గం చూడండి' : 'Open Ghat Navigation';
    }
    return cta;
  }
}
