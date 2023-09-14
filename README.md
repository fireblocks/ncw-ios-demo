# Fireblocks-iOS-NCW-Demo

Welcome to Fireblocks-iOS-NCW-Demo App.

## Installation

- git clone git@github.com:fireblocks/ncw-ios-demo.git
- Open the Fireblocks.xcodeproj project with Xcode.
- File -> Add files to Fireblocks -> Add GoogleService-Info.plist with your app's Google API Keys, for connecting to Firebase and Google Drive
- Add the following key to Fireblocks/Info.plist file inside this project, with the reversed Google Client-ID from GoogleService-Info.plist file -
- 
```
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>***REVERSED GOOGLE CLIENT ID KEY***</string>
			</array>
		</dict>
	</array>
 ```

## License
MIT License

