import consumer from "./consumer"

const privateChatChannel = consumer.subscriptions.create("PrivateChatChannel", {
  connected() {
    console.log("Connected to the private chat channel");
  },
  disconnected() {
    console.log("Disconnected from the private chat channel");
  },
  received(data) {
    console.log("Received data:", data, "Success:", data.success);
    const messages = document.getElementById('messages');
    if (messages && data.message) {
      messages.innerHTML += data.message;
      if (data.success) {
        const input = document.getElementById('chat_message_input');
        if (input) {
          input.value = ''; // Clear input field
        }
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
        privateChatChannel.speak(message, input.dataset.receiverId);
        input.value = ''; // Clear input field
      }
    };

    input.addEventListener('keypress', function(event) {
      if (event.keyCode === 13) {  // Enter key pressed
        sendMessage();
        event.preventDefault();
      }
    });

    button.addEventListener('click', (event) => {
      sendMessage();
      event.preventDefault(); // Prevent form submission
    });
  }
});
