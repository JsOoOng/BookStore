package com.cosmic.library.vendor.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.cosmic.library.vendor.model.VendorVO;
import com.cosmic.library.vendor.repository.VendorDAO;

@Service
public class VendorServiceImpl implements VendorService {

    @Autowired
    private VendorDAO vendorDAO;

    // 1. 입점 신청 (회원가입 처리)
    @Override
    public boolean register(VendorVO vendor) {
        // 아이디 중복 방어벽 한 번 더 가동
        if (!vendorDAO.isIdAvailable(vendor.getVendorId())) {
            return false;
        }
        return vendorDAO.insert(vendor) > 0;
    }

    // 2. 업체 로그인 인증
    @Override
    public VendorVO login(String vendorId, String vendorPw) {
        return vendorDAO.login(vendorId, vendorPw);
    }

    // 3. 아이디 중복 체크
    @Override
    public boolean checkIdAvailability(String vendorId) {
        return vendorDAO.isIdAvailable(vendorId);
    }

    // 4. 특정 업체 정밀 조회
    @Override
    public VendorVO getVendorById(String vendorId) {
        return vendorDAO.findById(vendorId);
    }

    // 5. 전체 입점 업체 명부 조회 (관리자 전용)
    @Override
    public List<VendorVO> getAllVendors() {
        return vendorDAO.findAll();
    }

    // 6. 업체 정보 수정
    @Override
    public boolean modifyVendor(VendorVO vendor) {
        return vendorDAO.update(vendor) > 0;
    }

    // 7. 업체 탈퇴 및 정제
    @Override
    public boolean removeVendor(String vendorId) {
        return vendorDAO.delete(vendorId) > 0;
    }
}