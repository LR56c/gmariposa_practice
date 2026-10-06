///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEs = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// es: 'Mini Catálogo'
	String get appTitle => 'Mini Catálogo';

	/// es: 'No hay productos'
	String get emptyCatalog => 'No hay productos';

	/// es: 'Buscar productos'
	String get searchHint => 'Buscar productos';

	/// es: 'Reintentar'
	String get retry => 'Reintentar';

	/// es: 'No hay más productos'
	String get noMoreProducts => 'No hay más productos';

	/// es: 'Agregar al carrito'
	String get addToCart => 'Agregar al carrito';

	/// es: 'Volver al catálogo'
	String get backToCatalog => 'Volver al catálogo';

	/// es: 'Sin foto'
	String get noPhoto => 'Sin foto';

	late final Translations$errors$es errors = Translations$errors$es._(_root);
}

// Path: errors
class Translations$errors$es {
	Translations$errors$es._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// es: 'No se pudo conectar. Revisa tu conexión.'
	String get network => 'No se pudo conectar. Revisa tu conexión.';

	/// es: 'Algo salió mal. Inténtalo de nuevo.'
	String get server => 'Algo salió mal. Inténtalo de nuevo.';

	/// es: 'No se pudo leer la respuesta. Inténtalo de nuevo.'
	String get parse => 'No se pudo leer la respuesta. Inténtalo de nuevo.';

	/// es: 'No encontramos ese producto.'
	String get notFound => 'No encontramos ese producto.';

	/// es: 'Algo salió mal. Inténtalo de nuevo.'
	String get generic => 'Algo salió mal. Inténtalo de nuevo.';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appTitle' => 'Mini Catálogo',
			'emptyCatalog' => 'No hay productos',
			'searchHint' => 'Buscar productos',
			'retry' => 'Reintentar',
			'noMoreProducts' => 'No hay más productos',
			'addToCart' => 'Agregar al carrito',
			'backToCatalog' => 'Volver al catálogo',
			'noPhoto' => 'Sin foto',
			'errors.network' => 'No se pudo conectar. Revisa tu conexión.',
			'errors.server' => 'Algo salió mal. Inténtalo de nuevo.',
			'errors.parse' => 'No se pudo leer la respuesta. Inténtalo de nuevo.',
			'errors.notFound' => 'No encontramos ese producto.',
			'errors.generic' => 'Algo salió mal. Inténtalo de nuevo.',
			_ => null,
		};
	}
}
