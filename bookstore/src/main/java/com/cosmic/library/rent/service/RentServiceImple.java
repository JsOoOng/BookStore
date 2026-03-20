package com.cosmic.library.rent.service;

import java.util.List;

import org.springframework.transaction.annotation.Transactional;

import com.cosmic.library.rent.model.RentVO;

@Transactional
public class RentServiceImple implements RentService {

	public int rentBook(String memberId, int bookId) {
		// TODO Auto-generated method stub
		return 0;
	}

	public List<RentVO> findMyRentHistory(String memberId) {
		// TODO Auto-generated method stub
		return null;
	}

	public int cancelRent(int rentId) {
		// TODO Auto-generated method stub
		return 0;
	}

	public List<RentVO> findAllRentHistory() {
		// TODO Auto-generated method stub
		return null;
	}

	public int getRentCount(String memberId) {
		// TODO Auto-generated method stub
		return 0;
	}

}
