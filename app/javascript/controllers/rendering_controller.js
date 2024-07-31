import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "details", "toggleDetails", "extraContent",
    "news", "worries", "search", "chat", "thanks",
    "newsImage", "worriesImage", "searchImage", "chatImage", "thanksImage"
  ];

  connect() {
    this.buttonMapping = {
      showNews: this.newsTarget,
      showWorries: this.worriesTarget,
      showSearch: this.searchTarget,
      showChat: this.chatTarget,
      showThanks: this.thanksTarget
    };

    this.imageMapping = {
      showNews: this.newsImageTarget,
      showWorries: this.worriesImageTarget,
      showSearch: this.searchImageTarget,
      showChat: this.chatImageTarget,
      showThanks: this.thanksImageTarget
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
    // 全てのセクションと画像を非表示にする
    Object.values(this.buttonMapping).forEach(section => {
      section.classList.add("is-hidden");
    });

    Object.values(this.imageMapping).forEach(image => {
      image.classList.add("is-hidden");
    });

    // クリックされたボタンに対応するセクションと画像を表示
    const targetId = event.currentTarget.id;
    const targetElement = this.buttonMapping[targetId];
    const targetImage = this.imageMapping[targetId];

    if (targetElement && targetImage) {
      targetElement.classList.remove("is-hidden");
      targetImage.classList.remove("is-hidden");
      this.extraContentTarget.classList.remove("is-hidden");

      // クリック時のテキストに変更
      this.activateButtonState(event.currentTarget, "click");
    }
  }

  hoverContent(event) {
    const button = event.currentTarget;
    const hoverText = button.getAttribute("data-hover-text");

    // 元のテキストを保存
    if (!button.hasAttribute("data-original-text")) {
      button.setAttribute("data-original-text", button.textContent);
    }

    // ホバーテキストを表示
    if (hoverText) {
      button.textContent = hoverText;
    }
  }

  resetContent(event) {
    const button = event.currentTarget;
    // ホバーが解除されたときに、元のテキストに戻す
    if (!button.hasAttribute("data-clicked")) {
      const originalText = button.getAttribute("data-original-text");
      if (originalText) {
        button.textContent = originalText;
      }
    }
  }

  activateButtonState(button, type) {
    if (button) {
      if (type === "click") {
        button.setAttribute("data-clicked", "true"); // クリック状態を記録
        const clickText = button.getAttribute("data-click-text");
        if (clickText) {
          button.textContent = clickText;
        }
      } else {
        const hoverText = button.getAttribute("data-hover-text");
        if (hoverText) {
          button.textContent = hoverText;
        }
      }
    }
  }
}
