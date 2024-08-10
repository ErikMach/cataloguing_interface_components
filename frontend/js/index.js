document.body.parentElement.classList.add([
    "ayu",
    "light",
    "chopchop",
    "babyChop",
    "darkRed",
    "poshLetter",
    "CarolsRed"
][6]);

/*** KEYWORD TAGS ***/
/*
class TagBox extends HTMLDivElement {
  constructor() {
    super();
// Add a tag => showModal thingo 
  }
  connectedCallback() {

  }
}
customElements.define("tag-box", tagBox, {extends: "div"});

let progressListBox = document.getElementsByClassName("listBox")[0];

let progressSteps = [
  "Original Source",
  "Save Score",
  "Convert to Sibelius",
  "Sibeius Corrections",
  "Carl's artistic additions",
  "Proper Formatting",
  "Convert to PDF"
];

progressSteps.forEach(step => {
  progressListBox.appendChild(new ProgressStep(step));
});
*/



/*** METADATA FIELDS ***/

class MetadataInput extends HTMLInputElement {
  constructor(placeholder) {
    super();
    this.type = "text";
    this.spellcheck = "off";
    this.placeholder = placeholder;
  }
  connectedCallback() {
    this.addEventListener("keydown", this.enterBlur.bind(this));
  }
  enterBlur(e) {
    if (e.key === "Enter") {
      this.blur();
    }
  }
}
customElements.define("metadata-input", MetadataInput, {extends: "input"});

let workDetailsCont = document.getElementsByClassName("workDetails")[0];

let metadataFields = [
  "Major work title",
  "Song Name",
  "Character(s)",
  "Voice type(s)",
  "Text Incipit",
  "Original Language",
  "Original Key",
  "Key",
  "Additional Instruments",
];

metadataFields.forEach(field => {
  workDetailsCont.appendChild(new MetadataInput(field));
});



/*** VARIATIONS ***/

  let vars = document.getElementsByClassName("var");
  for (let i=0; i<vars.length; i++) {
    vars[i].addEventListener("click", () => {
      if (vars[i].classList.contains("selected")) {
	return;
      }
      document.getElementsByClassName("var selected")[0].classList.remove("selected");
      vars[i].classList.add("selected");
    });
  }



/*** Page navigation animation ***/

const hexToRgb = (hexStr) => {
  return "rgb(" + +`0x${hexStr.slice(0,2)}` + ", " + +`0x${hexStr.slice(2,4)}` + ", " + +`0x${hexStr.slice(4,6)}` + ")";
};

let a = getComputedStyle(document.body);
let bw = +a.getPropertyValue("--page-menu-border-width").slice(0,-2);
let fh = +a.getPropertyValue("--page-menu-button-margin").slice(0,-2) + +a.getPropertyValue("--page-menu-button-height").slice(0,-2) + 2*a.getPropertyValue("--page-menu-border-width").slice(0,-2);

  let menuItems = document.getElementsByClassName("pageMenu")[0].children;
  for (let i=0; i<menuItems.length; i++) {
    if (menuItems[i].id === "selectedStyle") { continue };
    menuItems[i].addEventListener("click", () => {
      if (menuItems[i].classList.contains("selected")) {
	return;
      }
      menuItems[i].parentElement.getElementsByClassName("selected")[0]?.classList.remove("selected");
      menuItems[i].classList.add("selected");
      document.getElementById("selectedStyle").style.top = (i * fh) - bw + "px";
    });
  }
  menuItems[1].click();

/*
// Example data
const data = {
    Details: {
	UEDR: 123456,
	Variation_num: 00,
	Filename: "CHRIST Jesus - Australian Summer - A Really Hot Day - Violetta"
    },
    Composer: {
	Name: "Jesus Christ",
	Dates: "0-33"
    },
    Librettist: {
	Name: "Arnold Palmer",
	Dates: "1836-1904"
    },
    Work details: {
	Major_Work_name: "Australian Summer",
	Song_name: "A Really Hot Day",
	Character_name(s): "Violetta",
	Voice_type(s): ["Soprano", "Castrato", "Bass"],
	Original_Key: "C# Minor",
	Key: "C# Minor",
	Text_Incipit: ["What a hot day", "I sweating buckets"],
	Additional_Instruments: ['trumpet', 'flute']
    },
    Progress: {
	Status: 5/6,
	og_url: 'https://www.muscialion.com/song#1',
	Sibelius/PDF_locations: "",
	Notes: "Fix stemming in B section"
    },
    Tags (descriptors): [
	'baroque',
	'chinese'
    ],
    Rank: 42
};
*/
// Data Page, Editing Page, (Meta)Data Page...

class Page extends HTMLDivElement {
  constructor() {
    super();
  }
}

// Pretty much a class per object within "data"