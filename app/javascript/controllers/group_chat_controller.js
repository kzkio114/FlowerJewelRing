import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

export default class extends Controller {
  static targets = ["groupInput", "groupMessages", "groupSubmitButton"];

  connect() {
    console.log("Connected to GroupChatChannel");

    const chatElement = this.element.closest('[data-group-chat-id]');
    if (chatElement) {
      this.groupChatId = chatElement.dataset.groupChatId;

      this.groupChatChannel = consumer.subscriptions.create(
        { channel: "GroupChatChannel", group_chat_id: this.groupChatId },
        {
          connected: () => console.log(`Connected to GroupChatChannel with ID: ${this.groupChatId}`),
          disconnected: () => console.log(`Disconnected from GroupChatChannel with ID: ${this.groupChatId}`),
          received: this.received.bind(this)
        }
      );
    } else {
      console.error("Group Chat element not found");
    }
  }

  received(data) {
    if (data.action === "create" && data.message_html) {
      if (this.hasGroupMessagesTarget) {
        this.groupMessagesTarget.insertAdjacentHTML("beforeend", data.message_html);
        this.groupMessagesTarget.scrollTop = this.groupMessagesTarget.scrollHeight;
      } else {
        console.error("Missing target element 'groupMessages'");
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

    const message = this.groupInputTarget.value.trim();
    if (message !== "") {
      this.groupChatChannel.perform("speak", {
        message: message,
        group_chat_id: this.groupChatId
      });
      this.groupInputTarget.value = "";
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
      this.sendMessage(event);
    }
  }
}
