/**
 * get all subnets
 */
const https = require('https');

const domain = 'https://ic-api.internetcomputer.org/api/v3/subnets';

const url = `${domain}?format=json`;

function getSubnetList(json) {
  let subnets = json.subnets.map(subnet => subnet.subnet_id)
  return subnets;
};

async function main() {
  https.get(url, res => {
    let data = '';
    res.on('data', chunk => {
      data += chunk;
    });

    res.on('end', () => {
      try {
        let json = JSON.parse(data);
        let allSubnets = getSubnetList(json);

        console.log('Subnets', allSubnets);
      } catch (error) {
        console.error(error.message);
      };
    });
  }).on('error', err => {
    console.log('Error: ', err.message);
  });
}
main();
// module.exports = main;
