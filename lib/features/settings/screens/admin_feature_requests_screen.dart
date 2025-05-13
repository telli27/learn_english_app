import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/utils/constants/colors.dart';
import '../providers/feature_request_provider.dart';
import '../models/feature_request.dart';
import 'package:intl/intl.dart';

class AdminFeatureRequestsScreen extends ConsumerStatefulWidget {
  const AdminFeatureRequestsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminFeatureRequestsScreen> createState() =>
      _AdminFeatureRequestsScreenState();
}

class _AdminFeatureRequestsScreenState
    extends ConsumerState<AdminFeatureRequestsScreen> {
  FeatureRequest? _selectedRequest;
  String? _adminNotes;
  FeatureRequestStatus? _selectedStatus;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Schedule a refresh of the isAdmin status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will force the isAdminProvider to refresh
      ref.refresh(isAdminProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final isAdminAsync = ref.watch(isAdminProvider);
    final requestsAsyncValue = ref.watch(allFeatureRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özellik İstekleri Yönetimi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isAdminAsync.when(
        data: (isAdmin) {
          if (!isAdmin) {
            return _buildNotAdminView(isDark);
          }

          return Column(
            children: [
              // Admin badge
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.green.withOpacity(0.1),
                child: Center(
                  child: Text(
                    'YÖNETİCİ MODU',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ),

              // Ana içerik
              Expanded(
                child: requestsAsyncValue.when(
                  data: (requests) {
                    if (requests.isEmpty) {
                      return _buildEmptyState(isDark);
                    }
                    return _buildRequestsList(context, requests, isDark);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Bir hata oluştu: $error',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Bir hata oluştu: $error',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotAdminView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'Yetkisiz Erişim',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu sayfaya erişim yetkiniz bulunmamaktadır. Sadece yöneticiler bu sayfaya erişebilir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Geri Dön',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 70,
            color:
                isDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Henüz özellik isteği bulunmamaktadır',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? Colors.white.withOpacity(0.7) : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Kullanıcılar özellik isteği gönderdiğinde burada görünecektir',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color:
                  isDark ? Colors.white.withOpacity(0.5) : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
      BuildContext context, List<FeatureRequest> requests, bool isDark) {
    final dateFormatter = DateFormat('dd.MM.yyyy');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        Color statusColor;

        // Set status color based on status
        switch (request.status) {
          case FeatureRequestStatus.onaylandi:
            statusColor = Colors.blue;
            break;
          case FeatureRequestStatus.gelistiriliyor:
            statusColor = Colors.deepPurple;
            break;
          case FeatureRequestStatus.tamamlandi:
            statusColor = Colors.green;
            break;
          case FeatureRequestStatus.reddedildi:
            statusColor = Colors.red;
            break;
          case FeatureRequestStatus.inceleniyor:
          default:
            statusColor = Colors.orange;
            break;
        }

        return Card(
          elevation: 0,
          color: isDark ? const Color(0xFF242424) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              _showUpdateStatusDialog(context, request, isDark);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kullanıcı: ${request.username}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          request.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Request Text
                  Text(
                    request.requestText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tarih: ${dateFormatter.format(request.createdAt)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (request.updatedAt != null)
                        Text(
                          'Güncelleme: ${dateFormatter.format(request.updatedAt!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),

                  // Admin Notes
                  if (request.adminNotes != null &&
                      request.adminNotes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Notu:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.adminNotes!,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black87.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Edit button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        _showUpdateStatusDialog(context, request, isDark);
                      },
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Durum Güncelle'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpdateStatusDialog(
      BuildContext context, FeatureRequest request, bool isDark) {
    _selectedRequest = request;
    _selectedStatus = request.status;
    _adminNotes = request.adminNotes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Özellik İsteği Durumunu Güncelle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İstek:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(request.requestText),
                  const SizedBox(height: 16),
                  Text(
                    'Durum:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<FeatureRequestStatus>(
                        value: _selectedStatus,
                        isExpanded: true,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                        items: FeatureRequestStatus.values
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.displayName),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Admin Notu:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı için bir not ekleyin (isteğe bağlı)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                    controller: TextEditingController(text: _adminNotes),
                    onChanged: (value) {
                      _adminNotes = value;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('İptal'),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });

                        try {
                          final success = await ref
                              .read(updateFeatureRequestStatusProvider({
                            'requestId': request.id,
                            'status': _selectedStatus,
                            'adminNotes': _adminNotes,
                          }).future);

                          if (success) {
                            Navigator.of(context).pop();
                            // Refresh the requests list
                            ref.refresh(allFeatureRequestsProvider);
                          } else {
                            setState(() {
                              _errorMessage =
                                  'Durum güncellenemedi. Lütfen tekrar deneyin.';
                              _isLoading = false;
                            });
                          }
                        } catch (e) {
                          setState(() {
                            _errorMessage = 'Bir hata oluştu: $e';
                            _isLoading = false;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Güncelle'),
              ),
            ],
          );
        },
      ),
    );
  }
}
