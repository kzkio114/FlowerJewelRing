// rendering_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "details", "toggleDetails", "extraContent",
    "news", "worries", "search", "chat", "thanks",
    "showNews", "showWorries", "showSearch", "showChat", "showThanks"
  ];

  connect() {
    this.buttonMapping = {
      showNews: this.newsTarget,
      showWorries: this.worriesTarget,
      showSearch: this.searchTarget,
      showChat: this.chatTarget,
      showThanks: this.thanksTarget
    };
  }

  toggleDetails() {
    if (this.detailsTarget.classList.contains("is-hidden")) {
      this.detailsTarget.classList.remove("is-hidden");
      requestAnimationFrame(() => {
        this.detailsTarget.classList.add("is-visible");
      });
      this.toggleDetailsTarget.textContent = "詳細を隠す";
    } else {
      this.detailsTarget.classList.remove("is-visible");
      this.detailsTarget.addEventListener('transitionend', () => {
        this.detailsTarget.classList.add("is-hidden");
      }, { once: true });
      this.toggleDetailsTarget.textContent = "詳細を表示";
    }
  }

  showContent(event) {
    // 全てのセクションを非表示にする
    Object.values(this.buttonMapping).forEach(section => {
      section.classList.add("is-hidden");
    });

    // クリックされたボタンに対応するセクションを表示
    const targetId = event.currentTarget.id;
    const targetElement = this.buttonMapping[targetId];
    if (targetElement) {
      targetElement.classList.remove("is-hidden");
      this.extraContentTarget.classList.remove("is-hidden");
    }
  }
}
