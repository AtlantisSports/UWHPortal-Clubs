void main() {
  print('DateTime constants:');
  print('Monday: ${DateTime.monday}');
  print('Tuesday: ${DateTime.tuesday}');
  print('Wednesday: ${DateTime.wednesday}');
  print('Thursday: ${DateTime.thursday}');
  print('Friday: ${DateTime.friday}');
  print('Saturday: ${DateTime.saturday}');
  print('Sunday: ${DateTime.sunday}');
  
  print('\nTest date generation:');
  DateTime sept1 = DateTime(2025, 9, 1);
  print('Sept 1, 2025 is weekday: ${sept1.weekday}');
  
  // Find first Monday
  DateTime current = sept1;
  while (current.weekday != DateTime.monday) {
    current = current.add(Duration(days: 1));
  }
  print('First Monday in Sept 2025: $current (weekday: ${current.weekday})');
  
  // Find first Wednesday  
  current = sept1;
  while (current.weekday != DateTime.wednesday) {
    current = current.add(Duration(days: 1));
  }
  print('First Wednesday in Sept 2025: $current (weekday: ${current.weekday})');
}