/**
 * find all canisters that are controlled by a specific controller principal Id
 */
const https = require('https');
const domain = 'https://ic-api.internetcomputer.org/api/v3/canisters';

if(process.argv.length < 3) {
  console.log('Usage: node index.js <controller_id>');
  process.exit(1);
}

const controller = process.argv[2];
const url = `${domain}?controller_id=${controller}`;

https.get(url, res => {
  let data = '';
  res.on('data', chunk => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      let json = JSON.parse(data);
      console.log('Test',json);
  } catch (error) {
      console.error(error.message);
  };
  });
}).on('error', err => {
  console.log('Error: ', err.message);
});
