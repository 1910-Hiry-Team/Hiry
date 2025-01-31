import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    apiKey: String,
  };

  static targets = ["address"];

  connect() {
    if (!this.apiKeyValue) {
      console.error("Mapbox API key is missing.");
      return;
    }

    this.initAutocomplete();
  }

  initAutocomplete() {
    const input = this.addressTarget;

    // Use Mapbox's API to fetch autocomplete suggestions
    input.addEventListener("input", async (event) => {
      const query = event.target.value;

      if (query.length < 3) {
        this.clearSuggestions();
        return;
      }

      try {
        const response = await fetch(
          `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(
            query
          )}.json?access_token=${this.apiKeyValue}`
        );

        const data = await response.json();
        this.showSuggestions(data.features);
      } catch (error) {
        console.error("Error fetching address suggestions:", error);
      }
    });
  }

  showSuggestions(suggestions) {
    // Clear existing suggestions
    this.clearSuggestions();

    const dropdown = document.createElement("ul");
    dropdown.classList.add("autocomplete-dropdown");

    suggestions.forEach((suggestion) => {
      const li = document.createElement("li");
      li.textContent = suggestion.place_name;
      li.addEventListener("click", () => {
        this.addressTarget.value = suggestion.place_name;
        this.clearSuggestions();
      });

      dropdown.appendChild(li);
    });

    this.addressTarget.parentNode.appendChild(dropdown);
  }

  clearSuggestions() {
    const dropdown = this.addressTarget.parentNode.querySelector(
      ".autocomplete-dropdown"
    );
    if (dropdown) {
      dropdown.remove();
    }
  }
}
