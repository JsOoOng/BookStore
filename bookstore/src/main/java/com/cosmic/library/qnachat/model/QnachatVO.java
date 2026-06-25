package com.cosmic.library.qnachat.model;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class QnachatVO {

    private int chatId;

    private Integer senderPid;
    private Integer receiverPid;

    private String senderId;
    private String receiverId;

    private String senderRole;

    private String message;

    private Timestamp sendTime;
}