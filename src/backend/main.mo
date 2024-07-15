import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";

//import the custom types we have in Types.mo
import Types "Types";
import { JSON; }  "mo:serde";


//Actor
actor {

  //function to transform the response
  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {

    let transformed : Types.CanisterHttpResponsePayload = {
      status = raw.response.status;
      body = raw.response.body;
      headers = [
        {
          name = "Content-Security-Policy";
          value = "default-src 'self'";
        },
        { name = "Referrer-Policy"; value = "strict-origin" },
        { name = "Permissions-Policy"; value = "geolocation=(self)" },
        {
          name = "Strict-Transport-Security";
          value = "max-age=63072000";
        },
        { name = "X-Frame-Options"; value = "DENY" },
        { name = "X-Content-Type-Options"; value = "nosniff" },
      ];
    };
    transformed;
  };
  
  // function to get the canisters
  public shared func getCanistersByController(controllerId: Text) : async ?Types.CanisterResponse {

    // 1. DECLARE IC MANAGEMENT CANISTER
    // We need this so we can use it to make the HTTP request
    let ic : Types.IC = actor ("aaaaa-aa");

    // 2. SETUP ARGUMENTS FOR HTTP GET request

    // 2.1 Setup the URL and its query parameters
    let host : Text = "ic-api.internetcomputer.org";
    let url : Text = "https://"# host #"/api/v3/canisters?controller_id=" # controllerId;

    // 2.2 prepare headers for the system http_request call
    let request_headers = [
      { name = "Host"; value = host # ":443" },
      { name = "User-Agent"; value = "recycle" },
    ];

    // 2.2.1 Transform context
    let transform_context : Types.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    // 2.3 The HTTP request
    let http_request : Types.HttpRequestArgs = {
      url = url;
      max_response_bytes = null; //optional for request
      headers = request_headers;
      body = null; //optional for request
      method = #get;
      transform = ?transform_context;
    };

    //3. ADD CYCLES TO PAY FOR HTTP REQUEST

    //The IC specification spec says, "Cycles to pay for the call must be explicitly transferred with the call"
    //IC management canister will make the HTTP request so it needs cycles
    //See: https://internetcomputer.org/docs/current/motoko/main/cycles
    
    //The way Cycles.add() works is that it adds those cycles to the next asynchronous call
    //"Function add(amount) indicates the additional amount of cycles to be transferred in the next remote call"
    //See: https://internetcomputer.org/docs/current/references/ic-interface-spec/#ic-http_request
    let addAmountOfCycles : Nat = calcCyclesAdd();
    Cycles.add<system>(addAmountOfCycles);
    
    // 4. MAKE HTTPS REQUEST AND WAIT FOR RESPONSE
    // Since the cycles were added above, we can just call the IC management canister with HTTPS outcalls below
    let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);
    
    //5. DECODE THE RESPONSE
    let response_body: Blob = Blob.fromArray(http_response.body);
    let decoded_text: ?Types.CanisterResponse = switch (Text.decodeUtf8(response_body)) {
        case (null) {
          null;
        };
        case (?y) { 
          let result = JSON.fromText(y, null);
          let canisterResponse : ?Types.CanisterResponse = switch (result) {
            case (#ok(blob)) {
              // Successfully parsed JSON, convert from Candid
              from_candid(blob)
            };
            case (#err(errMsg)) {
              // Handle error, possibly log it or return a default value
              Debug.print(debug_show("Error parsing JSON: ", errMsg));
              null // or some default value or error handling
            };
          };
          canisterResponse;
        };
    };

    //6. RETURN RESPONSE OF THE BODY

    decoded_text;
  };

  // function to calc the Cycles.add() amount
  func calcCyclesAdd(): Nat {
    let n : Nat = 13; // 13 node network
    let baseFee : Nat = (3_000_000 + 60_000 * n) * n ;

    let request_size : Nat = 50000; // Assumption, must be improved
    let response_size : Nat = 1000000; // Assumption, must be improved

    let requestByte : Nat = (400 * n) * request_size;
    let responseByte : Nat = (800 * n) * response_size;

    var total : Nat = baseFee + requestByte + responseByte;

    Debug.print(debug_show("baseFee: ", baseFee));
    Debug.print(debug_show("requestByte: ", requestByte));
    Debug.print(debug_show("responseByte: ", responseByte));
    Debug.print(debug_show("total: ", total));
    
    // in a 13 node network the total cycles to pay for the call and a response of 3 canisters
    // is 20_849_105_355 =  (USD approx. 0.01583075577)


    // hard coded at the moment, I don't know if it all gets used or just the number of cycles needed??
    total := 230_949_972_000; 
    total;
  };

};