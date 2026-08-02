class PasswordSentResult {
  const PasswordSentResult({
    required this.email,
    required this.sentAt,
    required this.canResend,
  });

  final String email;
  final DateTime sentAt;
  final bool canResend;
}
