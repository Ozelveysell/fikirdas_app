import 'package:flutter/material.dart';
import '../repositores/chat_service.dart';
import 'package:flutter/services.dart'; 
class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController(); // ScrollController eklendi

  void _sendMessage() async {
    String message = _controller.text;
    if (message.isNotEmpty) {
      setState(() {
        _messages.add('Sen: $message'); // Kullanıcının mesajını ekle
        _controller.clear();
      });

      try {
        setState(() {
          _messages.add('Yanıt alınıyor...'); // Yanıt beklenirken geçici mesaj
        });

        String chatResponse = await _chatService.getChatResponse(message);
        setState(() {
          _messages.removeLast(); // Geçici mesajı kaldır
          _messages.add('$chatResponse'); // Botun yanıtını ekle
        });
      } catch (e) {
        setState(() {
          _messages.removeLast(); // Geçici mesajı kaldır
          _messages.add('Bir hata oluştu: $e'); // Hata mesajını ekle
        });
      }
      
      // Mesaj eklendikten sonra en alta kaydır
      _scrollToBottom();
    }
  }

 void _copyToClipboard(String message) {
    Clipboard.setData(ClipboardData(text: message)); // Mesajı panoya kopyala
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mesaj kopyalandı!')), // Kullanıcıya bilgi ver
    );
  }
  // Mesajlar listesi güncellendikten sonra en alta kaydır
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
  void _startNewConversation() {
    setState(() {
      _messages.clear();
    });

  showModalBottomSheet(
    context: context, 
    backgroundColor: Colors.grey[700],
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white,),
            SizedBox(width: 30.0),
            Text('Yeni konuşma başlatıldı!', style: TextStyle(color: Colors.white),
            ),

          ],
        ),
      );
    }
    
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
    onTap: () {
      // Klavyeyi kapatmak için FocusScope.of(context) kullanıyoruz
      FocusScope.of(context).unfocus();
    },
    child:Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text('Fikirdaş', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(onPressed: _startNewConversation ,tooltip: 'Yeni Konuşma Başlat', icon: Icon(Icons.edit, color: Colors.white,))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty // Eğer mesajlar boşsa
                    ? Center( // Mesajın ortada görünmesi için
                        child: Text(
                          'Merhaba ben Fikirdaş, nasıl yardımcı olabilirim?',
                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                    :  ListView.builder(
                controller: _scrollController, // ScrollController burada kullanılıyor
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  bool isUserMessage = _messages[index].startsWith('Sen:');
                  return Align(
                    alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.grey[700] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(20.0),
                      ),

                      child: Row(
                      
                        children: [
                          Expanded(
                            child: Text(
                        _messages[index],
                        style: TextStyle(fontSize: 16.0 , color: Colors.white),
                      ),
                          
                          ),
                          IconButton(
                           icon: Icon(Icons.copy, color: Colors.white),
                           onPressed: () => _copyToClipboard(_messages[index]),
                           ),
                        ],

                      ),
                    
                    ),
                   
                  );
                },
              ),
            ),
            SizedBox(height: 8.0,),
            Row(
              children: [
              
                Expanded(
                  child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText:
                'Fikirdaş uygulamasına ileti gönder', 
                hintStyle:  TextStyle(color: Colors.white),    
              filled: true,
              fillColor: Color.fromARGB(255, 87, 87, 87),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40)),
              borderSide: BorderSide(
              color: Colors.transparent
              ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                borderSide: BorderSide(
                  color: Colors.grey,
                )
              )
              ),
              autocorrect: false,
              enableSuggestions: false,
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
                ),
                 SizedBox(width: 8.0), // TextField ile buton arasında boşluk
                  IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_upward_outlined, color: Colors.grey[800],),
                  ),
                  onPressed: _sendMessage,
                  tooltip: 'Gönder',
                     ),
              ],
            )
          ],
        ),
      ),
    ),
  );
  }
}
