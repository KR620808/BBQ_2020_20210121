<!-- #include virtual="/inc/config.asp" -->
<%
	CUR_PAGE_CODE = "E"
	PROCESS_PAGE = "Y"

	CD = InjRequest("CD")
	CUR_PAGE_SUBCODE = CD	'현재 선택된 서브메뉴에 대한 권한을 체크하기 위해서 설정
%>
<!-- #include virtual="/inc/admin_check.asp" -->
<%
	BIDX = InjRequest("BIDX")
	If FncIsBlank(BIDX) Then
		Response.Write "E^잘못된 접근방식입니다"
		Response.End 
	End If

	Sql = "	Delete From bt_board_succ Where BIDX = " & BIDX
	conn.Execute(Sql)

	Response.Write "Y^삭제되었습니다"
	Response.End 
%>
