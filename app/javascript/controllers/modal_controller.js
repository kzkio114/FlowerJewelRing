import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "image"];

  open(event) {
    const imgSrc = event.currentTarget.src;
    this.imageTarget.src = imgSrc;
    this.containerTarget.classList.add("is-active");
  }

  close() {
    this.containerTarget.classList.remove("is-active");
    this.imageTarget.src = "";
  }
}
