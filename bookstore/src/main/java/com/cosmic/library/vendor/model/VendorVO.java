package com.cosmic.library.vendor.model;

import java.sql.Timestamp;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class VendorVO {

	private int VendorRegNum;
    private String vendorId;    // 업체 고유 ID (PK)
    private String vendorPw;    // 업체 비밀번호
    private String bizName;     // 업체명/상호명 (DB: biz_name)
    private String bizNo;       // 사업자등록번호 (DB: biz_no)
    private String contact;     // 업체 연락처 (DB: contact)
    private Timestamp regDate;  // 입점 등록 일시 (DB: regDate)
}