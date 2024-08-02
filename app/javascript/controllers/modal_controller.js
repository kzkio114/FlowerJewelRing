// modal_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modalContainer", "modalImage"];

  open(event) {
    const imgSrc = event.currentTarget.src;
    this.modalImageTarget.src = imgSrc;
    this.modalContainerTarget.classList.add("is-active");
  }

  close() {
    this.modalContainerTarget.classList.remove("is-active");
    this.modalImageTarget.src = "";
  }
}
