package com.cosmic.library.qnachat.service;
import com.cosmic.library.qnachat.model.QnachatVO;
import com.cosmic.library.qnachat.repository.QnaChatDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class QnaChatServiceImple implements QnaChatService {
    @Autowired private QnaChatDAO qnaChatDAO;
    
    @Override public void saveMessage(QnachatVO vo) { qnaChatDAO.insertMessage(vo); }
    @Override public List<QnachatVO> getChatHistory(String userId, String role) { 
        return qnaChatDAO.getChatHistory(userId, role); 
    }
}