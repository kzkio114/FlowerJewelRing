import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const groupChatElement = document.getElementById('group_chat')
  if (groupChatElement) {
    const groupChatId = groupChatElement.dataset.groupChatId

    const groupChatChannel = consumer.subscriptions.create(
      { channel: "GroupChatChannel", group_chat_id: groupChatId },
      {
        connected() {
          console.log("Connected to the group chat channel")
        },
        disconnected() {
          console.log("Disconnected from the group chat channel")
        },
        received(data) {
          console.log("Received data:", data)
          const messages = document.getElementById('messages')
          if (data.message && messages) {
            messages.innerHTML += data.message
          }
        },
        speak(message) {
          this.perform('speak', { message: message, group_chat_id: groupChatId })
        }
      }
    )

    const input = document.getElementById('chat_message_input')
    const button = document.querySelector('input[type="submit"]')

    if (input && button) {
      const sendMessage = () => {
        const message = input.value
        if (message.trim() !== '') {
          groupChatChannel.speak(message)
          input.value = ''
        }
      }

      input.addEventListener('keypress', function (event) {
        if (event.keyCode === 13) {
          sendMessage()
          event.preventDefault()
        }
      })

      button.addEventListener('click', (event) => {
        sendMessage()
        event.preventDefault()
      })
    }
  }
})
