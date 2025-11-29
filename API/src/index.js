const axios = require("axios");
const express = require("express");
const app = express();

app.use(express.json());

app.post("/base64", async (req, res) => {
  axios
    .get(req.body["file"], {
      responseType: "arraybuffer",
    })
    .then(function (response) {
      const base64 = Buffer.from(response.data).toString("base64");

      /*const chunks = [];
      for (let i = 0; i < base64.length; i += 10_000) {
        chunks.push(base64.slice(i, i + 10_000));
      }
        -> I know I'll never use this but I sometimes jinx myself*/

      res.send(base64);
    });
});

app.listen(3000, () => {
  console.log("Listening on port 3000");
});