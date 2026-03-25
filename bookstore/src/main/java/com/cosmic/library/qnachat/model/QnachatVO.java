package com.cosmic.library.qnachat.model;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class QnachatVO {
    private int chatId;
    private String senderId;
    private String receiverId; // 문의자 또는 관리자 ID
    private String message;
    private Timestamp sendTime;
    private String senderRole; // USER, superadmin, QNAadmin 등
}