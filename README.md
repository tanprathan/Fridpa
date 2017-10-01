# Fridpa
![image](https://raw.githubusercontent.com/tanprathan/Fridpa/master/image/fridpa.JPG)

An automated wrapper script for unpacking, patching (Insert the load command into binary), re-signing and deploying apps on non-jailbroken device. Once the process is completed, the apps will launch in debugging mode with lldb attached and ready for hooking using Frida. Fridpa has 2 modules which are: "The (IPA)Builder" and "The Connector"
   * `The (IPA)Builder` : This module uses for unpacking, patching, re-signing and deploying the app with debugging mode.
   * `The Connector`    : This module uses for connecting to patched app without re-installing.

### Program Dependencies
* optool (https://github.com/alexzielenski/optool)
* ios-deploy (https://github.com/phonegap/ios-deploy)

### Usage
* Ensure that your mobile provision profile is ready and locate on Fridpa directory. Please follow the instruction to create mobile provision profile at https://www.nccgroup.trust/uk/about-us/newsroom-and-events/blogs/2016/october/ios-instrumentation-without-jailbreak/ (Configure the environment).
* Ensure that your iOS application package (.ipa file) is located on Fridpa directory.
* Once the `The (IPA)Builder` module is selected, the Fridpa will reqest the signing identity (e.g. F0B35CBA1F2DA06F49F3ADB0C93E14FFFAE3B85B) in order to perform re-signing the app. (Please select the identity which match with provision profile).
* For first deployment, provision profile must be trusted on iDevice which can be set in "Settings->General->Profiles&Device Management->Developer App", then press enter to confirm the setting.
* Re-installation will be conducted automatically and run the app with debugging mode. Now, the app will wait Frida client for connecting to the app.

### Contribution
Your contributions and suggestions are welcome.

### License

[![Creative Commons License](http://i.creativecommons.org/l/by/4.0/88x31.png)](http://creativecommons.org/licenses/by/4.0/)

This work is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/)
