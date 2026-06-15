import 'package:flutter/material.dart';

class HealthStream<T> extends StatelessWidget {
  const HealthStream({
    super.key,
    required this.stream,
    required this.fallback,
    required this.builder,
  });

  final Stream<T>? stream;
  final T fallback;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    final activeStream = stream;
    // Firebase not available — render with sample/demo fallback data.
    if (activeStream == null) {
      return builder(context, fallback);
    }

    return StreamBuilder<T>(
      stream: activeStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return builder(context, fallback);
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}
