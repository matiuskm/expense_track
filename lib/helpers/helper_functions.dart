// These are some helpful functions to be used across the app

// convert string to double
import 'package:intl/intl.dart';

double stringToDouble(String value) {
  return double.tryParse(value) ?? 0;
}

// formating double amount into rupiah
String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
  return format.format(amount);
}

// calculate the number of months since the first start month
int calculateMonthCount(
    int startYear, int startMonth, int currentYear, int currentMonth) {
  return (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
}

// get current month name
String getCurrentMonthName() {
  return DateFormat.MMMM().format(DateTime.now()).toUpperCase();
}
