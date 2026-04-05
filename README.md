# Cosmic Library - 실시간 1:1 Q&A 통신망

Spring Framework와 WebSocket을 기반으로 구축된 **고객센터(CS) 실시간 1:1 채팅 솔루션**입니다. 
도서관 컨셉에 맞춘 UI/UX와 함께 관리자와 사용자 간의 원활한 소통을 위한 다양한 편의 기능을 제공합니다.

## 🛠 Tech Stack
- **Backend:** Java, Spring Framework 5, Spring WebSocket, JDBC
- **Database:** H2 Database
- **Frontend:** JSP, Bootstrap 5, Vanilla JavaScript, CSS3
- **Build Tool:** Maven

---

## 📂 Project Structure

\`\`\`text
com.cosmic.library.qnachat
 ├── controller
 │    └── QnaChatController.java     # View 라우팅 및 로그인 권한 검증
 ├── handler
 │    └── QnaChatHandler.java        # WebSocket 세션 관리 및 1:1 메시지 라우팅
 ├── model
 │    └── QnachatVO.java             # 채팅 데이터 전송 객체 (Timestamp 포함)
 ├── repository
 │    ├── QnaChatDAO.java
 │    └── QnaChatDAOH2.java          # DB 쿼리 실행 및 조인 (채팅 내역 불러오기)
 └── service
      ├── QnaChatService.java
      └── QnaChatServiceImple.java   # 비즈니스 로직 처리
\`\`\`
- **Views:** `/WEB-INF/views/pages/QnA/qnachat.jsp` (채팅 UI), `header.jsp` (글로벌 알람)

---

## Core Features (주요 기능)

### 1. Global Notification (글로벌 알람 시스템)
- 사용자가 사이트 내 어느 페이지에 있더라도 `header.jsp`에 내장된 글로벌 웹소켓을 통해 서버와 통신을 유지합니다.
- 새로운 문의나 답변 도착 시 상단 고정(Sticky) 네비게이션 바에 실시간으로 **'New' 뱃지**가 점등되어 즉각적인 인지가 가능합니다.

### 2. Admin Switchboard (관리자 다중 채팅 관리 뷰)
- **화면 분할:** 관리자 권한(`SUPER`, `QNAadmin`)으로 접속 시, 좌측에는 문의 대기 중인 유저 목록이, 우측에는 선택한 유저와의 1:1 채팅방이 렌더링됩니다.
- **스마트 알람:** 과거 채팅 내역을 스캔하여 '마지막 메시지가 유저인 방(미답변 상태)'에만 New 뱃지를 표시하여 응답 누락을 방지합니다.

### 3. Intelligent Fallback (지능형 부재중 처리)
- **오프라인 감지:** 유저가 메시지를 보낼 때 서버에 접속 중인 관리자가 0명일 경우, 즉시 시스템 알림을 보내 기다림 없이 '문의 게시판 이동' 버튼을 노출합니다.
- **60초 타임아웃:** 관리자가 온라인이더라도 60초 내에 답변이 오지 않으면 사용자 경험(UX) 이탈을 막기 위해 문의 게시판으로 유도하는 UI가 활성화됩니다.

### 4. Persistence & Timestamp (데이터 동기화 및 기록)
- 채팅방 입장 시 H2 데이터베이스에서 과거 대화 내역(`QNA_CHAT` 테이블)을 자동으로 불러와 끊김 없는 상담 문맥을 유지합니다.
- DB에 기록된 전송 시간(`sendTime`)을 프론트엔드에서 `HH:mm` 형식으로 파싱하여 말풍선에 배치, 직관적인 시간 흐름 파악이 가능합니다.

---

## Troubleshooting (문제 해결 과정)

**1. N:N 브로드캐스팅 오류를 1:1 통신망으로 개선**
- **문제:** 단순 반복문 발송으로 인해 모든 접속자에게 메시지가 노출됨.
- **해결:** `ConcurrentHashMap`을 활용해 세션 ID와 유저 권한을 매핑하고, 수신자(`receiverId`)를 지정하는 1:1 타겟팅 라우팅 로직을 백엔드에 구현.

**2. 페이지 이동 시 발생하는 알람 오작동 해결**
- **문제:** 페이지 이동 시 웹소켓이 재연결되며 불러오는 과거 내역을 새 메시지로 인식하여 알람이 울림.
- **해결:** 서버에서 과거 내역 전송 완료 후 `HISTORY_DONE` 플래그를 발송. 프론트엔드에서 해당 플래그 수신 이후의 메시지만 새 알람으로 처리하도록 로직 개선.

---

## How to Run
1. `pom.xml`에 명시된 Spring WebSocket 및 Jackson 의존성을 다운로드합니다.
2. H2 Database 콘솔에서 `QNA_CHAT` 테이블을 생성합니다. (제공된 SQL 스크립트 참고)
3. Tomcat 서버(v9.0 권장)를 기동하여 `http://localhost:8888/` (포트 및 경로 설정에 따라 다름)로 접속합니다.
