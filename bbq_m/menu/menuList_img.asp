<!--#include virtual="/api/include/utf8.asp"-->
<% Call DBOpen %>
<!doctype html>
<html lang="ko">
<head>
<!--#include virtual="/includes/top.asp"-->
<meta name="Keywords" content="메뉴소개, BBQ치킨">
<meta name="Description" content="메뉴소개">
<title>메뉴소개 | BBQ치킨</title>

<%
	Dim anc : anc = Request("anc")
%>
<script type="text/javascript">
	var cartPage = "";
	function addMenuNGo(data, go) {
		addCartMenu(data);

		if(go) {
			location.href = "/order/cart.asp";
		} else {
//			showAlertMsg({msg:"장바구니에 담았습니다"});

			lpOpen2("#lp_cart");
			// if(window.confirm("선택한 메뉴가 장바구니에 담겼습니다.\n장바구니로 이동하시겠습니까?")) {
			// 	location.href = "/order/cart.asp";
			// }
		}
	}

	var menu_name_arr = new Array();
	var menu_cate_arr = new Array();
	var menu_idx_arr = new Array();
	var save_anc = "<%=anc%>";


	function list_search()
	{
		var obj = document.getElementById("list_src");
		var val = obj.value;
		var cnt = 0;

		$('.menuBox').hide(0); // 모든 카테고리 close

		for (i=0; i<menu_name_arr.length; i++)
		{
			if (menu_name_arr[i].replace(/ /gi, "").indexOf(val.replace(/ /gi, "")) > -1) {
				$('.menu_list_idx_'+ menu_cate_arr[i] +'_'+ menu_idx_arr[i]).show(0); // 검색된 카테고리 open
				cnt++;
			}
		}

		if (menu_name_arr.length > cnt) { // 검색됨
			str = "";
			str += '<span style="display:block; text-align:center; padding:0px 0 15px 0;">"<strong>'+ cnt +'</strong>건이 검색되었습니다"</span>';
			str += '<a href="javascript:void(0)" onclick="menu_list_reset(2) " class="btn btn-black btn_middle" >전체보기</a>';

			$('#list_src_result').html(str).show(0);
			$('#re_text').show(0)
		} else { // input 빈값.
			$('#list_src_result').html('').hide(0);
			$('#re_text').hide(0);
			menu_go(save_anc); // 원래 보던 리스트 보여주기
		}
	}

	function menu_go(anc)
	{
		$('.menuBox').hide(0);
		save_anc = anc; // 선택된 카테고리 저장.

		// 검색관련된것 초기화
		$('#list_src').val('');
		$('#list_src_result').html('').hide(0);
		$('#re_text').hide(0);

		if (anc == "") {
			// 103은 인기메뉴.
			$('.menuBox').not('.menu_cate_103').show(0);
		} else {
			$('.menu_cate_'+ anc).show(0);
		}
	}

	function menu_list_reset(gubun)
	{
		$('#list_src').val(''); 
		list_search(); 

		if (gubun == "1") {
			$('#list_src').focus();
		}

		$('#re_text').hide(0)
	}

	function menu_list_cate_control(num)
	{
		$menu_list_cate_obj = $('#menu_list_cate_'+ num);

		if ($menu_list_cate_obj.parent().hasClass("open") === true) {
			$menu_list_cate_obj.parent().removeClass("open").find('.content').slideToggle(200);
		} else {
			$menu_list_cate_obj.parent().addClass("open").find('.content').slideUp(200);
		}
	}

	function menu_img_down(url, nm)
	{
		var x=new XMLHttpRequest();
		x.open("GET", url, true);
		x.responseType = 'blob';
		x.onload=function(e){download(x.response, nm, "application/octet-stream" ); }
		x.send();
	}
</script>

</head>

<body>


