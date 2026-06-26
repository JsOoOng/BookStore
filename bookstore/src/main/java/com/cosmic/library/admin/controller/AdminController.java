package com.cosmic.library.admin.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.cosmic.library.statistics.model.SalesSummaryVO;
import com.cosmic.library.statistics.model.SalesTrendVO;
import com.cosmic.library.statistics.model.SoldProductVO;
import com.cosmic.library.statistics.model.VendorOptionVO;
import com.cosmic.library.statistics.model.SalesCompareTrendVO;
import com.cosmic.library.vendor.service.ProductSaleService;

import com.cosmic.library.admin.model.AdminVO;
import com.cosmic.library.admin.service.AdminService;
import com.cosmic.library.member.model.MemberVO;
import com.cosmic.library.vendor.model.SalesVolumeVO;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private AdminService adminService; // 🌟 인터페이스 타입 주입으로 구조적 무결성 확보!

    @Autowired
    private ProductSaleService productSaleService;

    /**
     * 🔒 1. 관리자 전용 로그인 페이지 요청 ➔ 3단 통합 로그인 창으로 리다이렉트 워프
     * (정화 포인트: admin/login.jsp 폐기에 따른 궤도 수정)
     */
    @GetMapping("/login")
    public String adminLoginForm() {
        // 🚀 더 이상 뷰 조각을 리턴하지 않고, 통합 탭이 장착된 member/login으로 강제 송환!
        return "redirect:/member/login";
    }

    /**
     * 🔑 2. 관리자 로그인 처리 (POST)
     */
    @PostMapping("/login")
    public String adminLoginProcess(@RequestParam("adminId") String adminId,
                                    @RequestParam("adminPw") String adminPw,
                                    HttpSession session) {

        AdminVO loginAdmin = adminService.login(adminId, adminPw);

        if (loginAdmin != null) {

            session.setAttribute("loginAdmin", loginAdmin);

            // 다른 로그인 세션과 충돌 방지
            session.removeAttribute("loginMember");
            session.removeAttribute("loginUser");
            session.removeAttribute("loginVendor");
            session.removeAttribute("vRegNum");

            String role = loginAdmin.getRole();

            if ("SUPER".equals(role)) {
                return "redirect:/admin/userControl";
            }

            if ("VENDOR_ADMIN".equals(role)) {
                return "redirect:/admin/purchase/salesvolume";
            }

            return "redirect:/";
        }

        return "redirect:/member/login?error=true";
    }

    /**
     * 👑 3. [최고 사령실] 대원 통제 센터 (오직 SUPER 권한만 진입 허용)
     */
    @GetMapping("/userControl")
    public String userControl(Model model, HttpSession session) {
        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");
        
        // 🛡️ 이중 보안 장벽: 세션 검증 및 BASE_ADMIN 테이블의 role 스펙 체킹
        if (loginAdmin == null || !"SUPER".equals(loginAdmin.getRole())) {
            System.out.println("🚨 관제소 경고: 권한 없는 사용자가 사령부 총괄 통제 센터 진입 시도! 차단합니다.");
            return "redirect:/";
        }

        // 인터페이스를 통해 대원 행성의 모든 일반 회원 목록 수집
        List<MemberVO> memberList = adminService.getAllMembers();
        model.addAttribute("memberList", memberList);
        
        // 🚀 포인터 좌표: WEB-INF/views/pages/admin/userControl.jsp
        model.addAttribute("pageName", "pages/admin/userControl");
        return "common/layout";
    }

    /**
     * ⚙️ 4. 일반 대원 활동 상태 제어 프로토콜 (ACTIVE ➔ BLOCK 등 계급/상태 조정)
     */
    @GetMapping("/changeStatus")
    public String changeStatus(@RequestParam("id") String id, 
                               @RequestParam("status") String status, 
                               HttpSession session) {
        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");
        
        // 권한 방어벽
        if (loginAdmin == null || !"SUPER".equals(loginAdmin.getRole())) {
            return "redirect:/";
        }
        
        adminService.changeMemberStatus(id, status);
        return "redirect:/admin/userControl"; 
    }

    /**
     * ❌ 5. 불량 대원 블랙홀 추방 프로토콜 (Kick)
     */
    @GetMapping("/kick")
    public String kickMember(@RequestParam("id") String id, HttpSession session) {
        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");
        
        // 권한 방어벽
        if (loginAdmin == null || !"SUPER".equals(loginAdmin.getRole())) {
            return "redirect:/";
        }
        
        adminService.kickMember(id);
        return "redirect:/admin/userControl"; 
    }
    
    /**
     * 👑 6. [사령부 전용] 관리자 관리 패널 (오직 SUPER 권한만 진입 허용)
     */
    @GetMapping("/adminControl")
    public String adminControl(Model model, HttpSession session) {
        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");
        
        if (loginAdmin == null || !"SUPER".equals(loginAdmin.getRole())) {
            System.out.println("🚨 경고: 권한 없는 자가 사령부 핵심 관리자 패널 진입 시도! 차단합니다.");
            return "redirect:/";
        }

        // 모든 관리자 명단 수집
        List<AdminVO> adminList = adminService.getAllAdmins();
        model.addAttribute("adminList", adminList);
        
        // 🚀 포인터 좌표: WEB-INF/views/pages/admin/adminControl.jsp
        model.addAttribute("pageName", "pages/admin/adminControl");
        return "common/layout";
    }

    /**
     * 👑 7. 관리자 권한 자유 변동 프로토콜
     */
    @GetMapping("/changeAdminRole")
    public String changeAdminRole(@RequestParam("adminId") String adminId, 
                                  @RequestParam("role") String role, 
                                  HttpSession session) {
        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");
        if (loginAdmin == null || !"SUPER".equals(loginAdmin.getRole())) {
            return "redirect:/";
        }
        
        // 최고 사령관이 본인의 권한을 낮추는 자해 행위 방어 코드
        if (loginAdmin.getAdminId().equals(adminId)) {
            return "redirect:/admin/adminControl?error=self_mutation_blocked";
        }
        
        adminService.changeAdminRole(adminId, role);
        return "redirect:/admin/adminControl"; 
    }

    /**
     * 👑 8. 하위 관리자 해임 및 영구 퇴출 프로토콜
     */
    @GetMapping("/fireAdmin")
    public String fireAdmin(@RequestParam("adminId") String adminId, HttpSession session) {
        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");
        if (loginAdmin == null || !"SUPER".equals(loginAdmin.getRole())) {
            return "redirect:/";
        }
        
        if (loginAdmin.getAdminId().equals(adminId)) {
            return "redirect:/admin/adminControl?error=self_fire_blocked";
        }
        
        adminService.fireAdmin(adminId);
        return "redirect:/admin/adminControl"; 
    }
    
    /**
     * 👑 9. [최고 관리자 전용] 신규 하위 관리자 임명 프로토콜 (POST)
     */
    @PostMapping("/registerAdmin")
    public String registerAdmin(@ModelAttribute AdminVO admin, HttpSession session) {
        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");
        
        // 🛡️ 보안 장벽: 오직 SUPER 권한을 가진 최고 사령관만 임명 가능
        if (loginAdmin == null || !"SUPER".equals(loginAdmin.getRole())) {
            return "redirect:/";
        }
        
        // 아이디 중복 체크 로직을 넣으면 더 좋으나, 우선 심플 인서트 프로세스 가동!
        adminService.registerAdmin(admin);
        
        return "redirect:/admin/adminControl?regSuccess=true";
    }
    
    private boolean canViewSalesStats(AdminVO loginAdmin) {
        return loginAdmin != null &&
                ("SUPER".equals(loginAdmin.getRole())
                || "VENDOR_ADMIN".equals(loginAdmin.getRole()));
    }

    /**
     * 10. 📊 [SUPER / VENDOR_ADMIN 전용] 전체 협력업체 판매 통계 페이지
     */
    @GetMapping("/purchase/salesvolume")
    public String adminSalesVolumePage(HttpSession session, Model model) {

        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");

        if (loginAdmin == null) {
            return "redirect:/member/login";
        }

        if (!canViewSalesVolume(loginAdmin)) {
            return "redirect:/";
        }

        model.addAttribute("loginAdmin", loginAdmin);
        model.addAttribute("pageName", "pages/admin/salesvolume");

        return "common/layout";
    }

    /**
     * 📊 11. [SUPER / VENDOR_ADMIN 전용] 전체 도서 판매량 통계 데이터 API
     */
    @ResponseBody
    @GetMapping("/purchase/salesvolume/data")
    public List<SalesVolumeVO> adminSalesVolumeData(
            @RequestParam(value = "period", defaultValue = "hour") String period,
            HttpSession session) {

        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");

        if (loginAdmin == null) {
            return java.util.Collections.emptyList();
        }

        boolean canViewSalesVolume =
                "SUPER".equals(loginAdmin.getRole())
                || "VENDOR_ADMIN".equals(loginAdmin.getRole());

        if (!canViewSalesVolume) {
            return java.util.Collections.emptyList();
        }

        return productSaleService.getAdminSalesVolume(period);
    }
    
    /**
     * 📊 판매 통계 접근 권한 체크
     * SUPER / VENDOR_ADMIN만 접근 가능
     */
    private boolean canViewSalesVolume(AdminVO loginAdmin) {
        return loginAdmin != null &&
                ("SUPER".equals(loginAdmin.getRole())
                || "VENDOR_ADMIN".equals(loginAdmin.getRole()));
    }
    
    /**
     * 🏢 관리자용 협력업체 선택 목록
     */
    @ResponseBody
    @GetMapping("/purchase/salesvolume/vendors")
    public List<VendorOptionVO> adminVendorOptions(HttpSession session) {

        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");

        if (!canViewSalesStats(loginAdmin)) {
            return java.util.Collections.emptyList();
        }

        return productSaleService.getVendorOptions();
    }
    
    /**
     * 📊 관리자 판매 요약 카드 API
     * vRegNum = 0이면 전체 회사
     * vRegNum > 0이면 특정 회사
     */
    @ResponseBody
    @GetMapping("/purchase/salesvolume/summary")
    public SalesSummaryVO adminSalesSummary(
            @RequestParam("startDate") String startDate,
            @RequestParam("endDate") String endDate,
            @RequestParam(value = "vRegNum", defaultValue = "0") Integer vRegNum,
            HttpSession session) {

        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");

        if (!canViewSalesVolume(loginAdmin)) {
            return new SalesSummaryVO();
        }

        return productSaleService.getSalesSummary(startDate, endDate, vRegNum);
    }
    
    /**
     * 📈 관리자 기간별 판매 통계 그래프 API
     */
    @ResponseBody
    @GetMapping("/purchase/salesvolume/trend")
    public List<SalesTrendVO> adminSalesTrend(
            @RequestParam(value = "period", defaultValue = "day") String period,
            @RequestParam("startDate") String startDate,
            @RequestParam("endDate") String endDate,
            @RequestParam(value = "vRegNum", defaultValue = "0") Integer vRegNum,
            HttpSession session) {

        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");

        if (!canViewSalesStats(loginAdmin)) {
            return java.util.Collections.emptyList();
        }

        return productSaleService.getSalesTrend(period, startDate, endDate, vRegNum);
    }
    
    /**
     * 📚 관리자 특정 기간 판매 상품 목록 API
     */
    @ResponseBody
    @GetMapping("/purchase/salesvolume/products")
    public List<SoldProductVO> adminSoldProducts(
            @RequestParam("startDate") String startDate,
            @RequestParam("endDate") String endDate,
            @RequestParam(value = "vRegNum", defaultValue = "0") Integer vRegNum,
            HttpSession session) {

        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");

        if (!canViewSalesStats(loginAdmin)) {
            return java.util.Collections.emptyList();
        }

        return productSaleService.getSoldProducts(startDate, endDate, vRegNum);
    }
    
    /**
     * ⚖️ 관리자 두 협력업체 비교 그래프 API
     */
    @ResponseBody
    @GetMapping("/purchase/salesvolume/compare")
    public List<SalesCompareTrendVO> adminSalesCompareTrend(
            @RequestParam(value = "period", defaultValue = "day") String period,
            @RequestParam("startDate") String startDate,
            @RequestParam("endDate") String endDate,
            @RequestParam(value = "metric", defaultValue = "totalRevenue") String metric,
            @RequestParam("vendorA") int vendorA,
            @RequestParam("vendorB") int vendorB,
            HttpSession session) {

        AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin");

        if (!canViewSalesStats(loginAdmin)) {
            return java.util.Collections.emptyList();
        }

        if (vendorA <= 0 || vendorB <= 0 || vendorA == vendorB) {
            return java.util.Collections.emptyList();
        }

        return productSaleService.getSalesCompareTrend(
                period,
                startDate,
                endDate,
                metric,
                vendorA,
                vendorB
        );
    }
}