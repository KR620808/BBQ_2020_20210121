<!-- #include virtual="/inc/config.asp" -->
<%
	CUR_PAGE_CODE = "E"
	CUR_PAGE_SUBCODE = ""
	CD = InjRequest("CD")
	If Not FncIsBlank(CD) Then CUR_PAGE_SUBCODE = CD	'현재 선택된 서브메뉴에 대한 권한을 체크하기 위해서 설정
	BBSCODE = InjRequest("BBSCODE")
%>
<!-- #include virtual="/inc/admin_check.asp" -->
<%
	SDATE	= InjRequest("SDATE")
	EDATE	= InjRequest("EDATE")
	SM		= InjRequest("SM")
	SW		= InjRequest("SW")
	LNUM	= InjRequest("LNUM")
	If FncIsBlank(SDATE) Then SDATE = Date 
	If FncIsBlank(EDATE) Then EDATE = Date
	If FncIsBlank(LNUM) Then LNUM = 10

	DetailN = "&CD="& CD & "&SDATE="& SDATE & "&EDATE="& EDATE & "&SM="& SM & "&SW="& SW
	Detail = "&LNUM="& LNUM & DetailN

	TDATE = Date
	YDATE = Date - 1

	sYY		= Year(Date)
	sMM		= Right("0"&month(Date),"2")
	TMSDATE = DateSerial(sYY,sMM,1)		'당월 1일
	TMEDATE = Date 
	PMSDATE = DateSerial(sYY,sMM-1,1)		'전월 1일
	PMEDATE = CDate(TMSDATE) - 1			'전월 마지막일
%><!DOCTYPE html>
<html lang="ko">
<head>
<!-- #include virtual="/inc/head.asp" -->
<script>
function setDate(SD,ED){
	$('#SDATE').val(SD);
	$('#EDATE').val(ED);
	$('#searchfrm').submit();
}
</script>
</head>
<body>
    <div class="wrap">
<!-- #include virtual="/inc/header.asp" -->
<!-- #include virtual="/inc/header_nav.asp" -->
		<div class="board_top">
			<div class="route"> 
				<span><p>관리자</p> > <p>게시판관리</p> > <p><%=FncBrandName(CD)%></p></span>
			</div>
		</div>
	</div>
	<!--//GNB-->
</div>
<!--//NAV-->
        <div class="content">
            <div class="section section_board">
				<form id="searchfrm" name="searchfrm" method="get">
				<input type="hidden" name="CD" value="<%=CD%>">
				<input type="hidden" name="LNUM" value="<%=LNUM%>">
				<table>
					<tr>
						<th>
							<div class="list_select">
								<ul>
<%
	Sql = "Select MENU_CODE2, MENU_NAME, BBS From bt_code_menu Where menu_code='E' And menu_depth=2 And menu_code1='"& CD &"' "
	If SITE_ADM_LV <> "S" Then
		Sql = Sql & " And menu_code2 IN ('"& Replace(ADMIN_CHECKMENU2,",","','") &"') "
	End If
	Sql = Sql & " Order by menu_order "
	Set Mlist = conn.Execute(Sql)
	If Not Mlist.eof Then 
		Do While Not Mlist.Eof
			BBSCD = Mlist("MENU_CODE2")
			BBSNM = Mlist("MENU_NAME")
			BBS = Mlist("BBS")
			If FncIsBlank(BBSCODE) Then BBSCODE = BBSCD
%>
									<li><label><input type="radio" name="BBSCODE" value="<%=BBSCD%>"<%If BBSCODE = BBSCD Then%> checked<%End If%> onClick="document.location.href='<%=BBS%>?CD=<%=CD%>&BBSCODE=<%=BBSCD%>'"><span><%=BBSNM%></span></label></li>
<%
			Mlist.MoveNext
		Loop
	End If 
%>
								</ul>
							</div>
						</th>
					</tr>
					<tr>
						<th>
							<ul>
								<li>
									<label>가맹문의일</label>
									<input type="text" id="SDATE" name="SDATE" value="<%=SDATE%>" readonly style="width:100px"> ~
									<input type="text" id="EDATE" name="EDATE" value="<%=EDATE%>" readonly style="width:100px">
								</li>
								<li>
									<input type="button" value="금일" class="btn_white" onClick="setDate('<%=TDATE%>','<%=TDATE%>')">
									<input type="button" value="전일" class="btn_white" onClick="setDate('<%=YDATE%>','<%=YDATE%>')">
									<input type="button" value="전월" class="btn_white" onClick="setDate('<%=PMSDATE%>','<%=PMEDATE%>')">
									<input type="button" value="당월" class="btn_white" onClick="setDate('<%=TMSDATE%>','<%=TMEDATE%>')">
								</li>
								<li>
									<select name="SM" id="SM">
										<option value="N"<% If SM = "N" Then%> selected<%End If%>>대표자명</option>
									</select>
									<input type="text" name="SW" value="<%=SW%>">
									<input type="submit" value="조회" class="btn_white">
								</li>
							</ul>
						</th>
					</tr>
				</table>
				</form>
