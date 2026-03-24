package com.cosmic.library.qnamail.repository;

import java.util.List;
import com.cosmic.library.qnamail.model.QnAMailVO;

public interface QnAMailDAO {
    // 문의 등록
    void createInquiry(QnAMailVO qnamailvo);

    // 전체 문의 조회 (관리자용)
    List<QnAMailVO> getAllInquiries();

    // 특정 문의 조회
    QnAMailVO getInquiryById(int id);

    // 문의 삭제 (관리자용)
    void deleteInquiry(int id);
     
    // 관리자에게 문의 메일 발송 (매개변수 mail -> name 변경)
    void sendInquiryMail(String title, String name, String inquiry, String detail);

    // 답변 업데이트
    void updateAnswer(int id, String answer);

    // 특정 작성자 이름으로 문의 조회 (메소드명 명확화: getInquiriesByName)
    List<QnAMailVO> getInquiriesByName(String name);
}