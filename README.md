# iOS 14.0.1 NFC session bug PoC

When NFC session is invalidated and programatically started again under 3 seconds, new NFC session won’t start properly, i.e., callback `tagReaderSessionDidBecomeActive` is not called, no session modal window is displayed. 

We think it is some kind of a race condition after the session is invalidated. The NFC dialog informing about session being invalidated is still present for some time (~3 sec), when new NFC session is started programatically in this time interval, NFC session won't start properly. 

Bug manifests on older iPhones (iPhone 7, iPhone 8). iPhone 11 Pro works fine.

## Reproduce
Start the app, click to button on the screen (only one) and wait. 
It performs:

- Start a new NFC session
- Set task that invalidates the session 2 seconds after the session started.
- After the session was invalidated (callback is triggered), start another delayed task, which starts a new session in 2 seconds.
- When session is started, there is another “watchdog” task waiting 5 seconds for `tagReaderSessionDidBecomeActive` to be triggered. If it is not triggered, session is invalidated programatically as it won’t show up (bug!)
- Newly started session won’t show up...

