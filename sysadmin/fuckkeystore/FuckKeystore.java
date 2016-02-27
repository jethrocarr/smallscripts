/*
 * Takes file "keystore.passworded" with password "password" and generates
 * a new file "keystore.nopassword" with a blank password.
 *
 * Inspired http://stackoverflow.com/a/236858
*/

import java.security.*;
import java.io.IOException;
import java.io.FileOutputStream;
import java.io.FileInputStream;

public class FuckKeystore
{
    public static void main(String[] args) {
        try {
            // Creating an empty JKS keystore
            KeyStore keystore = KeyStore.getInstance(KeyStore.getDefaultType());

            // Hard coded password "password"
            char[] password ={ 'p', 'a', 's', 's', 'w', 'o', 'r', 'd'};

            // Load the existing keystore
            java.io.FileInputStream fis = null;
            try {
                fis = new java.io.FileInputStream("keystore.passworded");
                keystore.load(fis, password);
            } finally {
                if (fis != null) {
                  fis.close();
                }
            }

            // Saving the keystore with a zero length password
            FileOutputStream fout = new FileOutputStream("keystore.nopassword");
            keystore.store(fout, new char[0]);
        } catch (GeneralSecurityException | IOException e) {
           // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}
