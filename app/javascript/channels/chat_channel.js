// app/javascript/channels/chat_channel.js
import consumer from "./consumer";

document.addEventListener("turbo:load", () => {
  const chatElement = document.getElementById("content");

  if (!chatElement) {
    console.warn("Chat element not found");
    return;
  }

  const inputElement = document.getElementById("chat_message_input");
  if (!inputElement) {
    console.warn("Chat message input not found");
    return;
  }

  const userId = inputElement.dataset.receiverId;

  if (!userId) {
    console.warn("User ID not found");
    return;
  }

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
      if (data.action === 'create' && messages && data.message) {
        messages.innerHTML += data.message;
        if (data.success) {
          const input = document.getElementById('chat_message_input');
          if (input) {
            input.value = ''; // フィールドをクリア
          }
        }
      } else if (data.action === 'destroy' && data.chat_id) {
        const chatElement = document.getElementById(`chat_${data.chat_id}`);
        if (chatElement) {
          chatElement.remove();
        }
      }
    },
    speak(message, receiver_id) {
      this.perform('speak', { message: message, receiver_id: receiver_id });
    },
    deleteMessage(chat_id) {
      this.perform('delete_message', { chat_id: chat_id });
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

  document.addEventListener('click', (event) => {
    if (event.target.matches('.delete-chat-button')) {
      const chatId = event.target.dataset.chatId;
      chatChannel.deleteMessage(chatId);
    }
  });
});
