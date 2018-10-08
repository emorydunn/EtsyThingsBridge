# EtsyThingsBridge
A Node app that reads open orders from Etsy and creates projects in Things. 

## Dependancies 

There are only two `npm` packages required:

- osa
- oauth

Run `npm install` to download everything. 

You must also have [Things][things] installed. If you're on Mojave you'll also need to grant scripting privileges. 

## Configuration

EtsyThingsBridge _does not_ run through an OAuth token generation flow. In order to use the app you will need your own [Etsy API keys][etsy] and to create the access keys (I recommend [grant][]). 

Copy `keys.json.example` to `keys.json` and fill in the appropriate values. 

## Running

Run `node index.js` to download all open orders. 

EtsyThingsBridge stores the ID in the notes ensuring each item is only added to Things once. Additional notes can still be added as long as the ID remains. 

### LaunchAgent

In addition to running manually you can use the provided LaunchAgent. EtsyThingsBridge will run every night at midnight to download new orders.  

1. Copy `EtsyThingsBridge.job.plist` to `~/Library/LaunchAgents`
2. Update the path to `index.js` in the job
3. Run `launchctl load ~/Library/LaunchAgents/EtsyThingsBridge.job.plist`

[things]: https://culturedcode.com/things/
[etsy]: https://www.etsy.com/developers/your-apps
[grant]: https://grant.outofindex.com/etsy#
