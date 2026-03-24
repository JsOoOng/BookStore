package com.cosmic.library.qnamail.repository;

import java.util.List;

import com.cosmic.library.qnamail.model.QnAMailVO;


public interface QnAMailDAO {
	 // 문의 등록 (DB 저장 + 메일 발송까지 포함 가능)
    void createInquiry(QnAMailVO qnamailvo);

    // 전체 문의 조회 (관리자용)
    List<QnAMailVO> getAllInquiries();

    // 특정 문의 조회
    QnAMailVO getInquiryById(int id);

    // 문의 삭제 (관리자용)
    void deleteInquiry(int id);
     
    // 관리자에게 문의 메일 발송
    void sendInquiryMail(String title, String mail, String inquiry, String detail);

	void updateAnswer(int id, String answer);

	List<QnAMailVO> getInquiriesByMail(String mail);
}
