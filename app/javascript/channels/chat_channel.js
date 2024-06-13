import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const chatElement = document.getElementById('chat');
  const userId = chatElement.dataset.userId; // current_userのID

  if (userId) {
    const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", user_id: userId }, {
      connected() {
        console.log(`Connected to the chat channel for user ${userId}`);
      },
      disconnected() {
        console.log(`Disconnected from the chat channel for user ${userId}`);
      },
      received(data) {
        console.log("Received data:", data, "Success:", data.success);
        const messages = document.getElementById('messages');
        if (data.message && messages) {
          messages.innerHTML += data.message;
          if (data.success) {
            const input = document.getElementById('chat_message_input');
            if (input) {
              input.value = ''; // フィールドをクリア
            }
          }
        }
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
          chatChannel.speak(message, input.dataset.receiverId);
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