<%
	Detail = Detail &"&BBSCODE="& BBSCODE

	num_per_page	= LNUM	'페이지당 보여질 갯수
	page_per_block	= 10	'이동블럭

	page = InjRequest("page")
	If page = "" Then page = 1

	SqlFrom		= " From bt_board_joinq "
	SqlWhere	= " WHERE REG_DATE >= '"& SDATE &"' AND REG_DATE < '"& CDate(EDATE) + 1 &"' "
	If Not FncIsBlank(SW) Then 
		If SM = "N" Then
			SqlWhere = SqlWhere & " And BOWNER_NAME like '%" & SW & "%'"
		ElseIf SM = "P" Then
			SqlWhere = SqlWhere & " And BTEL like '%" & SW & "%'"
		End If 
	End If
	SqlOrder = " Order By BIDX Desc "

	Sql = "Select Count(*) " & SqlFrom & SqlWhere
	Set Trs = conn.Execute(Sql)
	total_num = Trs(0)
	Trs.close
	Set Trs = Nothing 

	If total_num = 0 Then
		first  = 1
	Else
		first  = num_per_page*(page-1)
	End If 

	total_page	= ceil(total_num / num_per_page)
	total_block	= ceil(total_page / page_per_block)
	block       = ceil(page / page_per_block)
	first_page  = (block-1) * page_per_block+1
	last_page   = block * page_per_block
%>
				<div class="list">
					<div class="list_top">
						<div class="list_total">
							<span>Total:<p><%=total_num%>건</p></span>
						</div>
						<div class="list_num">
                            <select name="LNUM" id="LNUM" onChange="document.location.href='?CD=<%=CD%>&BBSCODE=<%=BBSCODE%>&SM=<%=SM%>&SW=<%=SW%>&LNUM='+this.value">
                                <option value="10"<%If LNUM="10" Then%> selected<%End If%>>10</option>
                                <option value="20"<%If LNUM="20" Then%> selected<%End If%>>20</option>
                                <option value="50"<%If LNUM="50" Then%> selected<%End If%>>50</option>
                                <option value="100"<%If LNUM="100" Then%> selected<%End If%>>100</option>
                            </select>
						</div>
					</div>
					<div class="list_content">
						<table style="width:100%;">
								<tr>
									<th>NO</th>
									<th>대표자명</th>
									<th>연락처</th>
									<th>관심브랜드</th>
									<th>예상창업지역</th>
									<th>작성일</th>
									<th>상태</th>
									<th>관리</th>
								</tr>
<%
	If total_num > 0 Then 
		Sql = "SELECT Top "&num_per_page&" BIDX, BOWNER_NAME, BHP, BRAND_NAME, BSIDO, BGUGUN, ASTATUS, CONVERT(VARCHAR(19), REG_DATE, 121) AS REG_DATE " & SqlFrom & SqlWhere
		Sql = Sql & " And BIDX Not In "
		Sql = Sql & "(SELECT TOP " & ((page - 1) * num_per_page) & " BIDX "& SqlFrom & SqlWhere
		Sql = Sql & SqlOrder & ")"
		Sql = Sql & SqlOrder
		Set Rlist = conn.Execute(Sql)
		If Not Rlist.Eof Then 
			num	= total_num - first
			Do While Not Rlist.Eof
				BIDX	= Rlist("BIDX")
				BOWNER_NAME	= Rlist("BOWNER_NAME")
				BHP	= Rlist("BHP")
				BRAND_NAME	= Rlist("BRAND_NAME")
				BSIDO	= Rlist("BSIDO")
				BGUGUN	= Rlist("BGUGUN")
				ASTATUS	= Rlist("ASTATUS")
'				REG_DATE	= Left(Rlist("REG_DATE"),10)
				REG_DATE	= Rlist("REG_DATE")
				ASTATUS_TXT = FncJOINQBBS_STATUS(ASTATUS)
%>
								<tr>
									<td><span><%=num%></span></td>
									<td><span><%=BOWNER_NAME%></span></td>
									<td><span><%=BHP%></span></td>
									<td><span><%=BRAND_NAME%></span></td>
									<td><span><%=BSIDO%>&nbsp;<%=BGUGUN%></span></td>
									<td><span><%=REG_DATE%></span></td>
									<td><span><%=ASTATUS_TXT%></span></td>
									<td><input type="button" value="수정" class="btn_white" onClick="document.location.href='joinq_bbs_form.asp?BIDX=<%=BIDX%>&CD=<%=CD%>&BBSCODE=<%=BBSCODE%>'"></td>
								</tr>
<%
				num = num - 1
				Rlist.MoveNext
			Loop
		End If
		Rlist.Close
		Set Rlist = Nothing 
	End If 
%>
						</table>
					
					</div>
					<div class="list_foot">
<!-- #include virtual="/inc/paging.asp" -->
					</div>
				</div>
            </div>
        </div>
<!-- #include virtual="/inc/footer.asp" -->
    </div>
</body>
</html>