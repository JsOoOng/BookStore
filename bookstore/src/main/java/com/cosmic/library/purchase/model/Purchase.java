package com.cosmic.library.purchase.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Purchase {

    private int id;
    private String memberId;
    private int bookId;
    private int price;
}