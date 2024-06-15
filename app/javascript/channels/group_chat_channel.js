import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  console.log('Turbo:load event fired');
  const groupChatElement = document.getElementById('group_chat');
  const groupChatId = groupChatElement ? groupChatElement.dataset.groupChatId : null;

  if (groupChatId) {
    console.log(`Found group_chat element with ID: ${groupChatId}`);
    const groupChatChannel = consumer.subscriptions.create({ channel: "GroupChatChannel", group_chat_id: groupChatId }, {
      connected() {
        console.log(`Connected to the group chat channel for group ${groupChatId}`);
      },
      disconnected() {
        console.log(`Disconnected from the group chat channel for group ${groupChatId}`);
      },
      received(data) {
        console.log("Received data:", data, "Success:", data.success);
        const messagesContainer = document.getElementById('messages');
        if (data.action === 'create' && messagesContainer && data.message_html) {
          console.log('Appending new message to messages container');
          messagesContainer.innerHTML += data.message_html;
          const input = document.getElementById('group_chat_message_input');
          if (data.success && input) {
            console.log('Clearing input field');
            input.value = ''; // フィールドをクリア
          }
        } else if (data.action === 'destroy' && data.message_id) {
          console.log('Removing message with ID:', data.message_id);
          const messageElement = document.getElementById(`message_${data.message_id}`);
          if (messageElement) {
            messageElement.remove();
          }
        }
      },
      speak(message, group_chat_id) {
        console.log(`Sending message to group ${group_chat_id}:`, message);
        this.perform('speak', { message: message, group_chat_id: group_chat_id });
      },
      deleteMessage(message_id) {
        console.log(`Requesting deletion of message with ID: ${message_id}`);
        this.perform('delete_message', { message_id: message_id });
      }
    });

    const input = document.getElementById('group_chat_message_input');
    const button = document.querySelector('input[type="submit"]');

    if (input && button) {
      console.log('Found input field and submit button');
      const sendMessage = () => {
        const messageContent = input.value;
        if (messageContent.trim() !== '') {
          console.log('Sending message:', messageContent);
          groupChatChannel.speak(messageContent, input.dataset.groupChatId);
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

    document.addEventListener('click', (event) => {
      if (event.target.matches('.delete-chat-button')) {
        const messageId = event.target.dataset.messageId;
        console.log(`Delete button clicked for message ID: ${messageId}`);
        groupChatChannel.deleteMessage(messageId);
      }
    });
  } else {
    console.log('Group chat element not found');
  }
});
