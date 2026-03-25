package com.cosmic.library.qnachat.service;

import com.cosmic.library.qnachat.model.QnachatVO;
import com.cosmic.library.qnachat.repository.QnaChatDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class QnaChatServiceImple implements QnaChatService {

    @Autowired
    private QnaChatDAO qnaChatDAO;

    @Override
    public void saveMessage(QnachatVO vo) {
        qnaChatDAO.insertMessage(vo);
    }
}