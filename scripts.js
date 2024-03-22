//-----Not server side Javascript---------
function sortTableByColumn(columnName) {
    var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
    table = document.getElementById("csvTable");
    switching = true;
    dir = "asc"; // Set the sorting direction to ascending:

    while (switching) {
        switching = false;
        rows = table.getElementsByTagName("TR");
        for (i = 1; i < rows.length - 1; i++) {
            shouldSwitch = false;
            x = rows[i].querySelector("[data-column='" + columnName + "']");
            y = rows[i + 1].querySelector("[data-column='" + columnName + "']");
            if (dir == "asc") {
                if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                    shouldSwitch = true;
                    break;
                }
            } else if (dir == "desc") {
                if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                    shouldSwitch = true;
                    break;
                }
            }
        }
        if (shouldSwitch) {
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
            switchcount++;
        } else {
            if (switchcount == 0 && dir == "asc") {
                dir = "desc";
                switching = true;
            }
        }
    }
}

function downloadTableAsXLS() {
    // Select the table you want to download
    var table = document.getElementById('csvTable');
    var html = table.outerHTML;
  
    // Create a fake HTML document with the table embedded
    var htmlDocument = `
      <html>
        <head>
          <meta charset='utf-8'>
        </head>
        <body>
          ${html}
        </body>
      </html>
    `;
  
    // Download as .xls
    var fileName = 'table.xls';
    var blob = new Blob([htmlDocument], {
      type: 'application/vnd.ms-excel'
    });
    
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    a.click();
    
    URL.revokeObjectURL(url);
  }