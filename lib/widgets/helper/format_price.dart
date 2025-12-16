import 'package:intl/intl.dart';

// format price without currency
String formatPrice(String price, int discount) {
  try {
    double priceValue = double.parse(price);
    if (discount > 0) {
      priceValue *= (1 - (discount / 100));
    }
    final formatter = NumberFormat("#,##0", "en_US");
    String formattedPrice = formatter.format(priceValue);
    return formattedPrice;
  } catch (e) {
    return price;
  }
}
