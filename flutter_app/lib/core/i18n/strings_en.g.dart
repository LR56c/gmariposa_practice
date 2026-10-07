///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEn with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override String get appTitle => 'Mini Catalog';
	@override String get emptyCatalog => 'No products';
	@override String get searchHint => 'Search products';
	@override String get retry => 'Retry';
	@override String get noMoreProducts => 'No more products';
	@override String get addToCart => 'Add to cart';
	@override String get addedToCart => 'Added to cart';
	@override String get backToCatalog => 'Back to catalog';
	@override String get noPhoto => 'No photo';
	@override String get cart => 'Cart';
	@override String get productDetail => 'Product details';
	@override String get cartEmpty => 'Your cart is empty';
	@override String get cartLabelEmpty => 'Empty cart';
	@override String cartLabelUnits({required Object units}) => 'Cart, ${units}';
	@override String get remove => 'Remove';
	@override String decreaseQuantity({required Object title}) => 'Decrease quantity of ${title}';
	@override String increaseQuantity({required Object title}) => 'Increase quantity of ${title}';
	@override String units({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} unit',
		other: '${n} units',
	);
	@override String total({required Object amount}) => 'Total ${amount}';
	@override late final _Translations$errors$en errors = _Translations$errors$en._(_root);
}

// Path: errors
class _Translations$errors$en implements Translations$errors$es {
	_Translations$errors$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get network => 'Couldn\'t connect. Check your connection.';
	@override String get server => 'Something went wrong. Please try again.';
	@override String get parse => 'Couldn\'t read the response. Please try again.';
	@override String get notFound => 'We couldn\'t find that product.';
	@override String get generic => 'Something went wrong. Please try again.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appTitle' => 'Mini Catalog',
			'emptyCatalog' => 'No products',
			'searchHint' => 'Search products',
			'retry' => 'Retry',
			'noMoreProducts' => 'No more products',
			'addToCart' => 'Add to cart',
			'addedToCart' => 'Added to cart',
			'backToCatalog' => 'Back to catalog',
			'noPhoto' => 'No photo',
			'cart' => 'Cart',
			'productDetail' => 'Product details',
			'cartEmpty' => 'Your cart is empty',
			'cartLabelEmpty' => 'Empty cart',
			'cartLabelUnits' => ({required Object units}) => 'Cart, ${units}',
			'remove' => 'Remove',
			'decreaseQuantity' => ({required Object title}) => 'Decrease quantity of ${title}',
			'increaseQuantity' => ({required Object title}) => 'Increase quantity of ${title}',
			'units' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} unit', other: '${n} units', ), 
			'total' => ({required Object amount}) => 'Total ${amount}',
			'errors.network' => 'Couldn\'t connect. Check your connection.',
			'errors.server' => 'Something went wrong. Please try again.',
			'errors.parse' => 'Couldn\'t read the response. Please try again.',
			'errors.notFound' => 'We couldn\'t find that product.',
			'errors.generic' => 'Something went wrong. Please try again.',
			_ => null,
		};
	}
}
