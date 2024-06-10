content.jsp와 updateForm.jsp 그리고 updatePro.jsp 부분을 스프링부트로 변경하는 작업을 해야 한다.

  조회수: readCountUp 
  모든 타입을 검색하고 있기 떄문에 DTO로 resultType 해야 한다.
    왜냐하면 DTO로 받아야 View까지 전달되기 때문이다. requestParam으로 받으면 View까지 전달이 안 된다.
      그래서 @modelAttribute 어노테이션 해줘야 한다.

컨트롤에서 요청하고 컨트롤에서 서비스, 서비스에서 리포지토리, 그리고 뷰

BoardController.java
  @RequestMapping("/board/*") - 리퀘스트 매핑으로 /board/가 일괄 적용 된다는 뜻이다. 이건 매핑주소에 /board/를 생략하기 위한 작업이다. 홈페이지를 실행할 때엔 /board/writeForm 이렇게 실행해야 한다.

CRUD (Create - insert 삽입/ Read - select 검색 / Update -alert 수정 / Delete - drop 삭제)

----------------------------------------
# BoardService.java
	// 게시판에 글을 쓰는 방법을 설명해주는 코드
	public void boardCreate(BoardDTO boardDTO) {
		int maxNum = boardMapper.maxNum();		// 데이터베이스에서 가장 큰 글 번호를 가져옴
		if(boardDTO.getNum()!=0) {		// 답글인지 새 글인지를 확인. 0이 아니면 답글, 0이면 새 글
			boardMapper.reStepUp(boardDTO);	// 다른 답글들의 순서를 바꾸는 작업
			boardDTO.setRe_step(boardDTO.getRe_step()+1);	// 값 설정
			boardDTO.setRe_level(boardDTO.getRe_level()+1);
		}else {	// 0이면 새 글
			if(maxNum != 1) {		// 새 글이면 maxNum 값을 1 더해줌
				maxNum += 1;
			} 
			boardDTO.setRef(maxNum);	// boardDTO 의 ref 값을 새 번호로 설정
		}
		boardMapper.boardInsert(boardDTO);	// 새 글을 데이터베이스에 저장
	}
	// list 랑 count 결과를 각각 보내줘야해서 서비스를 나누었음
	public int countAll() {
		return  boardMapper.countAll();
	}
	// 전체 검색 - 스타트와 엔드가 필요 - count 를 가져오고 list 가 0보다 클 때
	// 게시판에서 여러 개의 글을 가져오는 역할 - start end 라는 숫자를 받아서 그 사이에 있는 글들을 가져옴
	// boardList 를 호출해서 글 목록을 가져옴
	public List<BoardDTO> boardReadAll(int start, int end){
			return boardMapper.boardList(start, end);
	}
	// 조회수 - 리드카운트 - 조회수 글을 올려주고 해당 값으로 리턴 
	// 글 번호를 받아서, 먼저 그 글의 조회수를 1 증가시킴
	// 보드 매퍼의 리드카운트 업을 호출해서 조회수를 올림
	// 조회수를 올린 후 보드넘을 호출해서 글 번호에 해당하는 글을 가져오고 반환해줌
	public  BoardDTO readNum(int num) {
		boardMapper.readcountUp(num);
		return boardMapper.boardNum(num);
	}
	// 업데이트 폼 - 수정 (위랑 동일한데 조회수는 올려주면 안됨)
	// 수정하기 위해 글 번호를 받아서 보드넘을 호출해서 그 번호에 해당하는 글을 가져오고 반환해줌
	public  BoardDTO updateForm(int num) {
		return boardMapper.boardNum(num);
	}
	// 업데이트 프로 - 비밀번호가 맞아야 게시판 수정 가능 (폼에서 입력받은 비번이랑 db 에 저장되어있는 비번이랑)
	public int updatePro(BoardDTO boardDTO) {
		int result = 0;	// 업데이트 성공 여부를 나타내는 변수
		String dbPw = boardMapper.passwdNum(boardDTO.getNum());		// 비밀번호 가져오기
		// 데이터베이스에 저장된 비밀번호를 가져옴. 수정하려는 글의 번호도 가져옴
		// 그 번호에 해당하는 글의 비밀번호를 얻을 수 있음
		if(dbPw.equals(boardDTO.getPasswd())) {	// 비밀번호 비교하기 - 이퀄스 메서드를 사용해서 데이터베이스에 있는 비밀번호와 사용자가 입력한 비밀번호를 비교함
			result = boardMapper.boardUpdate(boardDTO);	// 같으면 보드업데이트를 호출해서 글을 수정함
		}
		return result;	// 결과 반환 - 업데이트가 성공했는지 실패했는지를 알려줌
	}
	// 딜리트 프로 - 비밀번호가 맞아야함 (폼에서 입력받은 비번이랑 db 에 저장되어있는 비번이랑) 업데이트랑 동일
	// 리포지토리 안 비밀번호랑 dto 의 글번호를 가져옴
	// 데이터베이스에 저장된 비밀번호랑 사용자가 입력한 비밀번호가 같으면 글을 삭제시키고 성공 여부 값을 반환함
	public int deletePro(BoardDTO boardDTO) {
		int result = 0;
		String dbPw = boardMapper.passwdNum(boardDTO.getNum());
		if(dbPw.equals(boardDTO.getPasswd())) {
			result = boardMapper.boardDelete(boardDTO.getNum());
		}
		return result;
	}

