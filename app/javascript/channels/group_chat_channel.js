import consumer from "./consumer";

  const chatElement = document.getElementById('group_chat');
  if (chatElement) {
    const groupChatId = chatElement.dataset.groupChatId;
    const groupChatChannel = consumer.subscriptions.create(
      { channel: "GroupChatChannel", group_chat_id: groupChatId },
      {
        connected() {
          console.log("Connected to the GroupChatChannel");
        },
        disconnected() {
          console.log("Disconnected from the GroupChatChannel");
        },
        received(data) {
          const messages = document.getElementById('messages');
          if (data.action === 'create' && messages) {
            messages.insertAdjacentHTML('beforeend', data.message_html);
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
        deleteMessage(messageId) {
          this.perform('delete_message', { message_id: messageId });
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
          if (confirm('Are you sure you want to send this message?')) {
            groupChatChannel.speak(message);
            input.value = '';
          }
        }
      };

      const handleEvent = (event) => {
        sendMessage();
        event.preventDefault();
      };

      input.addEventListener('keypress', function (event) {
        if (event.key === 'Enter') {
          handleEvent(event);
        }
      });

      button.addEventListener('click', handleEvent);
    }
  });
}