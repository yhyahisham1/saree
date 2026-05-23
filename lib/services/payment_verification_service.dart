// lib/services/payment_verification_service.dart
import 'dart:io';

class PaymentVerificationService {
  /// التحقق من صحة إيصال الدفع
  /// 
  /// [receiptImage] صورة الإيصال المرفوعة
  /// [expectedAmount] المبلغ المتوقع دفعه (عدد الطلبات × 1 شيكل)
  static Future<VerificationResult> verifyReceipt(
    File receiptImage,
    int expectedAmount,
  ) async {
    // محاكاة وقت المعالجة
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: هنا سيتم إضافة OCR حقيقي لقراءة الإيصال
    // مثل استخدام: google_ml_kit, tesseract_ocr, أو API خارجي
    
    // محاكاة: 90% من الإيصالات تُقبل تلقائياً
    final isAutoVerified = DateTime.now().millisecondsSinceEpoch % 10 != 0;
    
    if (isAutoVerified) {
      return VerificationResult(
        success: true,
        message: 'تم التحقق من الإيصال بنجاح',
        extractedData: {
          'beneficiary': 'شركة سريع للتوصيل',
          'amount': expectedAmount,
          'date': DateTime.now(),
        },
      );
    } else {
      return VerificationResult(
        success: false,
        message: 'الإيصال غير واضح. يرجى إعادة رفع صورة أوضح',
        needsManualReview: true,
      );
    }
  }
  
  /// التحقق اليدوي من الإيصال (للمدير)
  static Future<VerificationResult> manualVerify(
    String receiptId,
    bool approved,
    String? notes,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return VerificationResult(
      success: approved,
      message: approved ? 'تم قبول الإيصال' : (notes ?? 'تم رفض الإيصال'),
      needsManualReview: false,
    );
  }
}

class VerificationResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? extractedData;
  final bool needsManualReview;
  
  VerificationResult({
    required this.success,
    required this.message,
    this.extractedData,
    this.needsManualReview = false,
  });
}