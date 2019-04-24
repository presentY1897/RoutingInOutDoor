const { Pool, Client } = require('pg')

const pool = new Pool({
    host:'localhost', port: 5432, database:'its_sample', user:'postgres', password: 'all1234'})

pool.query('SELECT NOW()', (err, res) => {
  console.log(err, res)
  pool.end()
})

const client = new Client({
    host:'localhost', port: 5432, database:'its_sample', user:'postgres', password: 'all1234'})
client.connect()

client.query('SELECT NOW()', (err, res) => {
  console.log(err, res)
  client.end()
})