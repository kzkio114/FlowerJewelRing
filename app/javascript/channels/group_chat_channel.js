import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const chatElement = document.getElementById('chat');
  if (chatElement) {
    const groupChatId = chatElement.dataset.groupChatId;
    const groupChatChannel = consumer.subscriptions.create({ channel: "GroupChatChannel", id: groupChatId }, {
      connected() {
        console.log(`Connected to the group chat channel ${groupChatId}`);
      },
      disconnected() {
        console.log(`Disconnected from the group chat channel ${groupChatId}`);
      },
      received(data) {
        console.log("Received data:", data, "Success:", data.success);
        const messages = document.getElementById('messages');
        if (data.message && messages) {
          messages.innerHTML += data.message;
          if (data.success) {
            const input = document.getElementById('chat_message_input');
            if (input) {
              input.value = '';
            }
          }
        }
      },
      speak(message) {
        this.perform('speak', { message: message, group_chat_id: groupChatId });
      }
    });

    const input = document.getElementById('chat_message_input');
    const button = document.querySelector('input[type="submit"]');

    if (input && button) {
      const sendMessage = () => {
        const message = input.value;
        if (message.trim() !== '') {
          groupChatChannel.speak(message);
          input.value = '';
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
