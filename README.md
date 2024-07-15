# Recycle
Get all canisters from the IC mainnet controlled by a controller principal.

## Usage nodeJS Version

```bash
Usage: node index.js <controller_id>
```

## Usage Motoko Version
This examples uses the mops package: serde to convert JSON data from the API to Motoko data.

Install it with:
```bash
dfx deploy
```

Then call it with:
```bash
dfx canister call recycle getCanisters '("<controllerID>")'
```


## Open questions

- How is the correct number of cycles for the http outcall calculated ?
