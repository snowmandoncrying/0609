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













