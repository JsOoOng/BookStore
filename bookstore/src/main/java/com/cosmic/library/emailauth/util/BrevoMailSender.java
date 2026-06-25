package com.cosmic.library.emailauth.util;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class BrevoMailSender {

    private static final String USER = "afaa26001@smtp-brevo.com";
    private static final String PASS = "xsmtpsib-9299cfb8ae2054e648b1689f479abc221d07868d46ffe6f8695b9e4a081361f1-Q8sMNcuclrLrSqA6";
    		
    public static void send(String toEmail, String code) {
    	
    	
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp-relay.brevo.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USER, PASS);
            }
        });
        
        
        try {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress("leeyg0212@gmail.com"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Cosmic 인증 코드");
            msg.setText("인증 코드: " + code);

            Transport.send(msg);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}