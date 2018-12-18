# EtsyThingsBridge
A Swift command line program that reads open orders from Etsy and creates projects in Things. 

## Dependancies 

Only one package is required:

- OAuthSwift

You must also have [Things][things] installed. If you're on Mojave you'll also need to grant scripting privileges. 

## Configuration

EtsyThingsBridge _does not_ run through an OAuth token generation flow. In order to use the app you will need your own [Etsy API keys][etsy] and to create the access keys (I recommend [grant][]). 

Keys are stored in `~/.config/EtsyThingsBridge/keys.json`. This file is created on first run. 

## Running

`EtsyThingsBridge` takes no arguments. 

EtsyThingsBridge stores the ID in the notes ensuring each item is only added to Things once. Additional notes can still be added as long as the ID remains. 

### LaunchAgent

In addition to running manually you can use the provided LaunchAgent. EtsyThingsBridge will run every night at midnight to download new orders.  

1. Copy `EtsyThingsBridge.job.plist` to `~/Library/LaunchAgents`
2. Update the path to `EtsyThingsBridge` in the job
3. Run `launchctl load ~/Library/LaunchAgents/EtsyThingsBridge.job.plist`

[things]: https://culturedcode.com/things/
[etsy]: https://www.etsy.com/developers/your-apps
[grant]: https://grant.outofindex.com/etsy#