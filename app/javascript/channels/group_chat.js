import consumer from "./consumer";

const chatElement = document.getElementById('group_chat');
if (chatElement) {
  const groupChatId = chatElement.dataset.groupChatId;

  const groupChatChannel = consumer.subscriptions.create(
    { channel: "GroupChatChannel", group_chat_id: groupChatId },
    {
      connected() {},
      disconnected() {},
      received(data) {
        const messages = document.getElementById('messages');
        if (data.action === 'create' && messages) {
          messages.innerHTML += data.message_html;
        } else if (data.action === 'destroy' && data.message_id) {
          const messageElement = document.getElementById(`message_${data.message_id}`);
          if (messageElement) {
            messageElement.remove();
          }
        }
      },
      speak(message) {
        this.perform('speak', { message: message, group_chat_id: groupChatId });
      },
      deleteMessage(message_id) {
        this.perform('delete_message', { message_id: message_id });
      }
    }
  );

  document.addEventListener('turbo:load', () => {
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

      input.removeEventListener('keypress', sendMessage);
      input.addEventListener('keypress', function(event) {
        if (event.keyCode === 13) {
          sendMessage();
          event.preventDefault();
        }
      });

      button.removeEventListener('click', sendMessage);
      button.addEventListener('click', (event) => {
        sendMessage();
        event.preventDefault();
      });
    }
  });
}