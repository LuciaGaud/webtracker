var express = require('express');
var cors = require('cors');
var multer = require('multer');
const { urlencoded } = require("body-parser"); //to get the post result from the html and more
const upload = multer({ dest: 'uploads/' });
require('dotenv').config();
var sql = require("mssql");
var app = express();


app.get('/data', function (req,res) {
  var config ={
    user: process.env.USER,
    password: process.env.PASSWORD,
    server: process.env.SERVER, 
    database: process.env.DATABASE,
      options: {
      encrypt: true,
      trustServerCertificate: true // Change this to false in production!!!
  }
  };


      // connect to your database
      sql.connect(config, function (err) {
    
        if (err) console.log(err);

        // create Request object
        var request = new sql.Request();
           
        // query to the database and get the records
        request.query('select * from Users', function (err, recordset) {
            
            if (err) console.log(err)

            // send records as a response
            res.send(recordset);
            
        });
    });
})



app.use(cors());
//app.use(multer);
app.use('/public', express.static(process.cwd() + '/public'));
app.use(express.urlencoded({ extended: true })); // In short this makes req.body possible

app.get('/', function (req, res) {
  res.sendFile(process.cwd() + '/views/index.html');
});

app.get('/views/logo.jpg', function (req, res) {
  res.sendFile(process.cwd() + '/views/logo.jpg');
});

app.get('/data', function(req,res) {

})



const port = process.env.PORT || 3000;
app.listen(port, function () {
  console.log('Your app is listening on port ' + port)
});
