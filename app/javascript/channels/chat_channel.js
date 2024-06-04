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
    console.log("Received data:", data); // 受信データをログに出力
    const messages = document.getElementById('messages');
    if (messages && data.html) {
      const parser = new DOMParser();
      const doc = parser.parseFromString(data.html, 'text/html');
      messages.appendChild(doc.body.firstChild);
    }
  },
  speak(message, receiver_id) {
    this.perform('speak', { message: message, receiver_id: receiver_id });
  }
});

document.addEventListener('turbo:load', () => {
  const input = document.getElementById('chat_message_input');
  const button = document.querySelector('input[type="submit"]');

  if (input && button) {
    const sendMessage = () => {
      const message = input.value;
      if (message.trim() !== '') {
        chatChannel.speak(message, input.dataset.receiverId);
        input.value = '';
      }
    };

    input.addEventListener('keypress', function(event) {
      if (event.keyCode === 13) {  // Enterキーが押された場合
        sendMessage();
        event.preventDefault();
      }
    });

    button.addEventListener('click', (event) => {
      sendMessage();
      event.preventDefault(); // フォームのデフォルトの送信動作を防ぐ
    });
  }
});
