/**
 * find all canisters that are controlled by a specific controller 
 * api specification. HERE ==>  https://ic-api.internetcomputer.org/api/v3/swagger
 */
const https = require('https');

const domain = 'https://ic-api.internetcomputer.org/api/v3/canisters';

const limimt = 100;
const controller = 'acvcd-vgg3o-qftqn-7apsp-hm3gc-j5qza-u7kcz-2q6jn-3a5hu-iucqw-tae';

const url = `${domain}?controller_id=${controller}&limit=${limimt}`;

function findMyCanisters(json) {
  console.log(`Total canisters: ${json.total_canisters}`);
  if (json.total_canisters > limimt) {
    console.log("need to paginate to get all canisters");
  };
  let myCanisters = json.data;

  return myCanisters;
};

https.get(url, res => {
  let data = '';
  res.on('data', chunk => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      let json = JSON.parse(data);
      let myCanisters = findMyCanisters(json);

      console.log('My owned cans', myCanisters);
    } catch (error) {
      console.error(error.message);
    };
  });
}).on('error', err => {
  console.log('Error: ', err.message);
});
