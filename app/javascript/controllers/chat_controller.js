import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

export default class extends Controller {
  static targets = ["input", "messages", "submitButton"];

  connect() {
    this.chatChannel = consumer.subscriptions.create("ChatChannel", {
      connected: this.connected.bind(this),
      disconnected: this.disconnected.bind(this),
      received: this.received.bind(this),
    });
  }

  connected() {
    console.log("Connected to the chat channel");
  }

  disconnected() {
    console.log("Disconnected from the chat channel");
  }

  received(data) {
    if (data.action === 'error' && data.errors) {
      const errorMessagesDiv = document.getElementById('error-messages');
      if (errorMessagesDiv) {
        errorMessagesDiv.innerHTML = data.errors.join("<br>");
        errorMessagesDiv.style.display = 'block';
      }
    } else if (data.action === 'create' && data.message) {
      this.messagesTarget.innerHTML += data.message;
      if (data.success) {
        this.inputTarget.value = ''; // フィールドをクリア
      }
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight; // スクロール
    } else if (data.action === 'destroy' && data.chat_id) {
      const chatElement = document.getElementById(`chat_${data.chat_id}`);
      if (chatElement) {
        chatElement.remove();
      }
    }
  }

  sendMessage(event) {
    event.preventDefault(); // フォームのデフォルト送信動作を防ぐ
    const errorMessagesDiv = document.getElementById('error-messages');
    if (errorMessagesDiv) {
      errorMessagesDiv.style.display = 'none';
    }
  
    const message = this.inputTarget.value;
    if (message.trim() !== '') {
      this.chatChannel.perform('speak', { message: message, receiver_id: this.inputTarget.dataset.receiverId });
      this.inputTarget.value = ''; // フィールドをクリア
    }
  }

  deleteMessage(event) {
    event.preventDefault();
    const chatId = event.target.dataset.chatId;
    if (chatId) {
      this.chatChannel.perform('delete_message', { chat_id: chatId });
    }
  }
}
