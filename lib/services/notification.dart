import 'package:flash_chat/services/networking.dart';

class ChatNotification {
  String serverUrl = 'https://flash-chat-backend.herokuapp.com';

  void sendNotification(String sender, String message) async {
    String url =
        '$serverUrl/message?sender=$sender&receiver=debaishik14@gmail.com&message=$message';

    NetworkHelper networkHelper = NetworkHelper(url);

    var responseData = await networkHelper.getData();

    print(responseData);
  }
}
