package com.cosmic.library.qnamail.service;

import java.util.List;
import com.cosmic.library.qnamail.model.QnAMailVO;

public interface QnAMailService {
    
    // 1. 문의 등록 (DB 저장 + 알림 시뮬레이션)
    void createInquiry(QnAMailVO qnamailvo);

    // 2. 전체 문의 조회 (관리자용 관제 화면)
    List<QnAMailVO> getAllInquiries();

    // 3. 특정 문의 상세 분석
    QnAMailVO getInquiryById(int id);

    // 4. 문의 데이터 영구 말소 (관리자용)
    void deleteInquiry(int id);

    // 5. 관리자의 응답(답변) 등록 및 전송
    void replyInquiry(int id, String answer);

    // 6. 특정 대원의 내 문의 내역 추적 (mail -> name 규격 적용)
    List<QnAMailVO> getMyInquiries(String name);
}