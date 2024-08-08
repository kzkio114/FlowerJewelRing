import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modalContainer", "modalImage", "modalContent"];

  open(event) {
    const imgSrc = event.currentTarget.src;
    this.modalImageTarget.src = imgSrc;
    this.modalContainerTarget.classList.add("is-active");
    this.modalImageTarget.addEventListener("click", this.close.bind(this));
  }

  close() {
    this.modalContainerTarget.classList.remove("is-active");
    this.modalImageTarget.src = "";

    // イベントリスナーを削除してクリーンアップ
    this.modalImageTarget.removeEventListener("click", this.close.bind(this));
  }
}