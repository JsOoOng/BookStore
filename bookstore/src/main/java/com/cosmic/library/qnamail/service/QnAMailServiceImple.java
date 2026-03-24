package com.cosmic.library.qnamail.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.cosmic.library.qnamail.model.QnAMailVO;
import com.cosmic.library.qnamail.repository.QnAMailDAO;

@Service
public class QnAMailServiceImple implements QnAMailService {
    
    @Autowired
    private QnAMailDAO qnAMailDAO;

    // 1. 문의 등록 (DB 저장 + 시뮬레이션 메일 발송)
    @Override
    public void createInquiry(QnAMailVO qnamailvo) {
        // 🛡️ 유효성 검사 (mail -> name으로 변경)
        if (qnamailvo.getTitle() == null || qnamailvo.getTitle().isEmpty()) {
            throw new IllegalArgumentException("문의 제목은 필수입니다.");
        }
        if (qnamailvo.getName() == null || qnamailvo.getName().isEmpty()) {
            throw new IllegalArgumentException("작성자 정보(이름/ID)는 필수입니다.");
        }

        // DAO를 통해 DB 저장 (내부 SQL이 name 컬럼을 사용하도록 수정됨)
        qnAMailDAO.createInquiry(qnamailvo);

        // 관리자에게 알림 (시뮬레이션)
        qnAMailDAO.sendInquiryMail(
            qnamailvo.getTitle(),
            qnamailvo.getName(), // mail 대신 name 전달
            qnamailvo.getInquiry(),
            qnamailvo.getDetail()
        );
    }
    
    // 2. 내 문의 내역 조회 (유저용)
    @Override
    public List<QnAMailVO> getMyInquiries(String name) {
        // 🛰️ DAO의 메소드명도 변경된 규격(getInquiriesByName)에 맞춥니다.
        return qnAMailDAO.getInquiriesByName(name);
    }
    
    // 3. 답변 등록 (관리자용)
    @Override
    public void replyInquiry(int id, String answer) {
        qnAMailDAO.updateAnswer(id, answer);
    }

    // 4. 전체 문의 조회 (관리자용)
    @Override
    public List<QnAMailVO> getAllInquiries() {
        return qnAMailDAO.getAllInquiries();
    }

    // 5. 특정 문의 상세 조회
    @Override
    public QnAMailVO getInquiryById(int id) {
        return qnAMailDAO.getInquiryById(id);
    }

    // 6. 문의 데이터 삭제 (관리자용)
    @Override
    public void deleteInquiry(int id) {
        qnAMailDAO.deleteInquiry(id);
    }
}