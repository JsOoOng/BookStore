package com.cosmic.library.qnamail.service;

import java.util.List;

import com.cosmic.library.qnamail.model.QnAMailVO;

public interface QnAMailService {
	// 문의 등록 (DB 저장 + 메일 발송)
    void createInquiry(QnAMailVO qnamailvo);

    // 전체 문의 조회 (관리자용)
    List<QnAMailVO> getAllInquiries();

    // 특정 문의 조회
    QnAMailVO getInquiryById(int id);

    // 문의 삭제 (관리자용)
    void deleteInquiry(int id);
}
