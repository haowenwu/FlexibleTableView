# FlexibleTableView

A flexible tableview used on iOS implement by swift.

Inspired By [SKSTableView](https://github.com/sakkaras/SKSTableView).

## Requirements
- iOS 7.0+
- Xcode 8.0
- Swift3

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
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
func tableView(_ tableView: UITableView, numberOfSubRowsAt indexPath: IndexPath) -> Int
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
func tableView(_ tableView: UITableView, cellForSubRowAt indexPath: FlexibleIndexPath) -> UITableViewCell
```

## License

FlexibleTableView is available under the MIT license. See the LICENSE file for more info.
