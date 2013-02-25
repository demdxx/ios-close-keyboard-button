ios-close-keyboard-button
=========================

    @year 2012
    @license CC-BY-3.0
    @copyright Dmitry Ponomarev <demdxx@gmail.com>

Thanks for button images https://github.com/gavingmiller/evernote-show-hide-keyboard

![Example](https://raw.github.com/demdxx/ios-close-keyboard-button/master/screen.png)

How to use
==========

```objectivec

#import "UIViewController+KeyboardClose.h"

@interface MyController : UIViewController

// ...

@end

...

@implementation MyController

#pragma mark UIViewController load/unload view events

- (void)viewWillAppear:(BOOL)animated
{
    [self registerKeyboardCloseButtonForIphone];

    /* ... */

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unregisterKeyboardCloseButton];

    /* ... */

    [super viewWillDisappear:animated];
}

@end
```

License
=======

<a rel="license" href="http://creativecommons.org/licenses/by/3.0/deed.en_US"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by/3.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">NSHelpers</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Dmitry Ponomarev &lt;demdxx@gmail.com&gt;</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/3.0/deed.en_US">Creative Commons Attribution 3.0 Unported License</a>.<br />Based on a work at <a xmlns:dct="http://purl.org/dc/terms/" href="https://github.com/demdxx/NSHelpers" rel="dct:source">https://github.com/demdxx/NSHelpers</a>.