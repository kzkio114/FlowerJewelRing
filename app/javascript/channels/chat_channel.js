// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create("ChatChannel", {
  connected() {
    console.log("Connected to the chat channel");
  },
  disconnected() {
    console.log("Disconnected from the chat channel");
  },
  received(data) {
    const messages = document.getElementById('messages');
    // ブロードキャストされたHTMLを直接追加
    messages.innerHTML += data.html;
  }
});

document.addEventListener('turbo:load', () => {
  const input = document.getElementById('chat_message');
  const button = document.getElementById('send_message_button');

  if (input && button) {
    const sendMessage = () => {
      const message = input.value;
      if (message.trim() !== '') {
        chatChannel.speak(message, input.dataset.receiverId);  // 受信者IDを動的に取得
        input.value = '';
      }
    };

    input.addEventListener('keypress', function(event) {
      if (event.keyCode === 13) {  // Enterキーが押された場合
        sendMessage();
        event.preventDefault();
      }
    });

    button.addEventListener('click', () => {
      sendMessage();
    });
  }
});
