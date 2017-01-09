# ROKOMoji.iMessage
Build your own iMessage extension

## About ROKOmoji.iMessage
Create your own iMessage Sticker App with ROKO Labs! We've open sourced our iMessage sticker app so you can easily build your own to promote your company and brand!

The application is utilizing ROKO Mobi - http://roko.mobi - Stickers SDK to manage your keyboard and see analytics, all for free! 

Should you have any questions or concerns, feel free to email us at help@rokolabs.com

## Xcode Project Settings
Open workspace in Xcode:

1. Select Project Navigator View and choose your project name
2. Select Holding App Target
3. Complete the Bundle Identifier with your own Bundle info received from Apple Developer Site
4. Complete the Provisioning profiles with info received from your Apple Developer Site
5. Open Constants.Swift file, he following line and replace Your_API_KEY_goes_here with your key:
```
let kAPIToken = "Your_API_KEY_goes_here"
```


## Portal settings
ROKO Mobi provides app developers and product owners with a suite of tools to accelerate mobile development, engage and track customers, and measure their app's success

See here for ROKO Mobi documentation, interaction guides, and instructions:
https://docs.roko.mobi/docs/setting-up-your-account

## Activate your new keyboard
Run application on device or simulator and follow the instructions on the main screen.

## Reference Links
For Apple's iOS 10.0 Human Interface Guidelinse for iMessage extensions, please see below:
https://developer.apple.com/ios/human-interface-guidelines/extensions/messaging/

You can access the technical app extension programming guide on iMessage extentions here:
https://developer.apple.com/reference/messages
