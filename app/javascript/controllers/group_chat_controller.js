import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

export default class extends Controller {
  static targets = ["groupInput", "groupMessages", "groupSubmitButton"];

  connect() {
    console.log("Connected to GroupChatChannel");
    console.log("groupMessages target:", this.groupMessagesTarget);

    const chatElement = this.element.closest('[data-group-chat-id]');
    if (chatElement) {
      this.groupChatId = chatElement.dataset.groupChatId;

      this.groupChatChannel = consumer.subscriptions.create(
        { channel: "GroupChatChannel", group_chat_id: this.groupChatId },
        {
          connected: this.connected.bind(this),
          disconnected: this.disconnected.bind(this),
          received: this.received.bind(this),
        }
      );
    } else {
      console.error("Group Chat element not found");
    }
  }

  connected() {
    console.log(`Connected to GroupChatChannel with ID: ${this.groupChatId}`);
  }

  disconnected() {
    console.log(`Disconnected from GroupChatChannel with ID: ${this.groupChatId}`);
  }

  received(data) {
    if (data.action === 'error' && data.errors) {
      const errorMessagesDiv = document.getElementById('error-messages');
      if (errorMessagesDiv) {
        errorMessagesDiv.innerHTML = data.errors.join("<br>");
        errorMessagesDiv.style.display = 'block';
      }
    } else if (data.action === "create" && data.message_html) {
      if (this.hasGroupMessagesTarget) {
        this.groupMessagesTarget.insertAdjacentHTML("beforeend", data.message_html);
        this.groupMessagesTarget.scrollTop = this.groupMessagesTarget.scrollHeight;
  
        const currentUserId = document.querySelector('[data-current-user-id]').dataset.currentUserId;
        console.log("Current User ID:", currentUserId);
  
        const messageElement = this.groupMessagesTarget.lastElementChild;
        const messageUserId = messageElement.dataset.messageUserId;
        console.log("Message User ID:", messageUserId);
  
        if (currentUserId === messageUserId) {
          const deleteButton = messageElement.querySelector('.delete-chat-button');
          console.log("Delete Button:", deleteButton);
          if (deleteButton) {
            deleteButton.style.display = 'block';
            console.log("Delete button is now visible");
          }
        }
      } else {
        console.error("GroupMessages target not found. Cannot insert new message.");
      }
    } else if (data.action === "destroy" && data.message_id) {
      const messageElement = document.getElementById(`message_${data.message_id}`);
      if (messageElement) {
        messageElement.remove();
      }
    }
  }


  sendMessage(event) {
    event.preventDefault();
  
    if (!this.hasGroupInputTarget) {
      console.error("groupInputTarget is not defined.");
      return;
    }
  
    const message = this.groupInputTarget.value.trim();
    console.log("Message to send:", message); // 送信するメッセージを確認
    if (message !== "") {
      this.groupChatChannel.perform("speak", {
        message: message,
        group_chat_id: this.groupChatId
      });
      this.groupInputTarget.value = ""; // Clear input field
    }
  }
  
  deleteMessage(event) {
    event.preventDefault();
    const messageId = event.target.dataset.messageId;
    if (messageId) {
      this.groupChatChannel.perform("delete_message", { message_id: messageId });
    }
  }

  handleEnterKey(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      if (!this.hasGroupInputTarget) {
        console.error("groupInputTarget is not defined.");
        return;
      }
      this.sendMessage(event);
    }
  }
}
