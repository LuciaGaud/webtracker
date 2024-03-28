//-----Not server side Javascript---------
function sortTableByColumn(columnName, tableName) {
    var table = document.getElementById(tableName);
    var headers = table.getElementsByTagName("TH");
    var rows = table.getElementsByTagName("TR");
    var switching = true;
    var shouldSwitch;
    var dir = "asc";
    var switchcount = 0;
    var i, x, y;
    var headerIndex = -1;

    // Remove existing sorting classes from all headers
    for (var j = 0; j < headers.length; j++) {
        headers[j].classList.remove("th-sort-asc", "th-sort-desc");
    }

    // Find the index of the header cell that matches columnName
    for (var i = 0; i < headers.length; i++) {
        if (headers[i].getAttribute('data-column') === columnName) {
            headerIndex = i;
            headers[i].classList.add("th-sort-asc"); // Set the initial sort class
            break;
        }
    }
    
    // If the header cell was not found, exit the function
    if (headerIndex === -1) return;

    while (switching) {
        switching = false; // Start by saying no switching is needed
        for (i = 1; i < (rows.length - 1); i++) {
            shouldSwitch = false; // Start by saying there should be no switching
            x = rows[i].querySelector("[data-column='" + columnName + "']");
            y = rows[i + 1].querySelector("[data-column='" + columnName + "']");

            // Determine if a switch should occur based on the sorting direction
            if ((dir === "asc" && x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) ||
                (dir === "desc" && x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase())) {
                shouldSwitch = true; // Mark that a switch is needed and break out of the loop
                break;
            }
        }
        if (shouldSwitch) {
            // If a switch is needed, perform it and continue the while loop
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
            switchcount++; // Increment the switch count for this pass
        }  else if (switchcount === 0 && dir === "asc") {
            dir = "desc";
            switching = true;
        } else if (switchcount === 0 && dir === "desc") {
            dir = "asc";
            switching = true;    
        }
        // At the end of each pass, update the header classes
if (dir === "asc") {
    th.classList.remove("th-sort-desc");
    th.classList.add("th-sort-asc");
} else {
    th.classList.remove("th-sort-asc");
    th.classList.add("th-sort-desc");
}

    }
}


function downloadTableAsXLS() {
    // Select the table you want to download
    var table = document.getElementById("csvTable");
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
    var fileName = "table.xls";
    var blob = new Blob([htmlDocument], {
        type: "application/vnd.ms-excel",
    });

    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    a.href = url;
    a.download = fileName;
    a.click();

    URL.revokeObjectURL(url);
}
