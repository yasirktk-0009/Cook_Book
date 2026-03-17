import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';

// ─── Add / Edit Recipe Screen (Bonus) ────────────────────────────────────────
class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // null = add mode, non-null = edit mode

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _formInvalid = false;

  late TextEditingController _titleCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _imageCtrl;

  String _category = 'Breakfast';
  String _difficulty = 'Easy';
  double _rating = 3.0;

  final List<Map<String, TextEditingController>> _ingredients = [];
  final List<TextEditingController> _steps = [];

  static const _categories = ['Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Snack'];
  static const _difficulties = ['Easy', 'Medium', 'Hard'];

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _timeCtrl = TextEditingController(text: r?.cookTimeMinutes.toString() ?? '30');
    _imageCtrl = TextEditingController(text: r?.imageUrl ?? '');
    _category = r?.category ?? 'Breakfast';
    _difficulty = r?.difficulty ?? 'Easy';
    _rating = r?.rating ?? 3.0;

    if (r != null) {
      for (final ing in r.ingredients) {
        _ingredients.add({
          'name': TextEditingController(text: ing.name),
          'qty': TextEditingController(text: ing.quantity),
        });
      }
      for (final step in r.steps) {
        _steps.add(TextEditingController(text: step));
      }
    } else {
      _addIngredient();
      _addStep();
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({
        'name': TextEditingController(),
        'qty': TextEditingController(),
      });
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index]['name']!.dispose();
      _ingredients[index]['qty']!.dispose();
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    setState(() => _steps.add(TextEditingController()));
  }

  void _removeStep(int index) {
    setState(() {
      _steps[index].dispose();
      _steps.removeAt(index);
    });
  }

  void _save() {
    setState(() => _formInvalid = false);

    if (!_formKey.currentState!.validate() ||
        _ingredients.isEmpty ||
        _steps.isEmpty) {
      setState(() => _formInvalid = true);
      return;
    }

    final ingredients = _ingredients
        .map((i) => Ingredient(
              name: i['name']!.text.trim(),
              quantity: i['qty']!.text.trim(),
            ))
        .toList();

    final steps = _steps.map((s) => s.text.trim()).toList();

    final recipe = Recipe(
      id: widget.recipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      category: _category,
      cookTimeMinutes: int.tryParse(_timeCtrl.text) ?? 30,
      difficulty: _difficulty,
      imageUrl: _imageCtrl.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600'
          : _imageCtrl.text.trim(),
      rating: _rating,
      ingredients: ingredients,
      steps: steps,
      isFavorite: widget.recipe?.isFavorite ?? false,
    );

    Navigator.pop(context, recipe);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _timeCtrl.dispose();
    _imageCtrl.dispose();
    for (final i in _ingredients) {
      i['name']!.dispose();
      i['qty']!.dispose();
    }
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        leadingWidth: 80,
        title: Text(
          _isEditing ? 'Edit Recipe' : 'Add Recipe',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Validation Error Banner ─────────────────────────────────────────
            if (_formInvalid)
              Container(
                width: double.infinity,
                color: kErrorColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: kPadding,
                  vertical: 10,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Form is invalid',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(kPadding),
                  children: [
                    // ── Title ──────────────────────────────────────────────────
                    _FieldLabel('Recipe Title *'),
                    _InputField(
                      controller: _titleCtrl,
                      hint: 'e.g. Chicken Tikka',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Title required' : null,
                    ),
                    const SizedBox(height: kPadding),

                    // ── Category ───────────────────────────────────────────────
                    _FieldLabel('Category'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: kPadding),
                      decoration: BoxDecoration(
                        color: isDark ? kDarkCard : kLightCard,
                        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _category,
                          isExpanded: true,
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _category = val!),
                          dropdownColor:
                              isDark ? kDarkCard : kLightSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: kPadding),

                    // ── Cook Time ──────────────────────────────────────────────
                    _FieldLabel('Cook Time (minutes) *'),
                    _InputField(
                      controller: _timeCtrl,
                      hint: '30',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Time required';
                        if (int.tryParse(v) == null) return 'Enter a number';
                        return null;
                      },
                    ),
                    const SizedBox(height: kPadding),

                    // ── Difficulty ─────────────────────────────────────────────
                    _FieldLabel('Difficulty'),
                    Row(
                      children: _difficulties.map((d) {
                        final isSelected = _difficulty == d;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => setState(() => _difficulty = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kPrimaryColor
                                      : isDark
                                          ? kDarkCard
                                          : kLightCard,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  d,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: kPadding),

                    // ── Image URL ──────────────────────────────────────────────
                    _FieldLabel('Image URL (optional)'),
                    _InputField(
                      controller: _imageCtrl,
                      hint: 'https://example.com/image.jpg',
                    ),
                    const SizedBox(height: kPadding),

                    // ── Rating Slider ──────────────────────────────────────────
                    _FieldLabel('Rating: ${_rating.toStringAsFixed(1)}'),
                    Slider(
                      value: _rating,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      activeColor: kPrimaryColor,
                      onChanged: (val) =>
                          setState(() => _rating = val),
                    ),
                    const SizedBox(height: kPadding),

                    // ── Ingredients ────────────────────────────────────────────
                    _FieldLabel('Ingredients *'),
                    ...List.generate(_ingredients.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _InputField(
                                controller: _ingredients[index]['name']!,
                                hint: 'Ingredient name',
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _InputField(
                                controller: _ingredients[index]['qty']!,
                                hint: 'Qty',
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: _ingredients.length > 1
                                  ? () => _removeIngredient(index)
                                  : null,
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: _ingredients.length > 1
                                    ? Colors.grey
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    OutlinedButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Ingredient'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: BorderSide(
                          color: kPrimaryColor.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: kPadding),

                    // ── Steps ──────────────────────────────────────────────────
                    _FieldLabel('Steps *'),
                    ...List.generate(_steps.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 8),
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: kPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _InputField(
                                controller: _steps[index],
                                hint: 'Describe this step...',
                                maxLines: 3,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Step required'
                                        : null,
                              ),
                            ),
                            IconButton(
                              onPressed: _steps.length > 1
                                  ? () => _removeStep(index)
                                  : null,
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: _steps.length > 1
                                    ? Colors.grey
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    OutlinedButton.icon(
                      onPressed: _addStep,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Step'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: BorderSide(
                          color: kPrimaryColor.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? kDarkCard : kLightCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: const BorderSide(color: kErrorColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          borderSide: const BorderSide(color: kPrimaryColor),
        ),
      ),
    );
  }
}
