package com.cosmic.library.member.model;

import java.sql.Timestamp;
import lombok.Data;
import lombok.Getter;

@Data
public class MemberVO {
    // 1. COSMIC_USER 테이블 매핑 필드
    private String id;          // 회원 ID 또는 비회원 쿠키 UUID (DB: user_id)
    private String pw;          // 회원 비밀번호 (비회원 NULL) (DB: user_pw)
    private String name;        // 대원 호출명 (비회원 'GUEST') (DB: user_name)
    private int is_member;      // 1:회원, 0:비회원
    private int points;         // 대원이 보유한 현재 적립금
    private String email;       // 연락용 이메일
    private String address; // 🛸 실시간 배송지 주소 컬럼 싱크 장착
    private Timestamp regDate;  // 최초 유입 일시

    // 2. USER_REGISTRATION 테이블 매핑 필드 (조인 및 로그인 세션 편의용 확장)
    private int user_reg_num;   // ★ 활동 기준 번호 (모든 거래의 참조점!)
    private String reg_status;  // 활동 상태 (ACTIVE, GUEST, BLOCK)

}