/**
 * find all canisters that are controlled by a specific controller in a subnet
 */
const https = require('https');

const domain = 'https://ic-api.internetcomputer.org/api/v3/canisters';
const subnet = 'bkfrj-6k62g-dycql-7h53p-atvkj-zg4to-gaogh-netha-ptybj-ntsgw-rqe';

const url = `${domain}?subnet_id=${subnet}`;
const controller = '4sd6s-xg3ws-aaulg-6h7ju-ntyrc-qpyot-lir4s-abk6o-4s5mn-s7jyv-tqe';

function findMyCanisters(json, controller) {
  let myCanisters = json.data.filter(canister => 
    canister.controllers.some(ctrl => ctrl === controller)
  );
  
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
      let myCanisters = findMyCanisters(json, controller);

      console.log('Test',myCanisters);
  } catch (error) {
      console.error(error.message);
  };
  });
}).on('error', err => {
  console.log('Error: ', err.message);
});
