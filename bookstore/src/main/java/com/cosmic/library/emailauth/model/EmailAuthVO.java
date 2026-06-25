package com.cosmic.library.emailauth.model;

import java.sql.Timestamp;

public class EmailAuthVO {

    private String email;
    private String authCode;
    private String authYn;
    private Timestamp expireTime;
    private Timestamp regDate;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAuthCode() { return authCode; }
    public void setAuthCode(String authCode) { this.authCode = authCode; }

    public String getAuthYn() { return authYn; }
    public void setAuthYn(String authYn) { this.authYn = authYn; }

    public Timestamp getExpireTime() { return expireTime; }
    public void setExpireTime(Timestamp expireTime) { this.expireTime = expireTime; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }
}