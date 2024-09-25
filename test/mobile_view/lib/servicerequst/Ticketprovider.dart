// lib/providers/ticket_provider.dart
import 'package:flutter/material.dart';
import 'package:servicerequest/ticketModel.dart';

class TicketProvider with ChangeNotifier {
  final List<Ticket> _tickets = [];

  List<Ticket> get tickets => _tickets;

  void addTicket(Ticket ticket) {
    _tickets.add(ticket);
    notifyListeners();
  }
}
