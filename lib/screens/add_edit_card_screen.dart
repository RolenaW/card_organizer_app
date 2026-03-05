import 'package:flutter/material.dart';

import '../models/card.dart';
import '../models/folder.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {

  final Folder folder;
  final PlayingCard? card;

  const AddEditCardScreen({
    super.key,
    required this.folder,
    this.card,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {

  final CardRepository _cardRepository = CardRepository();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _imageController;

  String _selectedSuit = 'Hearts';

  final List<String> _suits = [
    'Hearts',
    'Diamonds',
    'Clubs',
    'Spades'
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
        text: widget.card?.cardName ?? '');

    _imageController = TextEditingController(
        text: widget.card?.imageUrl ?? '');

    _selectedSuit = widget.card?.suit ?? widget.folder.folderName;
  }

  // Save card to database
  Future<void> _saveCard() async {

    if (!_formKey.currentState!.validate()) return;

    final newCard = PlayingCard(

      id: widget.card?.id,

      cardName: _nameController.text,

      suit: _selectedSuit,

      imageUrl: _imageController.text,

      folderId: widget.folder.id!,
    );

    if (widget.card == null) {

      await _cardRepository.insertCard(newCard);

    } else {

      await _cardRepository.updateCard(newCard);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final isEditing = widget.card != null;

    return Scaffold(

      appBar: AppBar(
        title: Text(isEditing ? 'Edit Card' : 'Add Card'),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              // Card name input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Card Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter card name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Suit dropdown
              DropdownButtonFormField<String>(

                value: _selectedSuit,

                decoration: const InputDecoration(
                  labelText: 'Suit',
                ),

                items: _suits.map((suit) {

                  return DropdownMenuItem(
                    value: suit,
                    child: Text(suit),
                  );

                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _selectedSuit = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Image path input
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL / Asset Path',
                ),
              ),

              const SizedBox(height: 30),

              Row(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [

                  ElevatedButton(
                    onPressed: _saveCard,
                    child: const Text('Save'),
                  ),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}