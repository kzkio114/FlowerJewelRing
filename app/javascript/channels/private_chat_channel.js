// app/javascript/channels/private_chat_channel.js
import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const chatElement = document.getElementById('chat');
  if (chatElement) {
    const userId = chatElement.dataset.userId;

    consumer.subscriptions.create({ channel: "PrivateChatChannel", user_id: userId }, {
      connected() {
        console.log(`Connected to the private chat channel for user ${userId}`);
      },
      disconnected() {
        console.log(`Disconnected from the private chat channel for user ${userId}`);
      },
      received(data) {
        console.log("Received data:", data, "Success:", data.success);
      },
      speak(message, receiver_id) {
        this.perform('speak', { message: message, receiver_id: receiver_id });
      }
    });

    const input = document.getElementById('chat_message_input');
    const button = document.querySelector('input[type="submit"]');

    if (input && button) {
      const sendMessage = () => {
        const message = input.value;
        if (message.trim() !== '') {
          privateChatChannel.speak(message, input.dataset.receiverId);
          input.value = ''; // フィールドをクリア
        }
      };

      input.addEventListener('keypress', function(event) {
        if (event.keyCode === 13) {
          sendMessage();
          event.preventDefault();
        }
      });

      button.addEventListener('click', (event) => {
        sendMessage();
        event.preventDefault();
      });
    }
  }
});
