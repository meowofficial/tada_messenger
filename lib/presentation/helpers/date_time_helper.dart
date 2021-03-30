abstract class DateTimeHelper {
  DateTime getCurrentUtcDateTime();
}

class DateTimeHelperImpl implements DateTimeHelper {
  @override
  DateTime getCurrentUtcDateTime() {
    return DateTime.now().toUtc();
  }
}