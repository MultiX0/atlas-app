import 'package:flutter/material.dart';

class AtlasErrorPage extends StatelessWidget {
  final String code; // e.g., "404", "500"
  final String title; // e.g., "Page Not Found"
  final String message; // e.g., "The manga you're looking for isn't here..."
  final VoidCallback? onRetry;
  final VoidCallback? onHome;

  const AtlasErrorPage({
    super.key,
    this.code = "Oops!",
    this.title = 'Error',
    required this.message,
    this.onRetry,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/error_image.png', height: 180, fit: BoxFit.contain),
              const SizedBox(height: 20),
              Text(
                code,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .7),
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  if (onHome != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.home),
                      onPressed: onHome,
                      label: const Text("Back to Home"),
                    ),
                  if (onRetry != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      onPressed: onRetry,
                      label: const Text("Try Again"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
