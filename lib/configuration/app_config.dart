/// Central configuration. MVP: everything commercial/remote OFF.
class AppConfig {
  static const appName = 'AyuCare';
  static const packageName = 'com.xeloxy.ayucare';
  static const version = '1.0.0';
  static const contentVersion = '1.0';
  static const contactEmail = 'care@ayucare.example';
}

class FeatureFlags {
  static const adsEnabled = false;
  static const affiliateEnabled = false;
  static const remoteContentEnabled = false;
  static const analyticsEnabled = false;
}

/// Central disclaimer copy — one place to update globally.
class DisclaimerConfig {
  static const globalDisclaimer =
      'AyuCare is an educational health and wellness reference app. It is not a '
      'medical device and does not diagnose, treat, cure, or prevent any disease '
      'or medical condition. Information about health conditions, symptoms, herbs, '
      'Ayurveda, home remedies, and products is for general educational purposes '
      'only and is not a substitute for professional medical advice, diagnosis, or '
      'treatment. Please consult a qualified healthcare professional before starting '
      'any new herb, supplement, home remedy, or health product, especially if you '
      'are pregnant, nursing, taking medication, managing a medical condition, or '
      'caring for a child or older adult. For urgent or emergency symptoms, seek '
      'appropriate medical care immediately.';
  static const friendlyLine =
      'AyuCare is here to inform you, not replace your healthcare professional.';
  static const homeNotice =
      'Health information on AyuCare is for educational purposes only. We are not '
      'your doctor and this app does not diagnose or treat medical conditions. '
      'Please consult a qualified healthcare professional before making health decisions.';
  static const conditionNotice =
      'This information is for education only and is not a diagnosis or treatment '
      'plan. AyuCare does not replace your healthcare professional.';
  static const herbalNotice =
      'Please discuss any new home remedy, herb, or Ayurvedic practice with a '
      'qualified healthcare professional before use. Natural does not always mean '
      'safe, and herbs or supplements may interact with medicines or may not be '
      'appropriate for everyone. AyuCare provides educational information and is not your doctor.';
  static const herbNotice =
      'Herbal products can have side effects and may interact with medicines or '
      'medical conditions. Before using a herb or supplement for a health concern, '
      'discuss it with a qualified healthcare professional.';
  static const productNotice =
      'These products are shown for informational and external shopping purposes '
      'only. Their inclusion does not mean that AyuCare recommends them as a '
      'treatment or that they are appropriate for you. Please consult a qualified '
      'healthcare professional before using any supplement, herbal product, or '
      'other health product for a medical condition.';
  static const affiliateDisclosure =
      'Some links may be affiliate links. We may earn a commission if you purchase '
      'through them, at no additional cost to you.';
  static const searchNotice =
      'Search results may contain information about conditions associated with '
      'similar symptoms. They cannot determine what condition you have. Please '
      'consult a qualified healthcare professional for diagnosis or treatment.';
  static const pageFooter =
      'Educational information only. This content does not diagnose, treat, cure, '
      'or prevent disease. Consult a qualified healthcare professional for medical advice.';
}
