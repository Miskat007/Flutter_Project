import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../data/models/product.dart';
import '../../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _brand;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _image;
  bool _saving = false;

  bool get _isNew => widget.product == null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _title = TextEditingController(text: p?.title ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _brand = TextEditingController(text: p?.brand ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '1');
    _image = TextEditingController(text: p?.thumbnail ?? '');
  }

  @override
  void dispose() {
    for (final controller in [
      _title, _description, _category, _brand, _price, _stock, _image
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final old = widget.product;
    final draft = Product(
      id: old?.id ?? -DateTime.now().microsecondsSinceEpoch,
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category.text.trim(),
      brand: _brand.text.trim(),
      price: double.parse(_price.text.trim()),
      stock: int.parse(_stock.text.trim()),
      rating: old?.rating ?? 0,
      thumbnail: _image.text.trim(),
      images: old?.images ?? const [],
      isLocal: true,
    );
    try {
      await context.read<ProductProvider>().saveProduct(draft, isNew: _isNew);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save product: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? 'Add product' : 'Edit product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_title, 'Product name', validator: _required),
            _field(_description, 'Description', maxLines: 4, validator: _required),
            _field(_category, 'Category', validator: _required),
            _field(_brand, 'Brand'),
            _field(_price, 'Price (USD)',
                keyboard: TextInputType.number,
                validator: (v) {
                  if (_required(v) != null) return _required(v);
                  if (double.tryParse(v!) == null || double.parse(v) < 0) {
                    return 'Enter a valid positive price';
                  }
                  return null;
                }),
            _field(_stock, 'Stock quantity',
                keyboard: TextInputType.number,
                validator: (v) {
                  if (_required(v) != null) return _required(v);
                  if (int.tryParse(v!) == null || int.parse(v) < 0) {
                    return 'Enter a valid whole number';
                  }
                  return null;
                }),
            _field(_image, 'Image URL (optional)',
                keyboard: TextInputType.url),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save product'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Changes are saved on this device. DummyJSON write endpoints are simulated and do not modify its permanent dataset.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
