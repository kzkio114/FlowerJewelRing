// tooltip_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tooltip"];

  connect() {
    this.tooltipElement = null;
  }

  show(event) {
    const tooltipText = this.element.getAttribute('data-tooltip');
    const targetImageName = this.element.getAttribute('data-tooltip-target');
    const targetImage = document.querySelector(`[data-rendering-target="${targetImageName}"]`);

    if (tooltipText && targetImage) {

      this.hide();


      this.tooltipElement = document.createElement('div');
      this.tooltipElement.className = 'custom-tooltip-content';
      this.tooltipElement.textContent = tooltipText;


      const rect = targetImage.getBoundingClientRect();
      this.tooltipElement.style.position = 'absolute';
      this.tooltipElement.style.top = `${rect.bottom + window.scrollY}px`;
      this.tooltipElement.style.left = `${rect.left + window.scrollX}px`;
      this.tooltipElement.style.background = '#333';
      this.tooltipElement.style.color = '#fff';
      this.tooltipElement.style.padding = '5px 10px';
      this.tooltipElement.style.borderRadius = '5px';
      this.tooltipElement.style.whiteSpace = 'nowrap';
      this.tooltipElement.style.fontSize = '0.875rem';
      this.tooltipElement.style.zIndex = '1000';

      document.body.appendChild(this.tooltipElement);
    }
  }

  hide() {
    if (this.tooltipElement) {
      this.tooltipElement.remove();
      this.tooltipElement = null;
    }
  }
}
