import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  next(event) {
    event.preventDefault();
    const url = this.element.dataset.nextUrl;
    fetch(url, { headers: { "Turbo-Frame": "registration_form" } })
      .then(response => response.text())
      .then(html => {
        document.getElementById("registration_form").innerHTML = html;
      });
  }
}
