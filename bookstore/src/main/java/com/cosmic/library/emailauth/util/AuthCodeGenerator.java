package com.cosmic.library.emailauth.util;

import java.util.Random;

public class AuthCodeGenerator {

    public static String generate() {
        return String.format("%06d", new Random().nextInt(1000000));
    }
}