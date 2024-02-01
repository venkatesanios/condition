import 'package:rxdart/rxdart.dart';

class CounterBloc
{
  final _counterSubject = BehaviorSubject<int>.seeded(0);

  // Stream for observing the counter
  Stream<int> get counterStream => _counterSubject.stream;

  // Function to increment the counter
  void incrementCounter() {
    _counterSubject.add(_counterSubject.value + 1);
    /*Future.delayed(const Duration(milliseconds: 2000), () async {
      _counterSubject.add(_counterSubject.value + 1);
    });*/

  }

  // Function to decrement the counter
  void decrementCounter() {
    _counterSubject.add(_counterSubject.value - 1);
  }

  // Close the subject when done
  void dispose() {
    _counterSubject.close();
  }
}