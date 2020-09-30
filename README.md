# iOS 14.0.1 NFC session bug PoC

NFC session started too fast after previously invalidated session (typically under 3 seconds) won't start properly.

We think it is some kind of a race condition after the session is invalidated. The NFC dialog informing about session being invalidated is still present for some time (~3 sec), when new NFC session is started programatically in this time interval, NFC session won't start properly. 


