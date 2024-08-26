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
          connected: this.connected.bind(this),
          disconnected: this.disconnected.bind(this),
          received: this.received.bind(this),
        }
      );
    } else {
      console.error("Group Chat element not found");
    }

    // ページロード時に削除ボタンを設定
    this.setDeleteButtonsVisibility();
  }

  connected() {
    console.log(`Connected to GroupChatChannel with ID: ${this.groupChatId}`);
  }

  disconnected() {
    console.log(`Disconnected from GroupChatChannel with ID: ${this.groupChatId}`);
  }

  received(data) {
    if (data.action === 'error' && data.errors) {
      this.displayErrors(data.errors);
    } else if (data.action === "create" && data.message_html) {
      this.addMessageToChat(data.message_html);
    } else if (data.action === "destroy" && data.message_id) {
      this.removeMessageFromChat(data.message_id);
    }
  }

  addMessageToChat(messageHtml) {
    if (this.hasGroupMessagesTarget) {
      this.groupMessagesTarget.insertAdjacentHTML("beforeend", messageHtml);
      this.groupMessagesTarget.scrollTop = this.groupMessagesTarget.scrollHeight;
  
      const currentUserId = document.querySelector('[data-current-user-id]').dataset.currentUserId;
      const messageElement = this.groupMessagesTarget.lastElementChild;
      const messageUserId = messageElement.dataset.messageUserId;
  
      if (currentUserId === messageUserId) {
        const deleteButton = messageElement.querySelector('.delete-chat-button');
        if (deleteButton) {
          deleteButton.style.display = 'block'; // 現在のユーザーが送信したメッセージの場合、削除ボタンを表示
        }
        this.groupInputTarget.value = ""; // メッセージ送信後に入力フィールドをクリア
      }
    } else {
      console.error("GroupMessages target not found. Cannot insert new message.");
    }
  }

  removeMessageFromChat(messageId) {
    const messageElement = document.getElementById(`message_${messageId}`);
    if (messageElement) {
      messageElement.remove();
    }
  }

  sendMessage(event) {
    event.preventDefault(); // フォーム送信のデフォルト動作を防止
  
    if (!this.hasGroupInputTarget) {
      console.error("groupInputTarget is not defined.");
      return;
    }
  
    const message = this.groupInputTarget.value.trim();
    if (message) {
      this.groupChatChannel.perform("speak", {
        message: message,
        group_chat_id: this.groupChatId
      });
      this.groupInputTarget.value = ""; // 入力フィールドをクリア
    } else {
      console.error("Message is empty or not a string.");
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

  displayErrors(errors) {
    const errorMessagesDiv = document.getElementById('error-messages');
    if (errorMessagesDiv) {
      errorMessagesDiv.innerHTML = errors.join("<br>");
      errorMessagesDiv.style.display = 'block';
    }
  }

  // ページロード時に削除ボタンの表示を設定
  setDeleteButtonsVisibility() {
    const currentUserId = document.querySelector('[data-current-user-id]').dataset.currentUserId;

    this.groupMessagesTarget.querySelectorAll('[data-message-user-id]').forEach(messageElement => {
      const messageUserId = messageElement.dataset.messageUserId;
      const deleteButton = messageElement.querySelector('.delete-chat-button');

      if (currentUserId === messageUserId && deleteButton) {
        deleteButton.style.display = 'block'; // 削除ボタンを表示
      }
    });
  }
}
