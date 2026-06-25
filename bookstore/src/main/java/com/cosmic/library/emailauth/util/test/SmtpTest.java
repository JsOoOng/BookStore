package com.cosmic.library.emailauth.util.test;

import java.util.Properties;
import javax.mail.*;

public class SmtpTest {

    public static void main(String[] args) {

        final String USER = "afaa26001@smtp-brevo.com";
        final String PASS = "xsmtpsib-9299cfb8ae2054e648b1689f479abc221d07868d46ffe6f8695b9e4a081361f1-Q8sMNcuclrLrSqA6"; // Brevo SMTP key

        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp-relay.brevo.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.debug", "true");

            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USER, PASS);
                }
            });

            Transport transport = session.getTransport("smtp");

            System.out.println("=== CONNECTING ===");
            transport.connect();   // 👉 여기서 성공/실패 갈림

            System.out.println("=== SUCCESS (AUTH OK) ===");

            transport.close();

        } catch (Exception e) {
            System.out.println("=== FAILED ===");
            e.printStackTrace();
        }
    }
}