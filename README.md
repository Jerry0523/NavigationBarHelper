[![Build Status](https://travis-ci.org/Jerry0523/NavigationBarHelper.svg?branch=master)](https://travis-ci.org/Jerry0523/NavigationBarHelper)
# NavigationBarHelper
A library that helps to manage the navigation bar style. It helps to remember bar attributes between different VCs and keep the transition smooth.

![alt tag](https://raw.githubusercontent.com/Jerry0523/NavigationBarHelper/master/screenshot.gif)


Usage
-------

### When your app finishes launch, call the function below to start up the helper.

```swift
NavigationBarHelper.load()
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

### Protocol NavigationBarHelperDelegate

- backgroundAttrWillRestore(attr: inout NavigationBarBackgroundAttr)
>Called before the mirror view capturing the bar's background attribute. Modify the backgroundAttr if it is not your appetite.

- backgroundAttrDidRestore()
> Called after the mirror view capturing the bar's background attribute. It is the best time for you to do additional change to the bar's background attr. After this function is called, the mirror background view will synchronize with the bar's background.

- foregroundAttrWillRestore(attr: inout NavigationBarForegroundAttr)
> Called before the navigation bar's foreground attribute being restored, especially when the viewController's appearing. Modify the foregroundAttr if it is not your appetite.

- foregroundAttrDidRestore()
> Called after the navigation bar's foreground attribute being restored, especially when the viewController's appearing. Do additional change if you have modified the navigation bar out of the performNavigationBarUpdates scope.(e.g, you have set the bar tint color according to scrollview offset).

License
-------
(MIT license)

