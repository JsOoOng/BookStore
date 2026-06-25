package com.cosmic.library.vendor.repository;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import com.cosmic.library.vendor.model.VendorVO;

@Repository
public class VendorDAOH2 implements VendorDAO {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 🌟 [수리 완료] 데이터베이스 조인 결과를 모두 담을 수 있도록 RowMapper 확장!
    private final RowMapper<VendorVO> rowMapper = (rs, rowNum) -> {
        VendorVO vo = new VendorVO();
        vo.setVendorId(rs.getString("vendor_id"));
        vo.setVendorPw(rs.getString("vendor_pw"));
        vo.setBizName(rs.getString("biz_name"));
        vo.setBizNo(rs.getString("biz_no"));
        vo.setContact(rs.getString("contact"));
        vo.setRegDate(rs.getTimestamp("regDate"));
        
        // 💥 [핵심 방어막] VENDOR_REGISTRATION과 JOIN 할 때만 데이터가 있으므로, 
        // 에러를 방지하기 위해 try-catch로 감싸서 값을 담아준다!
        try {
            vo.setVendorRegNum(rs.getInt("vendor_reg_num"));
        } catch (Exception e) {
            // 조인이 없는 단순 VENDOR 조회 쿼리에서는 이 컬럼이 없으므로 무시한다.
        }
        return vo;
    };

    // 1. 신규 입점 업체 등록 (회원가입)
    @Override
    public int insert(VendorVO vendor) {
        String sql = "INSERT INTO VENDOR (vendor_id, vendor_pw, biz_name, biz_no, contact) "
                   + "VALUES (?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, 
                vendor.getVendorId(), 
                vendor.getVendorPw(), 
                vendor.getBizName(), 
                vendor.getBizNo(), 
                vendor.getContact());
    }

    // 2. 업체 ID를 통한 정밀 단건 조회
    @Override
    public VendorVO findById(String vendorId) {
        String sql = "SELECT * FROM VENDOR WHERE vendor_id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, rowMapper, vendorId);
        } catch (EmptyResultDataAccessException e) {
            return null; // 조회된 업체가 없을 때 예외 방어막
        }
    }

    // 3. 💥 [핵심 수리 완료] 업체 로그인 검증 신호 (JOIN 쿼리로 개조!)
    @Override
    public VendorVO login(String vendorId, String vendorPw) {
        // VENDOR와 VENDOR_REGISTRATION을 조인하여 활동 승인 번호(vendor_reg_num)까지 싹 다 긁어온다!
        String sql = "SELECT v.*, vr.vendor_reg_num "
                   + "FROM VENDOR v "
                   + "JOIN VENDOR_REGISTRATION vr ON v.vendor_id = vr.vendor_id "
                   + "WHERE v.vendor_id = ? AND v.vendor_pw = ?";
        try {
            return jdbcTemplate.queryForObject(sql, rowMapper, vendorId, vendorPw);
        } catch (EmptyResultDataAccessException e) {
            return null; // ID/PW가 틀렸거나 일치하는 데이터가 없을 때
        }
    }

    // 4. 입점 신청 시 업체 ID 중복 방어벽 (count 검사)
    @Override
    public boolean isIdAvailable(String vendorId) {
        String sql = "SELECT COUNT(*) FROM VENDOR WHERE vendor_id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, vendorId);
        return count != null && count == 0; // 0개면 사용 가능(true), 그 이상이면 중복(false)
    }

    // 5. 전체 입점 업체 리스트 관제 (Admin용)
    @Override
    public List<VendorVO> findAll() {
        String sql = "SELECT * FROM VENDOR ORDER BY regDate DESC";
        return jdbcTemplate.query(sql, rowMapper);
    }

    // 6. 업체 정보 수정
    @Override
    public int update(VendorVO vendor) {
        String sql = "UPDATE VENDOR SET biz_name = ?, biz_no = ?, contact = ? WHERE vendor_id = ?";
        return jdbcTemplate.update(sql, 
                vendor.getBizName(), 
                vendor.getBizNo(), 
                vendor.getContact(), 
                vendor.getVendorId());
    }

    // 7. 입점 철회 및 퇴출
    @Override
    public int delete(String vendorId) {
        String sql = "DELETE FROM VENDOR WHERE vendor_id = ?";
        return jdbcTemplate.update(sql, vendorId);
    }
}