import 'package:flutter/material.dart';

import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import 'add_edit_card_screen.dart';

class CardsScreen extends StatefulWidget {

  final Folder folder;

  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {

  final CardRepository _cardRepository = CardRepository();

  List<PlayingCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // Load cards for the selected folder
  Future<void> _loadCards() async {

    final cards =
        await _cardRepository.getCardsByFolderId(widget.folder.id!);

    setState(() {
      _cards = cards;
    });
  }

  // Delete a card with confirmation
  Future<void> _deleteCard(PlayingCard card) async {

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Delete ${card.cardName} of ${card.suit}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {

      await _cardRepository.deleteCard(card.id!);

      _loadCards();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${card.cardName} deleted')),
      );
    }
  }

  // Navigate to Add/Edit screen
  Future<void> _openAddEditScreen({PlayingCard? card}) async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCardScreen(
          folder: widget.folder,
          card: card,
        ),
      ),
    );

    _loadCards();
  }

  // Display card image
  Widget _buildCardImage(PlayingCard card) {

    if (card.imageUrl == null || card.imageUrl!.isEmpty) {
      return const Icon(Icons.image, size: 50);
    }

    if (card.imageUrl!.startsWith('http')) {

      return Image.network(
        card.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    }

    return Image.asset(
      card.imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 50);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.folder.folderName),
      ),

      body: ListView.builder(

        itemCount: _cards.length,

        itemBuilder: (context, index) {

          final card = _cards[index];

          return Card(

            margin: const EdgeInsets.all(8),

            child: ListTile(

              leading: SizedBox(
                width: 50,
                height: 50,
                child: _buildCardImage(card),
              ),

              title: Text(card.cardName),

              subtitle: Text(card.suit),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openAddEditScreen(card: card),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCard(card),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Button to add new card
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}