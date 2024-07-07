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
    console.log("Received data:", data, "Success:", data.success); // この行を修正
    const messages = document.getElementById('messages');
    if (data.action === 'create' && messages && data.message) {
      messages.innerHTML += data.message; // サーバーから受け取ったHTMLを挿入
      if (data.success) {
        const input = document.getElementById('chat_message_input');
        if (input) {
          input.value = ''; // フィールドをクリア
        }
      }
      // 新しいメッセージを追加した後にスクロール
      messages.scrollTop = messages.scrollHeight;
    } else if (data.action === 'destroy' && data.chat_id) {
      const chatElement = document.getElementById(`chat_${data.chat_id}`);
      if (chatElement) {
        chatElement.remove(); // メッセージを削除
      }
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
        input.value = ''; // フィールドをクリア
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
