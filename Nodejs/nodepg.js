const { Pool, Client } = require('pg');

const pool = new Pool({
    host:'localhost', port: 5432, database:'OutDoor', user:'postgres', password: 'all1234'});
const client = new Client({
    host:'localhost', port: 5432, database:'OutDoor', user:'postgres', password: 'all1234'});

const text = 'INSERT INTO public.\"BUS_ROUTE\"\(\"Route_Id\", \"Rout_Name\", \"corpNm\", \"edStationNm\", \"stStationNm\", term, \"firstBusTm\", \"routeType\"\) VALUES($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *';
const values = ['0','0','0','0','0','0','0','0'];
//const sql = `SELECT 1 AS "\\'/*", 2 AS "\\'*/\n + console.log(process.env)] = null;\n//"`

// client.query(sql, (err, res) => {
//     client.end()
// })

// callback

values.forEach(function(element) {
pool.query(text, values, (err, res) => {
    if (err) {
        console.log(err.stack)
    } else {
        console.log(res.rows[0])
        console.log('insert ')
        // { name: 'brianc', email: 'brian.m.carlson@gmail.com' }
    }
})});