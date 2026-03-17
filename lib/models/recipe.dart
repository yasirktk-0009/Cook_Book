// ─── Recipe Model ─────────────────────────────────────────────────────────────

class Ingredient {
  String name;
  String quantity;

  Ingredient({required this.name, required this.quantity});

  Map<String, dynamic> toMap() => {'name': name, 'quantity': quantity};

  factory Ingredient.fromMap(Map<String, dynamic> map) =>
      Ingredient(name: map['name'], quantity: map['quantity']);
}

class Recipe {
  final String id;
  String title;
  String category;
  int cookTimeMinutes;
  String difficulty; // Easy | Medium | Hard
  String imageUrl;
  double rating;
  List<Ingredient> ingredients;
  List<String> steps;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.imageUrl,
    required this.rating,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    int? cookTimeMinutes,
    String? difficulty,
    String? imageUrl,
    double? rating,
    List<Ingredient>? ingredients,
    List<String>? steps,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get formattedTime {
    if (cookTimeMinutes < 60) return '${cookTimeMinutes}m';
    final h = cookTimeMinutes ~/ 60;
    final m = cookTimeMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
