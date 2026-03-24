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
   

    // 문의 등록 (DB 저장 + 메일 발송)
    public void createInquiry(QnAMailVO qnamailvo) {
        // 간단한 유효성 검사 예시
        if (qnamailvo.getTitle() == null || qnamailvo.getTitle().isEmpty()) {
            throw new IllegalArgumentException("문의 제목은 필수입니다.");
        }
        if (qnamailvo.getMail() == null || qnamailvo.getMail().isEmpty()) {
            throw new IllegalArgumentException("메일 주소는 필수입니다.");
        }

        // DAO를 통해 DB 저장
        qnAMailDAO.createInquiry(qnamailvo);

        // DAO를 통해 관리자에게 메일 발송
        qnAMailDAO.sendInquiryMail(
            qnamailvo.getTitle(),
            qnamailvo.getMail(),
            qnamailvo.getInquiry(),
            qnamailvo.getDetail()
        );
    }

    // 전체 문의 조회 (관리자용)
    public List<QnAMailVO> getAllInquiries() {
        return qnAMailDAO.getAllInquiries();
    }

    // 특정 문의 조회
    public QnAMailVO getInquiryById(int id) {
        return qnAMailDAO.getInquiryById(id);
    }

    // 문의 삭제 (관리자용)
    public void deleteInquiry(int id) {
        qnAMailDAO.deleteInquiry(id);
    }
}
