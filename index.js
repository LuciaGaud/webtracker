var express = require("express");
var cors = require("cors");
var multer = require("multer");
const { urlencoded } = require("body-parser"); //to get the post result from the html and more
const upload = multer({ dest: "uploads/" });
const registered = [];
const bcrypt = require("bcrypt");
require("dotenv").config();
var sql = require("mssql");
var app = express();
var config = {
  user: process.env.USER,
  password: process.env.PASSWORD,
  server: process.env.SERVER,
  database: process.env.DATABASE,
  options: {
    encrypt: true,
    trustServerCertificate: true, // Change this to false in production!!!
  },
};

app.use(express.json());
app.use(cors());
//app.use(multer);
app.use("/public", express.static(process.cwd() + "/public"));
app.use(express.urlencoded({ extended: true })); // In short this makes req.body possible

app.get("/data", function (req, res) {
  // connect to your database
  sql.connect(config, function (err) {
    if (err) console.log(err);

    // create Request object
    var request = new sql.Request();

    // query to the database and get the records
    request.query("select * from Users", function (err, recordset) {
      if (err) console.log(err);

      // send records as a response
      res.send(recordset);
    });
  });
});

app.get("/", function (req, res) {
  res.sendFile(process.cwd() + "/views/index.html");
});

app.get("/views/logo.jpg", function (req, res) {
  res.sendFile(process.cwd() + "/views/logo.jpg");
});

app.post("/loggedin", async function (req, res) {
  console.log("email is ", req.body.email);
  console.log("the password is", req.body.password); // To remove in production!!!
  console.log("I received a post request on /loggedin");
  // connect to your database

  sql.connect(config, async function (err) {
    if (err) console.log(err);

    // create Request object
    var request = new sql.Request();

    // query to the database and get the records
    const query = `
        SELECT  CompanyCode,Email,Password,Salt
        FROM Users
        WHERE Email = @email
    `;
  
    request.input("email", sql.NVarChar(50), req.body.email);
    const result = await request.query(query);
    await sql.close;
    console.log(result.recordset[0]);

    

    try{
      console.log(result.recordset[0].Password);
        if (result.recordset[0].Password == null){
         res.send("no user found");
          rertun;}
         const valid = await bcrypt.compare(req.body.password, result.recordset[0].Password); console.log(valid);
        if (valid){
          console.log("You are logged in");
          res.send("you are logged in");
    }  
        } catch{
          console.log("No username and/or massword match")
          res.status(500).send("no user name or password matched")
        }

   
    
   
  });
});

app.post("/registered", async function (req, res) {
  console.log("email is ", req.body.email);
  //const salt = await bcrypt.genSalt(10);
  //console.log("the salt is", salt);
  console.log("the password is", req.body.password); // To remove in production!!!

  const hashedPassword = await bcrypt.hash(req.body.password, 10);
  console.log("the hasedPassword is", hashedPassword);

  console.log("I received a post request on /registered");
  // connect to your database

  sql.connect(config, async function (err) {
    if (err) console.log(err);

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
    //request.input("salt", sql.NChar(50), salt);
    //req.body.companyCode','req.body.email','hashedPassword', 'salt'
    const result = await request.query(query);
    console.log(result);
    await sql.close;
    res.send("You are registered");
  });
});

const port = process.env.PORT || 3000;
app.listen(port, function () {
  console.log("Your app is listening on port " + port);
});
