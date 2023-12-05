const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: process.env.DB_USERNAME,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
});

// 쿼리 실행 예시
pool.query("SELECT * FROM test_table", (err, res) => {
  console.log(res.rows);
  console.log(arrayToObj(res.rows));
  pool.end();
});

const arrayToObj = (array) => {
  return array.reduce((obj, item) => {
    obj[item.id] = item.name;
    return obj;
  }, {});
};

// INSERT, UPDATE, DELETE 쿼리 실행 예시
const text = "INSERT INTO your_table(name, email) VALUES($1, $2) RETURNING *";
const values = ["brianc", "brian.m.carlson@gmail.com"];

// pool.query(text, values, (err, res) => {
//   if (err) {
//     console.log(err.stack);
//   } else {
//     console.log(res.rows[0]);
//   }
// });
