import 'package:flash_chat/services/networking.dart';

class ChatNotification {
  String serverUrl = 'https://flash-chat-backend.herokuapp.com';

  void sendNotification(String sender, String senderEmail, String receiver,
      String message) async {
    String url =
        '$serverUrl/message?sender=$sender&senderEmail=$senderEmail&receiver=$receiver&message=$message';

    NetworkHelper networkHelper = NetworkHelper(url);

    var responseData = await networkHelper.getData();

    print(responseData);
  }
}
