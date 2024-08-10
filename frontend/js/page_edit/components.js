/*** PROGRESS List Items ***/


/**
 * Creates a checkbox and label for a progress list item
 * N.B. progress  in the title is done in CSS
 * @param labelText:	text describing the progress step
 */
class ProgressListItem extends HTMLDivElement {
  static itemCount = 0;
  #index = ProgressListItem.itemCount++;

  constructor(labelText) {
    super();

    this.classList.add("progressStep");

    this.input = document.createElement("input");
    this.input.id = labelText.split(/\s/g)[0] + this.#index;
    this.input.type = "checkbox";

    this.label = document.createElement("label");
    this.label.setAttribute("for", labelText.split(/\s/g)[0] + this.#index);
    this.label.textContent = labelText;

    this.appendChild(this.input);
    this.appendChild(this.label);
  }
}
customElements.define("progress-list-item", ProgressListItem, {extends: "div"});

/* Add progressListItems to progressLisBox */
const progressListItems = [
  "Original Source",
  "Save Score",
  "Convert to Sibelius",
  "Sibeius Corrections",
  "Carl's artistic additions",
  "Proper Formatting",
  "Convert to PDF"
];
const progressListBox = document.getElementsByClassName("listBox")[0];
progressListItems.forEach(itemText => {
  progressListBox.appendChild(new ProgressListItem(itemText));
});
