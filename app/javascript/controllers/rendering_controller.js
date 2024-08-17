import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "details", "toggleDetails", "extraContent",
    "news", "worries", "search", "chat", "thanks",
    "newsImage", "worriesImage", "searchImage", "chatImage", "thanksImage",
    "appDescriptionTitle", "appDescriptionText",
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

    this.currentHoverElement = null; // 現在ホバー中の要素を追跡

    // 初期ロード時にタイトルと説明文を一文字ずつ表示する
    this.displayTextSlowly(this.appDescriptionTitleTarget, 50);
    this.displayTextSlowly(this.appDescriptionTextTarget, 50);
  }

  displayTextSlowly(element, speed) {
    if (!element) return;
    const htmlContent = element.innerHTML; // innerHTMLを使用して改行やHTMLタグを取得
    element.innerHTML = ""; // コンテンツをクリア
    let i = 0;
  
    const typing = () => {
      if (i < htmlContent.length) {
        if (htmlContent[i] === "<" && htmlContent.slice(i).startsWith("<br")) {
          // <br>タグを検出して改行を追加
          const endOfTag = htmlContent.indexOf('>', i) + 1;
          const tagContent = htmlContent.slice(i, endOfTag);
          
          // <br>タグのクラスに基づいて処理を分ける
          if (tagContent.includes('class="pc-only"')) {
            if (window.innerWidth > 480) { // PCサイズの時だけ表示
              element.innerHTML += "<br>";
            }
          } else if (tagContent.includes('class="sma"')) {
            if (window.innerWidth <= 480) { // スマホサイズの時だけ表示
              element.innerHTML += "<br>";
            }
          } else {
            element.innerHTML += "<br>"; // 共通の改行
          }
          i = endOfTag;
        } else {
          // それ以外の文字を追加
          element.innerHTML += htmlContent[i];
          i++;
        }
        setTimeout(typing, speed);
      }
    };
    typing();
  }

  showContent(event) {
    const targetId = event.currentTarget.id;
    const targetElement = this.buttonMapping[targetId];
    const targetImage = this.imageMapping[targetId];

    if (targetElement && targetImage) {
      // ホバー状態を設定
      this.currentHoverElement = { targetElement, targetImage };

      // すべての要素を一旦非表示にしてから表示したい要素を表示
      this.hideAllExceptCurrent();

      targetElement.classList.remove("is-hidden");
      targetImage.classList.remove("is-hidden");
      this.extraContentTarget.classList.remove("is-hidden");
    }
  }

  hideContent(event) {
    // ホバーが外れた時の処理は不要
  }

  hideAll() {
    // すべてのセクションと画像を非表示にする
    Object.values(this.buttonMapping).forEach(section => {
      section.classList.add("is-hidden");
    });

    Object.values(this.imageMapping).forEach(image => {
      image.classList.add("is-hidden");
    });

    this.extraContentTarget.classList.add("is-hidden");
  }

  hideAllExceptCurrent() {
    // 現在ホバー中の要素以外を非表示にする
    Object.values(this.buttonMapping).forEach(section => {
      if (!this.currentHoverElement || section !== this.currentHoverElement.targetElement) {
        section.classList.add("is-hidden");
      }
    });

    Object.values(this.imageMapping).forEach(image => {
      if (!this.currentHoverElement || image !== this.currentHoverElement.targetImage) {
        image.classList.add("is-hidden");
      }
    });

    if (!this.currentHoverElement) {
      this.extraContentTarget.classList.add("is-hidden");
    }
  }
}
