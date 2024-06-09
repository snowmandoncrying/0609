content.jsp와 updateForm.jsp 그리고 updatePro.jsp 부분을 스프링부트로 변경하는 작업을 해야 한다.

  조회수: readCountUp 
  모든 타입을 검색하고 있기 떄문에 DTO로 resultType 해야 한다.
    왜냐하면 DTO로 받아야 View까지 전달되기 때문이다. requestParam으로 받으면 View까지 전달이 안 된다.
      그래서 @modelAttribute 어노테이션 해줘야 한다.
