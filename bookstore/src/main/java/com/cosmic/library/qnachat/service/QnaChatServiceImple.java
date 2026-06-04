package com.cosmic.library.qnachat.service;

import com.cosmic.library.qnachat.model.QnachatVO;
import com.cosmic.library.qnachat.repository.QnaChatDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class QnaChatServiceImple implements QnaChatService {
    
    @Autowired 
    private QnaChatDAO qnaChatDAO;
    
    @Override 
    public void saveMessage(QnachatVO vo) { 
        // 🪐 [방어선 가동] 일반 대원이 'ADMIN' 뭉텅이를 타겟으로 무전을 치면, 
        // 사령부의 실존하는 마스터 관리자 ID로 스위칭하여 DAO의 서브쿼리를 안전하게 통과시킵니다.
        if ("ADMIN".equals(vo.getReceiverId())) {
            vo.setReceiverId("QNAadmin"); // 💡 사령관의 BASE_ADMIN 테이블에 등록된 실제 관리자 ID로 매pping!
        }
        
        qnaChatDAO.insertMessage(vo); 
    }
    
    @Override 
    public List<QnachatVO> getChatHistory(String userId, String role) { 
        return qnaChatDAO.getChatHistory(userId, role); 
    }
}