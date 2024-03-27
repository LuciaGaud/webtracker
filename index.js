const express = require("express");
const cors = require("cors");
const multer = require("multer");
const { urlencoded } = require("body-parser"); //to get the post result from the html and more
const upload = multer({ dest: "uploads/" });
const registered = [];
const bcrypt = require("bcrypt");
const fs = require("fs");
const fs2 = require("node:fs/promises"); //promise based
const csv = require("async-csv");
const ObjectsToCsv = require("objects-to-csv");
const path = require("path");
const Papa = require("papaparse");
require("dotenv").config();
const sql = require("mssql");
const app = express();
const config = {
    user: process.env.USER,
    password: process.env.PASSWORD,
    server: process.env.SERVER,
    database: process.env.DATABASE,
    options: {
        encrypt: true,
        trustServerCertificate: true, // Change this to false in production!!!
    },
};

app.set("view engine", "ejs");
app.use(express.json());
app.use(cors());
//app.use(multer);
app.use("/public", express.static(process.cwd() + "/public"));
app.use(express.urlencoded({ extended: true })); // In short this makes req.body possible


app.get("/data", function (req, res) {
    // connect to your database
    sql.connect(config, function (err) {
        if (err) {
            console.log(err);
            return res.status(500).send("Failed to connect to the database");
        }

        var request = new sql.Request(); // create Request object

        request.query("select * from Users", function (err, recordset) {
            // query to the database and get the records
            if (err) console.log(err);

            // send records as a response
            res.send(recordset);
        });
    });
});

app.get("/", function (req, res) {
    res.sendFile(process.cwd() + "/views/index.html");
});
app.get("/scripts.js", function (req, res) {
    res.sendFile(process.cwd() + "/scripts.js");
});
app.get("/views/logo.jpg", function (req, res) {
    res.sendFile(process.cwd() + "/views/logo.jpg");
});
//--------------Login-----------------
app.post("/loggedin", async function (req, res) {
    console.log("I received a post request on /loggedin");

    sql.connect(config, async function (err) {
        // connect to your database
        if (err) console.log(err);

        var request = new sql.Request(); // create Request object

        const query = `     
        SELECT  CompanyCode,Email,Password,Salt,Active
        FROM Users
        WHERE Email = @email
    `; // query to the database and get the records

        request.input("email", sql.NVarChar(50), req.body.email);
        const result = await request.query(query);
        await sql.close;

        try {
            if (result.recordset[0].Active == 0) {
                res.send(
                    "Please contact an admin at ICL to activate your accout"
                );
                return;
            }

            if (result.recordset[0].Password == null) {
                res.send("no user found");
                return;
            }

            const valid = await bcrypt.compare(
                req.body.password,
                result.recordset[0].Password
            );
            console.log(valid);
            if (valid) {
                //console.log("user id is ", req.session.userId,"result.recordset[0].email is",result.recordset[0].Email);
                const company = result.recordset[0].CompanyCode;
                console.log("You are loggedn into the company:", company);
                const fileName = await findNewestCsv("./data");
                const content = fs.readFileSync("data/" + fileName, "utf8");
                const filteredData = processCSVdata(content, company);
                res.render("entries", { data: filteredData });
            }

            //   res.sendFile(process.cwd() + "/views/entries.ejs")
        } catch {
            console.log("No username and/or massword match");
            res.status(500).send("no user name or password matched");
        }
    });
});
//-------------Registration endpoint-----------------

app.post("/registered", async function (req, res) {
    console.log("email is ", req.body.email);
    const hashedPassword = await bcrypt.hash(req.body.password, 10);
    console.log("I received a post request on /registered");
    sql.connect(config, async function (err) {
        if (err) {
            console.log(err);
            return res.status(500).send("Failed to connect to the database");
        }
        // create Request object
        var request = new sql.Request();
        // query to the database and get the records
        const query = `
        INSERT INTO Users (CompanyCode,Email,Password)
        VALUES (@companyCode,@email,@hashedPassword)
    `;
        request.input("companyCode", sql.NVarChar(50), req.body.companyCode);
        request.input("email", sql.NVarChar(50), req.body.email);
        request.input("hashedPassword", sql.NVarChar, hashedPassword);
        const result = await request.query(query);
        await sql.close();
        res.send(
            "You are registered. Please contact and ICL admit for your account to be activated"
        );
    });
});


const port = process.env.PORT || 3000;
app.listen(port, function () {
    console.log("Your app is listening on port " + port);
});

//################Functions##########################
//A function which will parse the csv, filter by company and manipulate the Entry type to show only the MRN
function processCSVdata(content, company) {
    const parsedCSV = Papa.parse(content, {
        header: true,
        complete: async function (result) {
            console.log("I have parsed the CSV");
        },
    });

    const filteredData = parsedCSV.data
        .filter(function (row) {
            return row.Carrier === company;
        })
        .map(function (row) {
            const entryParts = row["MRN"].split(" ");
            if (entryParts.length >= 3) {
                row["MRN"] = entryParts[1];
            } else {
                row["MRN"] = ""; // Assign some default value or leave it empty if MRN cannot be parsed
            }
            return row;
        }); // here ends complete()
    return filteredData;
}

//A function which returns the newest csv file in a folder
async function findNewestCsv(dirPath) {
    try {
        const stat = await fs2.stat(dirPath);
        console.log("the stat object is", stat);
        if (!stat.isDirectory()) {
            throw new Error("Path is not a directory");
        }
        const files = await fs2.readdir(dirPath);
        let newest = null;
        let latestTime = 0;
        // Iterate through each file in the directory
        for (const file of files) {
            if (path.extname(file).toLowerCase() === ".csv") {
                const filePath = path.join(dirPath, file);
                const fileStat = await fs2.stat(filePath);

                // Update newest file if this file is newer
                if (fileStat.mtime.getTime() > latestTime) {
                    newest = file;
                    console.log("latest file is", file);
                    latestTime = fileStat.mtime.getTime();
                }
            }
        }
        // Check if we found a CSV file
        if (newest === null) {
            throw new Error("No CSV files found");
        }

        return newest;
    } catch (err) {
        throw err; // Rethrow any errors encountered
    }
}
//----------Sorting function for the table--------------------
function sortTableByColumn(columnName) {
    var table,
        rows,
        switching,
        i,
        x,
        y,
        shouldSwitch,
        dir,
        switchcount = 0;
    table = document.getElementById("myTable");
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
