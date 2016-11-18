# SwiftMonkey

This project is a framework for generating randomised user input
in iOS apps. This kind of monkey testing is useful for
stress-testing apps and finding rare crashes.

It also contains a related framework SwiftMonkeyPaws, which
provides visualisation of the generated events. This greatly
increases the usefulness of the randomised testing, as you can
see what touches caused any crash you may encounter.

## Why use this?

- When testing your UI, it's very easy to think of how to test
  how things *should* work, but do you struggle to to figure out
  what kind of thing might *not* work?
- Ever showed your app someone who proceeded to bang away at the
  screen and immediately crashed it by doing something you never
  thought of?
- Do you want to feel a bit more confident about the stability
  of your app?
- Do you have rare crashes that you just can't reproduce?
- Do you have memory leaks that take a long time to manifest
  themselves, and require lots of UI actions?

Randomised testing will help you with all of these!

This project is inspired by and has similar goals to
[UI AutoMonkey][], but is integrated into the Xcode UI testing
framework, providing better opportunities to debug.

Also, it is fun to look at:

<img src="https://thumbs.gfycat.com/IndolentTallFoxterrier-size_restricted.gif" height="480">

## Quick start

To see for yourself how this framework works, just grab the code,
and open `SwiftMonkeyExample/SwiftMonkeyExample.xcodeproj`, and
then press `Cmd-U` to run the UI test.

## Installation

As a high-level overview, you add `SwiftMonkey.framework` to your
UI test target, and then add a test that creates a `Monkey`
object and uses it to generate events.

Optionally, you also add the `SwiftMonkeyPaws.framework` to your
main app, and create a `MonkeyPaws` object to enable visualisation.
You probably only want to do this in Debug builds, or when a
specific command line flag is used.

### Requirements

SwiftMonkey uses Swift 3.0. It has no dependencies other than
iOS itself (8.0 and up should work). SwiftMonkeyPaws also
similarly has no dependencies, and can also be used on its own
without SwiftMonkey.

### CocoaPods

You can install the frameworks using [CocoaPods][]. Assuming
your main app and test targets are named "App" and "Tests", you
can use something like this in your `Podfile`:

````ruby
target "App" do
  pod "SwiftMonkeyPaws", :git => "git@github.bus.zalan.do:dagren/SwiftMonkey.git"
end
    
target "Tests" do
  pod "SwiftMonkey", :git => "git@github.bus.zalan.do:dagren/SwiftMonkey.git"
end
````

### Manual installation

Copy the `SwiftMonkey` and `SwiftMonkeyPaws` folders into your
project. Next, drag the `xcodeproj` files into your project.

Then, for SwiftMonkey, add `SwiftMonkey.framework` as a
dependency for your test target, and add a Copy Files build
phase to copy it into `Frameworks`.

For SwiftMonkeyPaws, adding `SwiftMonkeyPaws.framework` to your
Embedded Binaries section of your app target is enough.

(You can also just directly link the Swift files, if you do not
want to use frameworks.)

### Swift Package Manager

The Swift Package Manager does not at the time of writing support
iOS projects. SPM package files have experimentally been created,
but obviously don't really work yet.

## Usage

### SwiftMonkey

To be written.

### SwiftMonkeyPaws

The simplest way to enable the visualisation in the app is to
first `import SwiftMonkeyPaws`, and do the following somewhere
early on in your program execution:

````swift
var paws: MonkeyPaws?

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
  paws = MonkeyPaws(view: window!)
  return true
}
````
(This example uses `application(_, didFinishLaunchingWithOptions)`,
but any time after you have a UIWindow will do.)

This call will swizzle some methods in UIApplication to capture
UIEvents. If you would rather not do this, or if you already have
a source of UIEvents, you can pass the following option to `init`
to disable swizzling:
````swift
paws = MonkeyPaws(view: window!, tapUIApplication: false)
````
Then you can pass in events or touches with either of the
following calls:
````swift
paws?.append(event: event) // event is UIEvent

paws?.append(touch: touch) // touch is UITouch
````
## Contributing

Feel free to file issues and send pull requests for this
project! It is very new and not overly organised yet, so be
bold and go ahead. We will sort out the details as we go along.

Code style is currently just 4 space identation, and regular
Apple Swift formatting.

Also, we have adopted the Contributor Covenant as the code
of conduct for this project:

<http://contributor-covenant.org/version/1/4/>

### Thanks to

* The Zalando open source guild for helping get this project
  off the ground.
* João Nunes for help with documentation.

## TODO

### SwiftMonkey

- Add more input event actions.
- Add randomised testing using public XCTest APIs instead of private ones.
  - Find clickable view and click them directly instead of
    clicking random locations, to compensate for the slow
    event generation.
- Fix swipe actions to avoid pulling out the top and bottom panels. (This
  can cause the monkey to escape from your app, which can be problematic!)
- Generally, find a quick way to see if the monkey manages to leave the
  application.
- Find out how to do device rotations using XCTest private API.
- Find out why UIAutomation actions do not work on device, but only on the
  simulator.
- Investigate other methods of generating input events that do not rely
  on private APIs.
- Once Swift Package Manager has iOS support, update project
  to support it properly.

### SwiftMonkeyPaws

- Add more customisability for the visualisation.

### SwiftMonkeyExample

- Add more UI elements, views and controls to make the example
  look more interesting.
- Maybe add some actual crashes that the monkey testing can find?

## Contact

This software was originally written by Dag Ågren
(dag.agren@zalando.fi) for Zalando SE. This email address serves
as the main contact address for this project.

Bug reports and feature requests are more likely to be addressed
if posted as issues here on GitHub.

## License

The MIT License (MIT) Copyright © 2016 Zalando SE, https://tech.zalando.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[CocoaPods]: https://cocoapods.org/
[UI AutoMonkey]: https://github.com/jonathanpenn/ui-auto-monkey

