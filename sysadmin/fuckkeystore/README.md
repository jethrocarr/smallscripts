# FuckKeystore

Java's Keystore is probably the most horrible key/cert store I've ever had the
misfortune of running into on a *nix operating system. It's chief frustration
is that the keytool util requires all keystore files to be created with a 6
char password, but developers frequently write apps that use a null password
in order for the apps to start automatically.

This becomes a real pain if you need to change the keystore since you can't
generate a new one.

This tool allows you to convert a password protected keystore into one with
a blank password.


# Usage

You must have the JDK installed in order to build the Java file:

    apt-get install openjdk-7-jdk
    javac FuckKeystore.java


Once built, when executed, this tool takes a file "keystore.passworded"
with password "password" and generates a new file "keystore.nopassword"
with a blank password.

    java FuckKeystore


