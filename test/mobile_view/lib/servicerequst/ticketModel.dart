// lib/models/ticket.dart
import 'package:uuid/uuid.dart';

class Ticket {
  final String id;
  final String category;
  final String priority;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.category,
    required this.priority,
    required this.createdAt,
  });

  factory Ticket.create({required String category, required String priority}) {
    return Ticket(
      id: Uuid().v4(),
      category: category,
      priority: priority,
      createdAt: DateTime.now(),
    );
  }
}
