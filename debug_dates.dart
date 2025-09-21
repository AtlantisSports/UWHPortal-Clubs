void main() {
  print('DateTime constants:');
  print('Monday: ${DateTime.monday}');
  print('Tuesday: ${DateTime.tuesday}');
  print('Wednesday: ${DateTime.wednesday}');
  print('Thursday: ${DateTime.thursday}');
  print('Friday: ${DateTime.friday}');
  print('Saturday: ${DateTime.saturday}');
  print('Sunday: ${DateTime.sunday}');
  print('');

  DateTime today = DateTime(2025, 9, 21);
  print('Today (Sept 21, 2025) is weekday: ${today.weekday}');
  print('Today is: ${['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][today.weekday]}');
  print('');

  // Test the date generation for Monday (weekday 1)
  DateTime startDate = DateTime(2025, 9, 1);
  DateTime current = startDate;
  int targetDay = DateTime.monday; // 1

  print('Looking for Monday (weekday $targetDay) starting from $startDate');
  while (current.weekday != targetDay && current.month == startDate.month) {
    print('Checking $current (weekday ${current.weekday})');
    current = current.add(const Duration(days: 1));
  }
  print('Found first Monday: $current (weekday ${current.weekday})');
  
  // Test Wednesday too
  current = startDate;
  targetDay = DateTime.wednesday; // 3
  print('');
  print('Looking for Wednesday (weekday $targetDay) starting from $startDate');
  while (current.weekday != targetDay && current.month == startDate.month) {
    print('Checking $current (weekday ${current.weekday})');
    current = current.add(const Duration(days: 1));
  }
  print('Found first Wednesday: $current (weekday ${current.weekday})');
}