import 'dart:io';

class NetworkConfig {
  // Method to get the appropriate base URL based on platform
  static String getBaseUrl() {
    if (Platform.isAndroid) {
      // For Android emulator
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      // For iOS simulator
      return 'http://127.0.0.1:3000/api';
    } else {
      // Default fallback
      return 'http://localhost:3000/api';
    }
  }

  // Alternative URLs to try if the main one fails
  static List<String> getAlternativeUrls() {
    return [
      'http://10.0.2.2:3000/api', // Android emulator
      'http://127.0.0.1:3000/api', // iOS simulator/localhost
      'http://localhost:3000/api', // Alternative localhost
      'http://192.168.1.100:3000/api', // Local network IP (replace with your IP)
      'http://192.168.0.100:3000/api', // Alternative local IP
    ];
  }

  // Instructions for users to find their local IP
  static String getNetworkInstructions() {
    if (Platform.isAndroid) {
      return '''
Android Emulator Setup:
1. Make sure your Node.js server is running on port 3000
2. The app is configured to use 10.0.2.2:3000 for emulator
3. If using a real device, find your computer's local IP:
   - Windows: Open cmd, type 'ipconfig', look for IPv4 Address
   - Mac/Linux: Open terminal, type 'ifconfig', look for inet address
4. Replace 192.168.x.x in the alternative URLs with your IP
      ''';
    } else {
      return '''
iOS Simulator Setup:
1. Make sure your Node.js server is running on port 3000
2. The app is configured to use 127.0.0.1:3000 for simulator
3. If using a real device, use your computer's local IP address
      ''';
    }
  }
}
