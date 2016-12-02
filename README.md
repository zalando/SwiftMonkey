# SwiftMonkey

This project is a framework for generating randomised user input
in iOS apps. This kind of monkey testing is useful for
stress-testing apps and finding rare crashes.

It also contains a related framework called SwiftMonkeyPaws, which
provides visualisation of the generated events. This greatly
increases the usefulness of your randomised testing, as you can
see what touches caused any crash you may encounter.

## Why Use SwiftMonkey?

- When testing your UI, it's very easy to think about how to test
  how things *should* work, but do you struggle to figure out
  what kind of thing might *not* work?
- Ever showed your app to someone who proceeded to bang away at the
  screen and immediately crashed it by doing something you had never
  thought of?
- Do you want to feel a bit more confident about your app's stability?
- Do you have rare crashes that you just can't reproduce?
- Do you have memory leaks that take a long time to manifest
  themselves, and require lots of UI actions?

Randomised testing will help you with all of these!

SwiftMonkey is inspired by and has similar goals to
[UI AutoMonkey][], but is integrated into the Xcode UI testing
framework, providing better opportunities to debug.

Also, it is fun to look at:

<img src="https://thumbs.gfycat.com/IndolentTallFoxterrier-size_restricted.gif" height="480">

## Quick Start

To see for yourself how this framework works, just grab the code
and open `SwiftMonkeyExample/SwiftMonkeyExample.xcodeproj`. Then press `Cmd-U` to run the UI test.

## Installation

As a high-level overview, add `SwiftMonkey.framework` to your
UI test target. Then add a test that creates a `Monkey`
object and uses it to generate events.

Optionally, you also add the `SwiftMonkeyPaws.framework` to your
main app, and create a `MonkeyPaws` object to enable visualisation.
You probably only want to do this for debug builds, or when a
specific command line flag is used.

### Requirements

SwiftMonkey uses Swift 3.0. It has no dependencies other than
iOS itself (8.0 and up should work). SwiftMonkeyPaws doesn't
have any dependencies, either; you can even use on its own,
without SwiftMonkey.

### CocoaPods

You can install the frameworks using [CocoaPods][]. Assuming
that you've named your main app and test targets "App" and "Tests", you
can use something like this in your `Podfile`:

````ruby
target "App" do
    pod "SwiftMonkeyPaws", "~> 1.0"
end

target "Tests" do
    pod "SwiftMonkey", "~> 1.0"
end
````

### Manual Installation

Copy the `SwiftMonkey` and `SwiftMonkeyPaws` folders into your
project. Next, drag the `xcodeproj` files into your project.

Then, for SwiftMonkey, add `SwiftMonkey.framework` as a
dependency for your test target, and add a Copy Files build
phase to copy it into `Frameworks`.

For SwiftMonkeyPaws, adding `SwiftMonkeyPaws.framework` to the
Embedded Binaries section of your app target is enough.

(You can also just directly link the Swift files, if you do not
want to use frameworks.)

### Swift Package Manager

As of this writing, the Swift Package Manager doesn't support
iOS projects. SPM package files have experimentally been created,
but obviously don't really work yet.

## Usage

### SwiftMonkey

To do monkey testing, `import SwiftMonkey`, then create a new
test case that uses the `Monkey` object to configure and run
the input event generation. Here is a simple example:

````swift
func testMonkey() {
    let application = XCUIApplication()

    // Workaround for bug in Xcode 7.3. Snapshots are not properly updated
    // when you initially call app.frame, resulting in a zero-sized rect.
    // Doing a random query seems to update everything properly.
    // TODO: Remove this when the Xcode bug is fixed!
    _ = application.descendants(matching: .any).element(boundBy: 0).frame

    // Initialise the monkey tester with the current device
    // frame. Giving an explicit seed will make it generate
    // the same sequence of events on each run, and leaving it
    // out will generate a new sequence on each run.
    let monkey = Monkey(frame: application.frame)
    //let monkey = Monkey(seed: 123, frame: application.frame)

    // Add actions for the monkey to perform. We just use a
    // default set of actions for this, which is usually enough.
    // Use either one of these, but maybe not both.
    // XCTest private actions seem to work better at the moment.
    // UIAutomation actions seem to work only on the simulator.
    monkey.addDefaultXCTestPrivateActions()
    //monkey.addDefaultUIAutomationActions()

    // Occasionally, use the regular XCTest functionality
    // to check if an alert is shown, and click a random
    // button on it.
    monkey.addXCTestTapAlertAction(interval: 100, application: application)

    // Run the monkey test indefinitely.
    monkey.monkeyAround()
}
````

The `Monkey` object allows you not only to add the built-in
event generators, but also any block of your
own to be executed either randomly or at set intervals. In
these blocks you can do whatever you want, including (but not
only) generate more input events.

Documentation for this is limited at the moment, so please
refer to `Monkey.swift` and its extensions for examples of
how to use the more advanced functionality if you need it.

### SwiftMonkeyPaws

The simplest way to enable the visualisation in your app is to
first `import SwiftMonkeyPaws`, then do the following somewhere
early on in your program execution:

````swift
var paws: MonkeyPaws?

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    if CommandLine.arguments.contains("--MonkeyPaws") {
        paws = MonkeyPaws(view: window!)
    }
    return true
}
````

(This example uses `application(_, didFinishLaunchingWithOptions)`,
but any time after you have a UIWindow will do. It also only
instatiates the visualisation if a certain command line flag
is passed, so that it can be enabled only for test runs.)

This call will swizzle some methods in UIApplication to capture
UIEvents. If you would rather not do this, or if you already have
a source of UIEvents, you can pass the following option to `init`
to disable swizzling:

````swift
paws = MonkeyPaws(view: window!, tapUIApplication: false)
````

Then you can pass in events with the following call:

````swift
paws?.append(event: event) // event is UIEvent
````

## Contributing

Feel free to file issues and send pull requests for this
project! It is very new and not overly organised yet, so be
bold and go ahead. We will sort out the details as we go along.

Code style is currently just four-space identation and regular
Apple Swift formatting.

Also, we have adopted the Contributor Covenant as the code
of conduct for this project:

<http://contributor-covenant.org/version/1/4/>

### Thanks to

* The Zalando Open Source Guild for helping get this project
  off the ground.
* João Nunes for help with documentation.
* Jakub Mucha for bugfixing.

## TODO

### SwiftMonkey

- Write more documentation.
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