----------------------------------
BoardController.java

package com.board.controller;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.board.data.BoardDTO;
import com.board.service.BoardService;

import jakarta.servlet.http.HttpServletRequest;

@Controller
@RequiredArgsConstructor
@RequestMapping("/board/*")

public class BoardController {
	private final BoardService boardService;
	// 리퀘스트매핑으로 /board/가 일괄적용됨 그래서 매핑주소에 생략해야함 - 실행할땐 /보드/붙여줘야함
	// 롸이트폼에서 답글쓰기 어쩌고 파라미터 받아야하니까 
	@GetMapping("writeForm")
	public String writeForm(BoardDTO boardDTO) {
		return "writeForm";
	}
	
	@PostMapping("writePro")
	// 폼에서 파라미터는 자동으로 넘어가니까 우리는 아이피만 넣어주면 된다.
	public String writePro(BoardDTO boardDTO, HttpServletRequest request) {
		boardDTO.setIp(request.getRemoteAddr());
		boardService.boardCreate(boardDTO);
		return "redirect:/board/list";
	}
	// pageNum 은 dto 에 없기 때문에 따로 받아야한다 - 파라미터이름이 페이지넘 - 없으면 기본값 1을 넣어주겠다.
	// 게시판 글 목록을 보여주는 역할
	@GetMapping("list")
	// 사용자가 보고싶은 페이지 번호를 받음. 입력하지 않으면 기본값은 1번 페이지 
	public String list(Model model, @RequestParam(name="pageNum",defaultValue = "1") int pageNum) {
		int pageSize = 10;		// 한 페이지에 보여줄 글의 개수
		int currentPage =pageNum;	// 현재 보고 있는 페이지 번호 설정
	    int start = (currentPage - 1) * pageSize + 1;	// 현재 페이지에서 첫 번째로 보여줄 글의 번호 계산
	    int end = currentPage * pageSize;	// 현재 페이지에서 마지막으로 보여줄 글의 번호 계산
	    int count = boardService.countAll(); // 데이터베이스에서 전체 글의 개수를 가져옴 - list 로 리턴
	
	    List<BoardDTO> list = null;	    // 글 목록을 저장할 변수 선언
	    if(count > 0) {		// 전체 글의 개수가 0보다 크면
	    	list = boardService.boardReadAll(start, end);	// 시작 글 번호와 끝 글 번호 사이의 글들을 가져옴	    	
	    }
	    int pageCount = count / pageSize + ( count % pageSize == 0 ? 0 : 1);	// 전체 글의 개수를 페이지 크리고 나눠 필요한 전체 페이지 수를 계산
        int startPage = (int)(currentPage/10)*10+1;	// 현재 페이지에서 시작 페이지 번호를 계산
		int pageBlock=10;	// 한 번에 보여줄 페이지 번호 개수 설정
        int endPage = startPage + pageBlock-1;	// 현재 페이지에서 끝 페이지 번호 계산
        if (endPage > pageCount) {	// 끝 페이지 번호가 전체 페이지 수를 넘으면 끝 페이지 번호를 전체 페이지 수로 맞춤
        	endPage = pageCount;	}
                
	    // 위에 있는 변수를 똑같이 다 보내주는 것 - 계산한 값들을 모델에 추가해서, 나중에 웹 페이지에서 사용할 수 있게 함
	    model.addAttribute("pageCount",pageCount);
	    model.addAttribute("startPage",startPage);
	    model.addAttribute("pageBlock",pageBlock);
	    model.addAttribute("endPage",endPage);
        
        model.addAttribute("pageSize", pageSize);
	    model.addAttribute("pageNum", pageNum);
	    model.addAttribute("start", start);
	    model.addAttribute("end", end);
	    model.addAttribute("count", count);
	    model.addAttribute("list", list);
		
	    return "list";		// list라는 이름의 웹 페이지를 보여줘라 >> 사용자가 웹 페이지에서 게시판의 글 목록을 페이지별로 볼 수 있게 됨
	}










