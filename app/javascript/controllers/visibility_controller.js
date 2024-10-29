import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bg"]

  connect() {
    this.CLASSNAME_VISIBLE = "-visible";
    this.CLASSNAME_INVISIBLE = "-invisible";
    this.CLASSNAME_MORNING = "-morning";
    this.TIMEOUT_VISIBLE = 4000;
    this.TIMEOUT_INVISIBLE = 4000;
    this.TIMEOUT_MORNING = 8000;

    this.toggleVisibility();
  }

  toggleVisibility() {
    this.bgTarget.classList.add(this.CLASSNAME_VISIBLE);

    setTimeout(() => {
      this.bgTarget.classList.remove(this.CLASSNAME_VISIBLE);
      this.bgTarget.classList.add(this.CLASSNAME_INVISIBLE);

      setTimeout(() => {
        this.bgTarget.classList.remove(this.CLASSNAME_INVISIBLE);
        this.bgTarget.classList.add(this.CLASSNAME_MORNING);
      }, this.TIMEOUT_INVISIBLE);
    }, this.TIMEOUT_VISIBLE);
  }
}
