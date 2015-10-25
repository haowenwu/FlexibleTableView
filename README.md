# FlexibleTableView

A flexible tableview used on iOS implement by swift.

Inspired By [SKSTableView](https://github.com/sakkaras/SKSTableView).

## Requirements
- iOS 7.0+
- Xcode 7.0

## Installation

FlexibleTableView is available through [CocoaPods](http://cocoapods.org).

```ruby
pod "FlexibleTableView"
```

## Screenshot
![FlexibleTableView](Screenshot.gif)

## Usage

FlexibleTableView work the same as UITableView but just with one FlexibleTableViewDelegate.

```swift
func tableView(tableView: FlexibleTableView, numberOfRowsInSection section: Int) -> Int
func tableView(tableView: FlexibleTableView, numberOfSubRowsAtIndexPath indexPath: NSIndexPath) -> Int
func tableView(tableView: FlexibleTableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FlexibleTableViewCell
func tableView(tableView: FlexibleTableView, cellForSubRowAtIndexPath indexPath: FlexibleIndexPath) -> UITableViewCell
```

## License

FlexibleTableView is available under the MIT license. See the LICENSE file for more info.
