package com.cosmic.library.admin.model;

import java.sql.Timestamp;

public class AdminVO {
    private String adminId;     // 관리자 고유 ID (PK)
    private String adminPw;     // 암호화된 비밀번호
    private String adminName;   // 관리자 실명/호칭
    private String role;        // 🌟 핵심: SUPER, BOOK_ADMIN, MEMBER_ADMIN, VENDOR_ADMIN
    private Timestamp regDate;  // 사령부 등록일

    // Getter, Setter 생성 (또는 롬복 @Data 사용 시 생략 가능)
    public String getAdminId() { return adminId; }
    public void setAdminId(String adminId) { this.adminId = adminId; }
    
    public String getAdminPw() { return adminPw; }
    public void setAdminPw(String adminPw) { this.adminPw = adminPw; }
    
    public String getAdminName() { return adminName; }
    public void setAdminName(String adminName) { this.adminName = adminName; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }
}