import 'package:flutter/material.dart';
import 'package:flutter_starter_template/shared/presentation/collection_visuals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('palette tokens are unique and round-trip to their icons', () {
    final tokens = collectionPalette.map((o) => o.token).toList();
    expect(tokens.toSet().length, tokens.length);

    for (final option in collectionPalette) {
      expect(collectionIconFor(option.token), option.icon);
    }
  });

  test('collectionIconFor falls back for unknown tokens', () {
    expect(collectionIconFor('not-a-token'), isNotNull);
  });

  test('collectionGradientFor returns two stops darker than the seed', () {
    final gradient = collectionGradientFor(0xFF6366F1);

    expect(gradient, hasLength(2));
    expect(gradient.first, const Color(0xFF6366F1));
    expect(
      gradient.last.computeLuminance(),
      lessThan(gradient.first.computeLuminance()),
    );
  });
}
