import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

export default class extends Controller {
  static targets = ["groupInput", "groupMessages", "groupSubmitButton"];

  connect() {
    console.log("Connect method called");
    console.log("groupMessages target exists:", this.hasGroupMessagesTarget);

    const chatElement = this.element.closest('[data-group-chat-id]');
    if (chatElement) {
      this.groupChatId = chatElement.dataset.groupChatId;
      console.log("Group Chat ID:", this.groupChatId);

      this.groupChatChannel = consumer.subscriptions.create(
        { channel: "GroupChatChannel", group_chat_id: this.groupChatId },
        {
          connected: this.connected.bind(this),
          disconnected: this.disconnected.bind(this),
          received: this.received.bind(this),
        }
      );

      console.log("Group Chat Channel initialized:", this.groupChatChannel);
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
        group_chat_id: this.groupChatId  // ここでgroup_chat_idが正しく設定されているか確認
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

  // エンターキーのハンドリング
  handleEnterKey(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      this.sendMessage(event);
    }
  }
}
