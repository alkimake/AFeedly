![AFeedly](http://i.imgur.com/HUyU7Bo.png)

#iOS Feedly API Client

The Feedly API Client library lets you authenticate by OAuth and connect to the Feedly APIs by returning Objective-C models. The project includes:

* A sample app which makes demonstrates a subset of the library calls
* Library code which is distributed as a Pod

**Under heavily development**

##Building and running the sample app

In the project directory where you have downloaded the code install dependency pods by running the following command:

```bash
pod install
```

Edit AFLAppDelegate.m to use the sandbox key which can be found on the [Feedly Developer Google Group](https://groups.google.com/forum/#!forum/feedly-cloud). You can also use your own key if you have requested one.  


```obj-c
    [[AFLClient sharedClient initWithApplicationId:@"yourApplicationIdHere" andSecret:@"yourSecretCodeHere"];
```

You may also need to change AFLClient.m to use "https" for authentication as XCode may block the unencrypted traffic.

```obj-c
static NSString * const kFeedlySandboxAPIBaseURLString = @"https://sandbox.feedly.com/v3";
static NSString * const kFeedlySandboxUserURLString = @"https://sandbox.feedly.com/v3/auth/auth";
static NSString * const kFeedlySandboxTokenURLString = @"https://sandbox.feedly.com/v3/auth/token";
```

Compile and run the app from XCode and you should be up and running.

##Installation

To include AFeedly in your own project, first add pod to your `Podfile` in your project directory

```bash
pod 'AFeedly', '~> 0.0'
```

Then install the new pod by running command

```bash
pod install
```

Initialize your client once with your Feedly Application ID and Secret obtained from Feedly or use the feedly sandbox enviroment as above.

```obj-c
    [[AFLClient sharedClient] initWithApplicationId:@"yourApplicationIdHere" andSecret:@"yourSecretCodeHere"];
```

 For more detailed information please visit [http://developer.feedly.com/v3/sandbox/](http://developer.feedly.com/v3/sandbox/).

Additionally you can use experimental `sync with server` feature by adding:

```obj-c
[[AFLClient sharedClient] setIsSyncWithServer:YES];
```

##Usage

--TODO--

##License
This code is distributed under the terms and conditions of the MIT license.

##Author
Alkim Gozen 
[@alkimake](https://twitter.com/alkimake)
