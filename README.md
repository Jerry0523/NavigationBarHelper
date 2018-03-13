[![Build Status](https://travis-ci.org/Jerry0523/NavigationBarBackgroundHelper.svg?branch=master)](https://travis-ci.org/Jerry0523/NavigationBarBackgroundHelper)
# NavigationBarBackgroundHelper
A library that helps to manage the navigation bar style. It helps to remember bar attributes between different VCs and keep the transition smooth.


Usage
-------

### When your app finishes launch, call the function below to start up the helper.

```swift
NavigationBarBackgroundHelper.load()
```
> swizzle UIViewController.viewSafeAreaInsetsDidChange

> swizzle UIViewController.viewWillAppear(_:)

### For a viewController, use the function below to modify the navigation bar.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    barBackgroundHelper.performNavigationBarUpdates {
        //Codes for navigation bar update.
        //e.g. self.navigationController?.navigationBar.tintColor = UIColor.white
    }
}
```

>After calling the function above, any attribute (background image/tintColor/barTintColor/barStyle etc) will be remembered by the library. It will create a mirror background view of the navigation bar (auto managed) and clear the bar background (to provide a smooth transition). Any change to the navigation bar background (background image/barTintColor/barStyle/shadowImage) in the closure will be syncronized with the mirror view.

### Protocol NavigationBarBackgroundHelperDelegate

- navigationBarBackgroundAttrDidRestore

>Called before the mirror view capturing the bar's background attribute. It is the best time for you to do additional change to the bar's background attr. After this function is called, the mirror background view will synchronize with the bar's background.

- navigationBarForegroundAttrDidRestore

>Called after the navigation bar's foreground attribute being restored, especially when the viewController's appearing. Do additional change if you have modified the navigation bar.(e.g, you have set the bar tint color according to scrollview offset)


License
-------
(MIT license)