<style type="text/css">
.topFixBanner {position:relative; background:#ffffff; text-align:center; padding:0 0 10px 0; width:100%}
.topFixBanner .menu_list_search {position:relative; margin-top:15px;}
.topFixBanner .menu_list_search > input {width:100%; border:1px solid #bebebe}
.topFixBannerFixed {position:fixed; top:59px; z-index:9999;}
.topFixBanner .menu_list_search span.re_text {position:absolute; font-size:1em; color:#777; font-weight:bold; right:15px; top:10px; display:none}
.topFixBanner .menu_list_search span.re_search {padding-top:10px; display:block}

.menu_accordion_fix {padding-top:60px;}
.menu_accordion_fix_src {padding-top:160px;}

@media (max-width:750px){
.topFixBannerFixed {top:45px;}
}
</style>


<div class="wrapper">

	<%
		PageTitle = "메뉴"
	%>

	<!--#include virtual="/includes/header.asp"-->
	
	<!-- Container -->
	<div class="container">
		<!-- Aside -->
		<!--#include virtual="/includes/aside.asp"-->
		<!--// Aside -->

		<%
			Dim cate_idx_str : cate_idx_str = "103" ' 초기설정
			Dim cate_name_str : cate_name_str = "모든 비비큐치킨" ' 초기설정
			Dim cate_idx_arr
			Dim cate_name_arr

			Set aCmd = Server.CreateObject("ADODB.Command")

			With aCmd
				.ActiveConnection = dbconn
				.CommandType = adCmdStoredProc
				.CommandText = "bp_main_category_select"

				Set aRs = .Execute
			End With

			Set aCmd = Nothing

			If Not (aRs.BOF Or aRs.EOF) Then
				aRs.MoveFirst

				Do Until aRs.EOF
					If cate_idx_str <> "" Then split_str = "S||S"

					cate_idx_str = cate_idx_str & split_str & aRs("category_idx")
					cate_name_str = cate_name_str & split_str & aRs("category_name")

					aRs.MoveNext
				Loop
			End If

			Set aRs = Nothing

			cate_idx_str = cate_idx_str & split_str & "99999"
			cate_name_str = cate_name_str & split_str & "사이드메뉴"

			cate_idx_arr = Split(cate_idx_str, "S||S")
			cate_name_arr = Split(cate_name_str, "S||S")
		%>
			
		<!-- Content -->
		<article class="content">

			<div class="topFixBanner">

				<!-- 상단 메뉴네비 -->
				<script type="text/javascript" src="/common/js/swiper/jquery-1.12.4.min.js"></script>
				<script type="text/javascript" src="/common/js/swiper/jquery-ui.min.js"></script>
				<script type="text/javascript" src="/common/js/swiper/plugins.js"></script>
				<script type="text/javascript" src="/common/js/download.js"></script>

				 <div class="menu_nav_wrap">
					<nav class="menu_nav2">
						<div class="swiper-wrapper">
							<span class="<% if anc = "" then %>				on <% end if %> swiper-slide2"><button type="button" id="" onclick="menu_go(''); ">전체</button></span>

							<% For i=0 To UBound(cate_idx_arr) %>
								<span class="<% if anc = cate_idx_arr(i) then %>		on <% end if %> swiper-slide2"><button type="button" id="" onclick="menu_go('<%=cate_idx_arr(i)%>'); "><%=cate_name_arr(i)%></button></span>
							<% Next %>
						</div>
					</nav>
				</div>

				<script type="text/javascript">
				//페이지 로드시 실행
				$(document).ready(function() {
					$('body').addClass('bg_wht');
				
					$('.pageName').text("전체메뉴");
					
					//메뉴 상단 네비게이션
					$(window).load(function(){
						setTimeout(function(){ 
							swiper = $('.menu_nav2').swiper({
								slidesPerView: 'auto',
								<% if anc = "" then %>			initialSlide: '0', <% end if %>

								<% For i=0 To UBound(cate_idx_arr) %>
									<% if anc = cate_idx_arr(i) then %>		initialSlide: '<%=i%>', <% end if %>
								<% Next %>
								//freeMode:true
							});	
						}, 300);
					});
					//메뉴 카테고리 클릭
					$('.swiper-wrapper span button').click(function(){
						var $this = $(this);
						$('.swiper-wrapper span').removeClass('on');
						$this.parents('span').addClass('on');
					});
					
					$('.btn_favorite').click(function(e){
						e.preventDefault();
						var $this = $(this);
						$this.toggleClass('favorite_add');
					});
					
					var cateid = '9999';
					var cateid2 = '';
					var slide_str = "";
					
				});
				</script>
				<!-- // 상단 메뉴네비 -->


				<div class="inbox1000 menu_list_search ">
					<input type="text" name="list_src" id="list_src"  onkeyup="list_search()" placeholder="검색어를 입력해 주십시오">
					<span id="re_text" class="re_text" onclick="menu_list_reset(1)">X</span>
					<span id="list_src_result" class="re_search"><span>
				</div>
				
			</div>


			<!-- 메뉴 리스트 -->
			<div class="menu_accordion inbox1000" >

				
				<!-- menu-list -->
				<div class="menu-list">
				<%
					dim m_i : m_i = 0

					category_idx = GetReqStr("cidx",0)

					menu_idx_arr = cate_idx_arr
					menu_str_arr = cate_name_arr



					for m=0 to ubound(menu_idx_arr)

						category_idx = menu_idx_arr(m)

						if category_idx = "103" then 

							Set aCmd = Server.CreateObject("ADODB.Command")

							With aCmd
								.ActiveConnection = dbconn
								.NamedParameters = True
								.CommandType = adCmdStoredProc
								.CommandText = "UP_MENU_LIST_GUBUN"

								.Parameters.Append .CreateParameter("@GUBUN", adInteger, adParamInput, , category_idx)

								Set aRs = .Execute
							End With

							Set aCmd = Nothing

						elseif category_idx = "99999" then 

							Set aCmd = Server.CreateObject("ADODB.Command")

							With aCmd
								.ActiveConnection = dbconn
								.NamedParameters = True
								.CommandType = adCmdStoredProc
								.CommandText = "bp_sidemenu_select"

								Set aRs = .Execute
							End With

							Set aCmd = Nothing

						else

							Set aCmd = Server.CreateObject("ADODB.Command")

							With aCmd
								.ActiveConnection = dbconn
								.NamedParameters = True
								.CommandType = adCmdStoredProc
								.CommandText = "bp_category_menu_list"

								.Parameters.Append .CreateParameter("@category_idx", adInteger, adParamInput, , category_idx)

								Set aRs = .Execute
							End With

							Set aCmd = Nothing

						end if 

						' 전체메뉴일경우
						if anc = "" then 
							if category_idx = "103" then 
								anc_display = "N" ' 인기메뉴는 제외.
							else
								 anc_display = "Y" ' 그외는 다보이게
							end if 
						else
							if category_idx = anc then 
								anc_display = "Y" ' 선택된 카테고리만 보이게
							else 
								anc_display = "N" ' 그외는 다보이게
							end if 
						end if 

						If Not (aRs.BOF Or aRs.EOF) Then
							aRs.MoveFirst

							Do Until aRs.EOF
								if aRs("menu_type") = "B" then ' B : 일반메뉴(M으로 변경해야됨) / S : 사이드메뉴
									vMenuType_plus = "M"
								else
									vMenuType_plus = aRs("menu_type")
								end if 
					%>

								<div id="list_div_<%=m_i%>" class="menuBox menu_cate_<%=category_idx%> menu_list_idx_<%=category_idx%>_<%=aRs("menu_idx")%>" <% if anc_display <> "Y" then %>style="display:none"<% end if %>>
									<ul class="menuWrap" onclick="menu_img_down('<%=SERVER_IMGPATH%><%=aRs("thumb_file_path")&aRs("thumb_file_name")%>', '<%=aRs("thumb_file_name")%>');">
										<li class="menuImg"><img src="<%=SERVER_IMGPATH%><%=aRs("thumb_file_path")&aRs("thumb_file_name")%>"></li>
										<li class="menuText">
											<h4><%=aRs("menu_name")%></h4>
										</li>
									</ul>

									<div class="menuList_btn clearfix">
										<button type="button" class="btn btn_list_cart btn_newImg" onClick="addMenuNGo('<%=vMenuType_plus%>$$<%=aRs("menu_idx")%>$$<%=aRs("menu_option_idx")%>$$<%=aRs("menu_price")%>$$<%=aRs("menu_name")%>$$<%=SERVER_IMGPATH%><%=aRs("thumb_file_path")&aRs("thumb_file_name")%>$$$$<%=aRs("kind_sel")%>', false);"><img src="/images/common/btn_add.png" alt="담아두기"> </button>
										<a href="javascript: addMenuNGo('<%=vMenuType_plus%>$$<%=aRs("menu_idx")%>$$<%=aRs("menu_option_idx")%>$$<%=aRs("menu_price")%>$$<%=aRs("menu_name")%>$$<%=SERVER_IMGPATH%><%=aRs("thumb_file_path")&aRs("thumb_file_name")%>$$$$<%=aRs("kind_sel")%>', true);" class="btn btn_list_order btn_newImg"><img src="/images/common/btn_order.png" alt="주문하기"></a>
									</div>
								</div>

					<%
								' 인기 메뉴는 검색에서 제외
								' 중복으로 검사됨
								if category_idx <> "103" then 
									response.write "<script type='text/javascript'>"
									response.write "	menu_name_arr.push('"& aRs("menu_name") &"');"
									response.write "	menu_cate_arr.push('"& category_idx &"');"
									response.write "	menu_idx_arr.push('"& aRs("menu_idx") &"');"
									response.write "</script>"
								end if 

								m_i = m_i + 1

								aRs.MoveNext
							Loop
						End If

						Set aRs = Nothing

					next 
				%>
				</div>
				<!-- menu-list -->

			</div>
			<!-- //메뉴 리스트 -->


		</article>
		<!--// Content -->

	</div>
	<!--// Container -->

	<!-- Footer -->
	<!--#include virtual="/includes/footer.asp"-->
	<!--// Footer -->


<!-- 아코디언 -->

<script>
function menu_list_cate_all_open()
{
	tot_cnt = "<%=m%>";

	for (i=0; i<=tot_cnt; i++)
	{
		$menu_list_cate_obj = $('#menu_list_cate_'+ i);
		$menu_list_cate_obj.parent().removeClass("open").find('.content').slideDown(0);
	}
}

</script>

<script type="text/javascript">
    function fnMove(seq, num){
        var offset = $("#anc_" + seq).offset();

		if ($('#list_src_result').css('display') == "none") {
			if (!$( '.menu_accordion' ).is( '.menu_accordion_fix')) {
				top_str = 134;
			} else {
				top_str = 124;
			}
		} else {
			if (!$( '.menu_accordion' ).is( '.menu_accordion_fix_src')) {
				top_str = 234;
			} else {
				top_str = 224;
			}
		}
		console.log(top_str)
        $('html, body').animate({scrollTop : offset.top-top_str}, 300);
    }

	<% if anc <> "" then %>
		$(function(){
//			fnMove(<%=anc%>)
		});
	<% end if %>
</script>

<script type="text/javascript">
</script>
<!-- // 아코디언 -->



<!-- 메뉴검색 -->
<script type="text/javascript">
//	var bannerOffset = $( '.topFixBanner' ).offset();

    $( window ).scroll( function() {  //window에 스크롤링이 발생하면
		var menu_accordion_fix_string = "";

		if ($('#list_src_result').css('display') == "none") {
			$( '.menu_accordion' ).removeClass( 'menu_accordion_fix_src');
			menu_accordion_fix_string = "menu_accordion_fix";
		} else {
			$( '.menu_accordion' ).removeClass( 'menu_accordion_fix');
			menu_accordion_fix_string = "menu_accordion_fix_src";
		}

		if ( $( document ).scrollTop() > 0 ) {   // 위치 및 사이즈를 파악하여 미리 정한 css class를 add 또는 remove 합니다.
			$( '.topFixBanner' ).addClass( 'topFixBannerFixed');
			$( '.menu_accordion' ).addClass( menu_accordion_fix_string);
		} else {
			$( '.topFixBanner' ).removeClass( 'topFixBannerFixed');
			$( '.menu_accordion' ).removeClass( menu_accordion_fix_string);
		}
	});
</script>
<!-- // 메뉴검색 -->