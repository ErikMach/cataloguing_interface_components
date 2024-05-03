const catalogueTableStyle = new CSSStyleSheet();
catalogueTableStyle.replaceSync(`
:host {
  display: block;
  width: 900px;
  border: 2px solid black;
}
table {
  width: 80%;
  border: 2px solid;
}
th {
  cursor: pointer;
}
th.sorting {
  background-color: gray;
}
`);

/*
 * Header row stays fixed with scrolling
 * each header row calls its own `sort` function (or `sort` with its own argument)
 * scoped and styled
 * yeah
 */
class CatalogueTable extends HTMLElement {
  constructor() {
    super();
    this.shadow = this.attachShadow({ mode: "closed" });
    this.shadow.adoptedStyleSheets = [catalogueTableStyle];

    this.table = document.createElement("table");
    this.shadow.appendChild(this.table);

    this.initTH();
    this.create10Rows();
  }
  initTH() {
    const firstRow = document.createElement("tr");
    const headings = [
      "Catalogue #",
      "Composer",
      "Song",
      "Progress"
    ];
    headings.forEach((heading, i) => {
      let th = document.createElement("th");
      th.textContent = heading;
      th.addEventListener("click", () => {
	this.sortRows.bind(this)(i);
      });
      firstRow.appendChild(th);
    });
    this.table.appendChild(firstRow);
  }
  sortRows(colNum) {
    this.table.getElementsByClassName("sorting")[0]?.classList.remove("sorting");
    this.table.getElementsByTagName("th")[colNum].classList.add("sorting");
    colNum++;
    console.log(`The table rows will be sorted by the ${colNum}${colNum % 10 === 1 ? "st" : colNum % 10 === 2 ? "nd": colNum % 10 === 3 ? "rd" : "th"} column!`);
  }
  create10Rows() {
    for (let i=0; i<10; i++) {
      let r = this.table.insertRow(-1);
    }
  }
/*
 * I don't know how this will work...
 * if there are up to 100K rows, surely it would be done bit-by-bit from the server
 * i.e. get the first 200 entries (for whatever sort/search parameters) and display them
 * so... how this table is implemented would depend on how the database works
 *
 * what I *can* do, is the style and layout
 */
}
customElements.define("catalogue-table", CatalogueTable);

document.body.appendChild(new CatalogueTable());