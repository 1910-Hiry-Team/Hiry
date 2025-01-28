import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["tabButton", "tabContent"]

  connect() {
    console.log("connected")
  }

  fire(event) {
    event.preventDefault();

    // Ensure all tab buttons lose the active class
    this.tabButtonTargets.forEach((button) => {
      button.classList.remove("active");
    });

    // Ensure all tab content sections are hidden
    this.tabContentTargets.forEach((content) => {
      content.classList.add("d-none");
    });

    // Add active class to the clicked tab
    const clickedTab = event.currentTarget;
    clickedTab.classList.add("active");

    // Show the content associated with the clicked tab
    const targetSelector = clickedTab.dataset.target;
    const targetContent = this.element.querySelector(targetSelector);

    if (targetContent) {
      targetContent.classList.remove("d-none");
    } else {
      console.error(`No element found for selector: ${targetSelector}`);
    }
  }
}
