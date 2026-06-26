package com.cosmic.library.vendor.repository;

import java.util.List;
import com.cosmic.library.vendor.model.VendorVO;

public interface VendorDAO {

    // 1. 신규 입점 업체 등록 (회원가입)
    int insert(VendorVO vendor);

    // 2. 업체 ID를 통한 정밀 단건 조회 (로그인 및 정보 확인용)
    VendorVO findById(String vendorId);

    // 3. 업체 로그인 검증 신호 (ID와 PW가 매칭되는지 확인)
    VendorVO login(String vendorId, String vendorPw);

    // 4. 입점 신청 시 업체 ID 중복 방어벽 (true: 사용 가능, false: 중복)
    boolean isIdAvailable(String vendorId);

    // 5. 전체 입점 업체 리스트 관제 (관리자 사령실 전용)
    List<VendorVO> findAll();

    // 6. 업체 정보 수정 (연락처, 상호명 등 변경)
    int update(VendorVO vendor);

    // 7. 입점 철회 및 퇴출 (삭제)
    int delete(String vendorId);
}