# WBRUTER

![wbruter](https://github.com/user-attachments/assets/8e8eb00d-a722-4b77-a1a0-bcc2dd22e2e7)

wbruter is is the first tool wich has been released as open source wich can guarantee 100% that your pin code will be cracked aslong as usb debugging has been enable. wbruter also includes some other brute methods like dictionary attacks for gmail, ftp, rar, zip and some other file extensions.

wbruter will allways try to bring support for rare protocols, wbruter wont contain common stuff like other brute tools cover like facebook, snapchat, instagram and you name it (except a few exceptions, very few)

Many times it's the easiest methods that are the most powerful methods, it's just a matter of using your imagination ;-)

### INFO: 2020-07-11:

Android and Google, now have set a rule for locksettings via cli as via gui earlier, if you try to many attempts within X seconds you will be blocked for X seconds so wbruter via cli wont work anymore on devices that has been upgraded to latest version Android 10, older version should work fine unless they are upgraded to latest android version.

Enable USB-Debugging via the methods below:

#### Via GUI:

Go to settings -> about > press on build number 7 times and the developer settings will be enable, go back to settings and press on developer mode and then enable USB DEBUGGING. If you found an android deviceon the street or something and want to break the pin this wont be possible unless you already know the pin so the device must have usb debugging enable for this to work. You wanna try this for fun then you can just enable usb debugging after you unlocked phone)

#### Via cli/adb:

```
settings put global development_settings_enabled 1
setprop persist.service.adb.enable 1
```

#### Via GUI (old layout now use --androidgui 4 instead)

Please use cli method instead since many devices has been set to erase the device after "10/15 wrong pin attempts" and this wont happen with the CLI method. (Updated: Jan/2019)
Screenshot

#### Via CLI:

![wbruter](https://github.com/user-attachments/assets/fc5eff84-ea36-4afe-931e-3260b1bee611)

From 0000 to 9999 takes ~83 minutes. In around ~1h you will with 100% guarantee have the pin code

### Notice:

If you will see a message similiar to message under you don't have to care, just let it run and it will be gone after ~4-5 failed attempts:

```
  Error while executing command: clear
    java.lang.RuntimeException: No data directory found for package android
    at android.app.ContextImpl.getDataDir(ContextImpl.java:2418)
    at android.app.ContextImpl.getPreferencesDir(ContextImpl.java:533)
    at android.app.ContextImpl.getSharedPreferencesPath(ContextImpl.java:795)
    at android.app.ContextImpl.getSharedPreferences(ContextImpl.java:394)
    at com.android.internal.widget.LockPatternUtils.monitorCheckPassword(LockPatternUtils.java:1814)
    at com.android.internal.widget.LockPatternUtils.checkCredential(LockPatternUtils.java:398)
    at com.android.internal.widget.LockPatternUtils.checkPassword(LockPatternUtils.java:548)
    at com.android.internal.widget.LockPatternUtils.checkPassword(LockPatternUtils.java:509)
    at com.android.server.LockSettingsShellCommand.checkCredential(LockSettingsShellCommand.java:151)
    at com.android.server.LockSettingsShellCommand.onCommand(LockSettingsShellCommand.java:57)
    at android.os.ShellCommand.exec(ShellCommand.java:96)
    at com.android.server.LockSettingsService.onShellCommand(LockSettingsService.java:1945)
    at android.os.Binder.shellCommand(Binder.java:574)
    at android.os.Binder.onTransact(Binder.java:474)
    at com.android.internal.widget.ILockSettings$Stub.onTransact(ILockSettings.java:419)
    at com.android.server.HwLockSettingsService.onTransact(HwLockSettingsService.java:179)
    at android.os.Binder.execTransact(Binder.java:675)
```


### How To

```
git clone https://github.com/wuseman/WBRUTER
cd WBRUTER; ./wbruter --help
```

### Requirements

A linux setup would be good ;)

### Website

Visit my websites and profiles for the latest info and updated tools
