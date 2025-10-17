class Endpoints {
  static const String base = '/api';

  // Auth
  static const String login = '$base/Auth/login';
  static const String register = '$base/Auth/register';
  static const String changePassword = '$base/Auth/change-password';

  // Category
  static const String categories = '$base/Category';

  // Chat (RAG)
  static const String chatAsk = '$base/Chat/ask';
  static const String chatIndex = '$base/Chat/index';

  // Equipment / Products
  static const String equipments = '$base/Equipment';
  static String equipmentById(int id) => '$base/Equipment/$id';
  static const String equipmentBrands = '$base/Equipment/brands';
  static const String equipmentRangePrice = '$base/Equipment/rangePrice';
  static String equipmentRelated(int id, int categoryId) => '$base/Equipment/$id/$categoryId/related';

  // Payment
  static const String payment = '$base/Payment';
  static const String paymentCallback = '$base/Payment/callback';

  // RentalOrder
  static const String rentalOrder = '$base/RentalOrder';
  static const String rentalOrderAdmin = '$base/RentalOrder/admin';
  static const String rentalOrderStatuses = '$base/RentalOrder/statuses';
  static const String rentalOrderCalculate = '$base/RentalOrder/calculate';
  static String rentalOrderById(int id) => '$base/RentalOrder/$id';
  static String rentalOrderUser(int userId) => '$base/RentalOrder/user/$userId';
  static const String rentalOrderCheckAvailability = '$base/RentalOrder/check-availability';

  // User
  static const String users = '$base/User';
  static const String userMe = '$base/User/me';
  static const String userAvatar = '$base/User/avatar';
  static const String userProfile = '$base/User/profile';
  static const String userOffline = '$base/User/offline';


  //reservation
  static const String reservation = '$base/Reservation';

  //cart 
  static const String cart = '$base/Cart';
  static const String cartAddItem = '$base/Cart/add';
}

// Helper to build query params could be added in repositories where needed.
