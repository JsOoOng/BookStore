package com.cosmic.library.vendor.service;

import java.util.List;
import com.cosmic.library.vendor.model.VendorVO;

public interface VendorService {

    // 1. 입점 신청 (회원가입 처리)
    boolean register(VendorVO vendor);

    // 2. 업체 로그인 인증 (성공 시 VendorVO 반환, 실패 시 null)
    VendorVO login(String vendorId, String vendorPw);

    // 3. 아이디 중복 체크 (true: 가입 가능, false: 이미 존재하는 아이디)
    boolean checkIdAvailability(String vendorId);

    // 4. 특정 업체 정밀 조회
    VendorVO getVendorById(String vendorId);

    // 5. 전체 입점 업체 명부 조회 (관리자 전용)
    List<VendorVO> getAllVendors();

    // 6. 업체 정보 수정
    boolean modifyVendor(VendorVO vendor);

    // 7. 업체 탈퇴 및 정제 (삭제)
    boolean removeVendor(String vendorId);
}