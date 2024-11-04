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

    this.currentHoverElement = null;

    this.displayTextSlowly(this.appDescriptionTitleTarget, 50);
    this.displayTextSlowly(this.appDescriptionTextTarget, 50);
  }

  displayTextSlowly(element, speed) {
    if (!element) return;
    const htmlContent = element.innerHTML;
    element.innerHTML = "";
    let i = 0;
  
    const typing = () => {
      if (i < htmlContent.length) {
        if (htmlContent[i] === "<" && htmlContent.slice(i).startsWith("<br")) {
          const endOfTag = htmlContent.indexOf('>', i) + 1;
          const tagContent = htmlContent.slice(i, endOfTag);
          
          if (tagContent.includes('class="pc-only"')) {
            if (window.innerWidth > 480) {
              element.innerHTML += "<br>";
            }
          } else if (tagContent.includes('class="sma"')) {
            if (window.innerWidth <= 480) {
              element.innerHTML += "<br>";
            }
          } else {
            element.innerHTML += "<br>";
          }
          i = endOfTag;
        } else {
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

      this.currentHoverElement = { targetElement, targetImage };


      this.hideAllExceptCurrent();

      targetElement.classList.remove("is-hidden");
      targetImage.classList.remove("is-hidden");
      this.extraContentTarget.classList.remove("is-hidden");
    }
  }

  hideContent(event) {

  }

  hideAll() {

    Object.values(this.buttonMapping).forEach(section => {
      section.classList.add("is-hidden");
    });

    Object.values(this.imageMapping).forEach(image => {
      image.classList.add("is-hidden");
    });

    this.extraContentTarget.classList.add("is-hidden");
  }

  hideAllExceptCurrent() {

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
