import 'lib/core/data/mock_data_service.dart';

void main() async {
  print('Testing practice generation...');
  
  final clubs = await MockDataService.getClubs();
  final denver = clubs.firstWhere((club) => club.id == 'denver-uwh', orElse: () => clubs.first);
  print('\nDenver practices:');
  for (final practice in denver.upcomingPractices.take(10)) {
    print('${practice.title}: ${practice.dateTime} (weekday: ${practice.dateTime.weekday})');
  }

  final sydney = clubs.firstWhere((club) => club.id == 'sydney-uwh', orElse: () => clubs.last);
  print('\nSydney practices:');
  for (final practice in sydney.upcomingPractices.take(10)) {
    print('${practice.title}: ${practice.dateTime} (weekday: ${practice.dateTime.weekday})');
  }
}