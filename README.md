# ROKOmoji iMessage Sticker App (iOS)
Create your own iMessage Sticker App for free with ROKO Labs! We've open sourced our iMessage sticker app so you can easily build your own to promote your company and brand!

The application also utilizes [ROKO Mobi Stickers SDK](https://www.instabot.io/stickers-emojis) - which will help you manage your iMessage Sticker App through:

1. In-depth sticker analytics and reporting
2. Upload and send stickers and GIFS straight to your iMessage app w/o submitting another build to Apple 
3. It's all free! 

Should you have any questions or concerns, feel free to email us at help@instabot.io

## Custom App Features
No need to spend time creating features from scratch or paying for a developer. Our open-sourced app includes multiple types of custom app features.

1. Multiple sticker packs supported within one app
2. Custom backgrounds
3. Logo branding
4. Static and animated stickers
5. Info bubble branding
6. Sticker size selector, and more!

Want to see these features in action? Then check out our client apps [Aminal Stickers](https://itunes.apple.com/us/app/aminal-stickers/id1162014434?mt=8) and [ZAG Heroez](https://itunes.apple.com/us/app/zag-heroez/id1185630903) in the iTunes App Store.


## Xcode Project Settings
Open your `.workspace` file in Xcode:

1. Select Project Navigator View and choose your project name
2. Select Holding App Target
3. Complete the Bundle Identifier with your own Bundle info received from Apple Developer Site
4. Complete the Provisioning profiles with info received from your Apple Developer Site
5. Open `Constants.Swift`, insert [your API key](https://docs.instabot.io/docs/web-basic-setup#section-1-get-your-instabot-api-key) - eg: 

    ```
    let kAPIToken = "Your_API_KEY_goes_here"
    ```

## About ROKO Mobi
ROKO Mobi provides app developers and product owners with a suite of tools to accelerate mobile development, engage and track customers, and measure their app's success. A few things we do:

1. Instabot (add a chatbot into your app)
2. User Analytics
3. Push notifications
4. Stickers

Learn more about features at:
https://www.instabot.io

See here for ROKO Mobi documentation, interaction guides, and instructions:
https://docs.instabot.io/docs/roko-imessage-ios-sticker-app

## Activate your New iMessage App
Run application on device or simulator and follow the instructions on the main screen.

## Reference
For Apple's iOS 10.0 Human Interface Guidelines for iMessage extensions, please see here:
https://developer.apple.com/ios/human-interface-guidelines/extensions/messaging/

You can access the technical app extension programming guide on iMessage extensions here:
https://developer.apple.com/reference/messages
