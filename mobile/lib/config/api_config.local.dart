/// Local API override for physical devices.
///
/// When testing on a real iPhone or Android phone, set this to your computer's
/// LAN address, for example:
///
///   const String? localApiBaseUrl = 'http://192.168.1.42:8000';
///
/// Start the API so it accepts network connections:
///
///   php artisan serve --host=0.0.0.0 --port=8000
///
/// Leave as null when using the iOS Simulator or Android Emulator.
const String? localApiBaseUrl = 'http://192.168.254.104:8000';
