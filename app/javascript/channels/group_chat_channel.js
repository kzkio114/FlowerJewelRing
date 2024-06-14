import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const groupChatElement = document.getElementById('group_chat');
  console.log('groupChatElement:', groupChatElement);
  
  if (groupChatElement) {
    const groupChatId = groupChatElement.dataset.groupChatId;
    console.log('groupChatId:', groupChatId);

    const groupChatChannel = consumer.subscriptions.create({ channel: "GroupChatChannel", group_chat_id: groupChatId }, {
      connected() {
        console.log(`Connected to the group chat channel for group chat ${groupChatId}`);
      },
      disconnected() {
        console.log(`Disconnected from the group chat channel for group chat ${groupChatId}`);
      },
      received(data) {
        console.log("Received data:", data);
        const messages = document.getElementById('messages');
        if (data.message) {
          messages.innerHTML += data.message;
          const input = document.getElementById('chat_message_input');
          if (input) {
            input.value = ''; // フィールドをクリア
          }
        }
      },
      speak(message) {
        console.log('Sending message:', message);
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
