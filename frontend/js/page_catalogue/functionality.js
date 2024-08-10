/*
store 5 most recent searches in locaStorage
expand catalogue reult row to show variations

*/

class CatalogueTableRow extends HTMLTableRowElement {
  constructor(data) {
    super();
    this.dataFields = Object.values(data);
    if (this.dataFields.length !== 7) {
	console.error("Attempted to construct table row from incorrect data", data);
    }
    this.dataFields.forEach(fieldText => {
      let row = document.createElement("td");
      row.textContent = fieldText;
      this.appendChild(row);
    });
  }
}
customElements.define("catalogue-table-row", CatalogueTableRow, { extends: "tr"})

fakeSearchResults = [
  {UEDR: 123456, variation: 1, filename: "È strano - Ah fors'è lui - Sempre libera", composer: "VERDI Giuseppe", voice: "soprano", progress: 6, importance: 5},
  {UEDR: 123456, variation: 2, filename: "È strano - Ah fors'è lui - Sempre libera", composer: "VERDI Giuseppe", voice: "mezzo", progress: 2, importance: 2},
  {UEDR: 123456, variation: 3, filename: "È strano - Ah fors'è lui - Sempre libera", composer: "VERDI Giuseppe", voice: "alto", progress: 3, importance: 2},
  {UEDR: 123456, variation: 4, filename: "È strano - Ah fors'è lui - Sempre libera", composer: "VERDI Giuseppe", voice: "piano", progress: 4, importance: 5},
  {UEDR: 123456, variation: 9, filename: "È strano - Ah fors'è lui - Sempre libera", composer: "VERDI Giuseppe", voice: "trumpet", progress: 0, importance: 1},
  {UEDR: 000200, variation: 1, filename: "Wo kDAk Eod", composer: "BEETHOVEN Ludwig Van", voice: "soprano", progress: 0, importance: 2},
  {UEDR: 948130, variation: 1, filename: "Cinque, Dieci - La Noce Di Figaro", composer: "MOZART Wolfgang", voice: "soprano", progress: 4, importance: 3},
  {UEDR: 189231, variation: 1, filename: "Applesaus", composer: "DEADmau5", voice: "soprano", progress: 5, importance: 2},
  {UEDR: 003182, variation: 1, filename: "Extremely Bold", composer: "Bach TheGoodOne", voice: "soprano", progress: 2, importance: 1},
  {UEDR: 004826, variation: 1, filename: "Foasidoi", composer: "MORANDI Gianni", voice: "soprano", progress: 5, importance: 4},
  {UEDR: 000130, variation: 1, filename: "Mi Fa Volare", composer: "SWIFT Taytay", voice: "soprano", progress: 1, importance: 5}
];

function fakeSearchFilter() {

}


function populateTable(data) {
  const table = document.getElementsByClassName("catalogueTable")[0];
  data.forEach(entry => {
    table.children[0].appendChild(new CatalogueTableRow(entry));
  });
}

populateTable(fakeSearchResults);