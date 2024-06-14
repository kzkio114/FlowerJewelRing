import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const groupChatElement = document.getElementById('chat_message_input');
  const groupChatId = groupChatElement.dataset.groupChatId;

  if (groupChatId) {
    const groupChatChannel = consumer.subscriptions.create({ channel: "GroupChatChannel", group_chat_id: groupChatId }, {
      connected() {
        console.log(`Connected to the group chat channel for group ${groupChatId}`);
      },
      disconnected() {
        console.log(`Disconnected from the group chat channel for group ${groupChatId}`);
      },
      received(data) {
        const messages = document.getElementById('messages');
        if (data.action === 'create' && messages) {
          messages.innerHTML += data.message;
          if (data.user_id === parseInt(groupChatElement.dataset.currentUserId)) {
            groupChatElement.value = '';
          }
        } else if (data.action === 'destroy' && data.message_id) {
          const messageElement = document.getElementById(`message_${data.message_id}`);
          if (messageElement) {
            messageElement.remove();
          }
        }
      },
      speak(message) {
        this.perform('speak', { message: message, group_chat_id: groupChatId });
      }
    });

    groupChatElement.addEventListener('keypress', function(event) {
      if (event.keyCode === 13) {
        const message = groupChatElement.value;
        if (message.trim() !== '') {
          groupChatChannel.speak(message);
          groupChatElement.value = '';
        }
        event.preventDefault();
      }
    });
  }
});
