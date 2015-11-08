# fitbit2fit

A hacked together bit of code to sync weight from fitbit to google fit. Potentially some of the worst code I've written all year, but it's working. :warning: :wine_glass: :wine_glass:

I run this on Heroku.

## Running

Register an app at http://dev.fitbit.com/ . Then use the api debug tool to get user creds: https://dev.fitbit.com/apps/oauthtutorialpage . Note doen the encoded user ID as well. Set the following env vars:

set `FITBIT_CONSUMER_KEY`, `FITBIT_CONSUMER_SECRET`, `FITBIT_ACCESS_TOKEN`, `FITBIT_ACCESS_SECRET` and `FITBIT_USER_ID`

For Google, you can use https://developers.google.com/oauthplayground/. In settings you may want to use your own OAuth credentials so the registered app isn't the OAuth explorer.
https://developers.google.com/oauthplayground/

Needs scope `https://www.googleapis.com/auth/fitness.body.write`

set `GOOGLE_CLIENT_SECRET`, `GOOGLE_REFRESH_TOKEN`, `GOOGLE_CLIENT_ID`, `GOOGLE_ACCOUNT_TYPE=authorized_user`
