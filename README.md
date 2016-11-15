# SwiftMonkeyPaws

This is a small framework that visualises all touch events in
an iOS app, as a layer on top of your UI. This is meant to be
paired with the [SwiftMonkey][] monkey testing library, but can
also be used on its own.

Usage is very simple: Just link the framework, the create and
hold on to a `MonkeyPaws` object. It will automatically tap into
input arriving in your app and overlay it on your UI.

(Obviously, you may want to do this only in debug builds or only
when passed a certain command line option, as it is not exactly
suited for a production release!)

### Requirements

SwiftMonkeyPaws uses Swift 3.0. It has no other dependencies
other than iOS itself, not even the SwiftMonkey framework.

### Usage

The simplest way to enable the visualisation is to first
`import SwiftMonkeyPaws`, and do the following somewhere early
on in your program execution:

    var paws: MonkeyPaws?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        paws = MonkeyPaws(view: window!)
        return true
    }

(This example uses `application(_, didFinishLaunchingWithOptions)`,
but any time after you have a UIWindow will do.)

This call will swizzle some methods in UIApplication to capture
UIEvents. If you would rather not do this, or if you already have
a source of UIEvents, you can pass the following option to `init`
to disable swizzling:

    paws = MonkeyPaws(view: window!, tapUIApplication: false)

Then you can pass in events or touches with either of the
following calls:

    paws?.append(event: event) // event is UIEvent

    paws?.append(touch: touch) // touch is UITouch

For a more concrete example, there is an example project
using both this framework and the [SwiftMonkey][] testing
framework here:

<https://github.bus.zalan.do/dagren/SwiftMonkeyExample>

### Contact

This software is written by Dag Ågren (dag.agren@zalando.fi)
for Zalando SE.

Bug reports and feature requests are more likely to be addressed
if posted as issues here on GitHub.

### License

The MIT License (MIT) Copyright © 2016 Zalando SE, https://tech.zalando.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[SwiftMonkey]: https://github.bus.zalan.do/dagren/SwiftMonkey
