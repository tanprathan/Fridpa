#!/bin/bash
# An automated wrapper script for unpacking, patching, signing and deploying
# apps on non-jailbroken device. Once the process is completed, the apps will
# launch in debugging mode with lldb attached and ready for hooking using Frida
#
# Developed by @tanprathan

export PATH=$PATH:/usr/libexec
DYLIB=${pwd}/FridaGadget.dylib



function patch() {
	# Clear Payload folder
	rm -rf Payload*

	# Download Frida DYLIB if not found
	if [ ! -f $DYLIB ]; then
		echo "FridaGadget.dylib not found"
		echo "Download from the internet"
		curl -O https://build.frida.re/frida/ios/lib/FridaGadget.dylib
	fi

	# Obtaining Certificate Identity from Developer profile:
	echo "" && echo -e "***** Listing Signing Identity *****"
	security find-identity -p codesigning -v
	echo "" && echo -n "Enter your Identity (Same as mobileprovision) then press [ENTER]: "
	read SID

	# Unpacking and Identifying Application Name:
	echo "" && echo -n "Ensure the IPA and embedded.mobileprovision file are on the current directory [ENTER]"
	read OK
	APPPACKAGE="$(find *.ipa)"
	unzip ${APPPACKAGE} >/dev/null
	APPNAME="$(ls Payload)"

	# Copying Frida to Application folder and Inserting load command
	cp FridaGadget.dylib "Payload/${APPNAME}/"
	echo "" && echo -e "***** Inserting load command into Binary *****"
	APPBINARY=${APPNAME%.*}
	./optool install -c load -p "@executable_path/FridaGadget.dylib" -t "Payload/${APPNAME}/${APPBINARY}"

	# Obtaining entitlements and Bundle ID:
	security cms -D -i embedded.mobileprovision >profile.plist
	PlistBuddy -x -c 'Print :Entitlements' profile.plist >entitlements.plist

	ENT=$(egrep -a -A 2 application-identifier embedded.mobileprovision | grep string | sed -e 's/<string>//' -e 's/<\/string>//' -e 's/ //' | tr -d '\t')
	BUNDLEID=${ENT#*.}

	# Signing the Application package:
	cp embedded.mobileprovision "Payload/${APPNAME}/embedded.mobileprovision"

	PlistBuddy -c "Set :CFBundleIdentifier ${BUNDLEID}" "Payload/${APPNAME}/Info.plist"

	rm -rf Payload/${APPNAME}/_CodeSignature
	echo "" && echo -e "***** Re-signing Binary *****"
	codesign --force --sign ${SID} "Payload/${APPNAME}/FridaGadget.dylib"
	codesign --force --sign ${SID} --entitlements entitlements.plist "Payload/${APPNAME}/${APPBINARY}"

	# Clear entitlements file
	rm entitlements.plist
	rm profile.plist

	# Deploying application with debuggable mode:
	echo "" && echo -e "***** Deploying Application on iDevice *****"
	ios-deploy --bundle "Payload/${APPNAME}/"
	echo "" && echo -n "Trust Developer profile on Device Settings and press [ENTER]"
	read OK
	echo "" && echo -e "***** Deploying Application with Frida Server *****"
	ios-deploy --noinstall --debug --bundle "Payload/${APPNAME}/"
	exit 0
}

function deploy() {
	APPNAME="$(ls Payload)"
	echo "" && echo -e "***** Deploying Application with Frida Server *****"
	ios-deploy --noinstall --debug --bundle "Payload/${APPNAME}/"
	exit 0
}

# Providing option for Fridpa
cat welcome.txt
echo "" && echo -n "Enter your Option for Fridpa and press [ENTER]: "
read option

case ${option} in
	1) patch ;;
	2) deploy ;;
	*)
		echo ""
		echo "++++++++++++++++++++++++++++++"
		echo "+                            +"
		echo "+  Noob Spotted, Go away !!  +"
		echo "+                            +"
		echo "++++++++++++++++++++++++++++++"
		echo ""
		exit 1
		;;
esac

sleep 10
