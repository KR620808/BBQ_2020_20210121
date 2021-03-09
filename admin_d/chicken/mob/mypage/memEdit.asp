<!doctype html>
<html lang="ko">
<head>
<!--#include virtual="/includes/meta.asp"-->
<meta name="Keywords" content="회원정보변경, BBQ치킨">
<meta name="Description" content="회원정보변경">
<title>회원정보변경 | BBQ치킨</title>
<!--#include virtual="/includes/styles.asp"-->
<!--#include virtual="/includes/scripts.asp"-->
<script>
jQuery(document).ready(function(e) {
	// inquiryList
	$(document).on('click', '.btn_phoneChange', function(e) {
		if($('.phone-cert').is(':hidden')){
			$('.phone-cert').show();
			$(this).find('span').text('취소');
		}else{
			$('.phone-cert').hide();
			$(this).find('span').text('변경');
		}
	});
});
</script>
</head>

<body>
<div class="wrapper">
	<!-- Header -->
	<header class="header">
		<h1>회원정보변경</h1>
		<div class="btn-header btn-header-nav">
			<button type="button" onClick="javascript:history.back();" class="btn btn_header_back"><span class="ico-only">이전페이지</span></button>
			<button type="button" class="btn btn_header_menu"><span class="ico-only">메뉴</span></button>
		</div>
		<div class="btn-header btn-header-mnu">
			<button type="button" class="btn btn_header_cart"><span class="ico-only">장바구니</span></button>
			<button type="button" class="btn btn_header_brand"><span class="ico-only">패밀리브랜드</span></button>
		</div>
	</header>
	<!--// Header -->
	<hr>

	<!-- Container -->
	<div class="container">
		<!-- Aside -->
		<!--#include virtual="/includes/aside.asp"-->
		<!--// Aside -->
		<hr>
			
		<!-- Content -->
		<article class="content">

			<form name="memForm" id="memForm" method="post" onSubmit="return false;">
			<!-- 기본정보 -->
			<section class="section mar-b125 mar-t50">
				<div class="section-header">						
					<h3>기본정보</h3>
				</div>
				<div class="section-body">
					<div class="box-gray">
						<dl class="regForm">
							<dt>이름</dt>
							<dd>박하나</dd>
						</dl>
						<dl class="regForm">
							<dt>생년월일</dt>
							<dd>1980.10.10(양력)</dd>
						</dl>
						<dl class="regForm">
							<dt>아이디</dt>
							<dd>hana12345678963</dd>
						</dl>
					</div>
					<div class="inner">
						<dl class="regForm">
							<dt><label for="sPwd1">비밀번호</label></dt>
							<dd>
								<input type="password" name="sPwd1" id="sPwd1" maxlength="20" placeholder="영문, 숫자, 특수문자를 조합하여 10자 이상" class="w-100p">
								<input type="password" name="sPwd2" id="sPwd2" maxlength="20" placeholder="비밀번호 재입력" class="w-100p bor-tnone">
							</dd>
						</dl>
						<dl class="regForm">
							<dt>휴대폰번호</dt>
							<dd>
								<span class="va-m mar-r20">010-1234-5678</span><button type="button" onclick="" class="btn btn-sm btn-brownLine w-170 btn_phoneChange"><span>변경</span></button>
								<ul class="phone-cert mar-t30">
									<li>
										<span class="ui-group-tel">
											<span>
												<select>
													<option value="" selected>010</option>
												</select>
											</span>
											<span class="dash">-</span>
											<span><input type="tel"></span>
											<span class="dash">-</span>
											<span><input type="tel"></span>
										</span>
										<a href="#" onclick="javascript:return false;" class="btn btn-md btn-red">인증번호</a>
									</li>
									<li>
										<input type="text" placeholder="인증번호 입력" class="w-100p">
										<button type="button" class="btn btn-md btn-black">확인</button>
									</li>
								</ul>
							</dd>
						</dl>
						<dl class="regForm">
							<dt><label for="sEmail1">이메일 주소</label></dt>
							<dd>
								<span class="ui-group-email">
									<span><input type="text" name="sEmail1" id="sEmail1" maxlength="20"></span>
									<span class="dash">@</span>
									<span><input type="text" name="sEmail2" id="sEmail2" maxlength="20"></span>
									<span>
										<select name="sEmailSel" id="sEmailSel" onChange="javascript:setEmail(this,'#sEmail2');">
											<option value="" selected>직접입력</option>
											<option value="naver.com">네이버</option>
											<option value="daum.net">다음</option>
											<option value="nate.com">네이트</option>
										</select>
									</span>
								</span>
							</dd>
						</dl>
					</div>
				</div>
			</section>
			<!--// 기본정보 -->
			
			<!-- 정보수신동의 -->
			<section class="section mar-b125">
				<div class="section-header">
					<h3>정보수신동의</h3>
				</div>
				<div class="section-body">
					<div class="box-gray">
						<div class="ui-group-checkbox three-up">
							<label class="ui-checkbox">
								<input type="checkbox" name="sAgree" id="sAgree1" value="A">
								<span></span> 전체동의
							</label>
							<label class="ui-checkbox">
								<input type="checkbox" name="sAgree" id="sAgree2" value="E">
								<span></span> 이메일 수신동의
							</label>
							<label class="ui-checkbox">
								<input type="checkbox" name="sAgree" id="sAgree3" value="M">
								<span></span> SMS 수신동의
							</label>									
						</div>
					</div>
					<div class="inner">
						<ul class="ul-guide mar-t30">
							<li>수신동의를 하시면 상품정보, 할인혜택, 이벤트 등 다양한 혜택 및 소식 안내를 받을 수 있습니다.</li>
							<li>회원가입, 주문배달 관련 등의 정보는 수신동의 여부와 상관없이 자동으로 발송됩니다.</li>
						</ul>
					</div>
				</div>
			</section>
			<!--// 정보수신동의 -->
			
			<!-- 주소지 관리 -->
			<section class="section">
				<div class="section-header section-header-line">
					<h3>주소지 관리</h3>
				</div>
				<div class="section section_shippingAdd">
					<button type="button" onClick="javascript:lpOpen('.lp_addShipping');"  class="btn btn-lg btn-black w-100p btn_lp_open">배달지 추가</button>
					<div class="txt">- 자주 사용하는 배송지를 등록 및 관리하실 수 있습니다.</div>
				</div>
			</section>
			<!--// 주소지 관리 -->

			<!-- 배달지 리스트 -->
			<section class="section section_shipList">
				<div class="box">
					<div class="name">
						<span class="red">[기본주소지]</span> 박하나
					</div>
					<ul class="info">
						<li>010-1111-1111</li>
						<li>(01234) 서울특별시 관악구 난리로 66 무슨빌딩 1층</li>
					</ul>
					<ul class="btn-wrap">
						<li class="btn-left">
						</li>
						<li class="btn-right">
							<button type="button" onClick="javascript:lpOpen('.lp_addShipping');" class="btn btn-sm btn-grayLine btn_lp_open">수정</button>
						</li>
					</ul>
				</div>
				<div class="box">
					<div class="name">
						<span class="red">[기본주소지]</span> 박하나
					</div>
					<ul class="info">
						<li>010-1111-1111</li>
						<li>(01234) 서울특별시 관악구 난리로 66 무슨빌딩 1층</li>
					</ul>
					<ul class="btn-wrap">
						<li class="btn-left">
							<button type="button" class="btn btn-sm btn-brown">기본주소지 설정</button>
						</li>
						<li class="btn-right">
							<button type="button" onClick="javascript:lpOpen('.lp_addShipping');" class="btn btn-sm btn-grayLine btn_lp_open">수정</button>
							<button type="button" class="btn btn-sm btn-grayLine">삭제</button>
						</li>
					</ul>
				</div>
				<div class="box">
					<div class="name">
						<span class="red">[기본주소지]</span> 박하나
					</div>
					<ul class="info">
						<li>010-1111-1111</li>
						<li>(01234) 서울특별시 관악구 난리로 66 무슨빌딩 1층</li>
					</ul>
					<ul class="btn-wrap">
						<li class="btn-left">
							<button type="button" class="btn btn-sm btn-brown">기본주소지 설정</button>
						</li>
						<li class="btn-right">
							<button type="button" onClick="javascript:lpOpen('.lp_addShipping');" class="btn btn-sm btn-grayLine btn_lp_open">수정</button>
							<button type="button" class="btn btn-sm btn-grayLine">삭제</button>
						</li>
					</ul>
				</div>
			</section>
			<!-- //배달지 리스트 -->

			<div class="mar-t100 inner">
					<button type="button" onClick="javascript:lpOpen('.lp_memSecssion');" class="btn btn_lp_open btn_memSecssion"><span class="ico-arrowRight">회원탈퇴 <small>제너시스BBQ그룹 통합 멤버십 회원탈퇴</small></span></button>
			</div>

			<div class="btn-wrap two-up inner mar-t80">
				<button type="submit" class="btn btn-lg btn-black"><span>확인</span></button>
				<button type="submit" class="btn btn-lg btn-grayLine"><span>취소</span></button>
			</div>

			</form>

			<!-- Layer Popup : Member Secssion -->
			<div id="LP_MemSecssion" class="lp-wrapper lp_memSecssion">
				<!-- LP Header -->
				<div class="lp-header">
					<h2>회원탈퇴</h2>
				</div>
				<!--// LP Header -->
				<!-- LP Container -->
				<div class="lp-container">
					<!-- LP Content -->
					<div class="lp-content">
						<section class="section inner mar-b70">
							<div class="headLine">
								<div class="headLine-img">
									<img src="/images/mypage/logo_genesisBBQ.png" alt="Genesis BBQ">
								</div>
								<p class="headLine-txt">
									제네시스BBQ그룹 통합 멤버십을<br>
									이용해 주셔서 감사합니다.
								</p>
							</div>
							<ul class="ul-guide ul-guide-type2">
								<li>웹사이트 약관 동의 및 개인정보 제공, 활용 동의가 철회됩니다.</li>
								<li>- 탈퇴후 재가입 시 사용하셨던 아이디는 다시 사용하실 수 있습니다.</li>
								<li class="red">- 재가입은 회원탈퇴 후 30일이 지난 후에만 가능합니다.</li>
							</ul>
						</section>
						<section class="section">
							<div class="section-header">
								<h3>탈퇴사유</h3>
							</div>
							<div class="section-body">
								<form name="secssionFrm" id="secssionFrm" method="post" onSubmit="javascript:return false;">								
								<div class="box-gray">
									<ul class="ui-group-list two-up">
										<li>
											<label class="ui-radio">
												<input type="radio" name="sSecssionType" id="sSecssionType1" value="1">
												<span></span> 배달불만
											</label>
										</li>
										<li>	
											<label class="ui-radio">
												<input type="radio" name="sSecssionType" id="sSecssionType2" value="2">
												<span></span> 자주 이용하지 않음
											</label>
										</li>
										<li>	
											<label class="ui-radio">
												<input type="radio" name="sSecssionType" id="sSecssionType3" value="3">
												<span></span> 상품의 다양성/가격불만
											</label>
										</li>
										<li>	
											<label class="ui-radio">
												<input type="radio" name="sSecssionType" id="sSecssionType4" value="4">
												<span></span> 개인정보 유출우려
											</label>
										</li>
										<li>	
											<label class="ui-radio">
												<input type="radio" name="sSecssionType" id="sSecssionType5" value="5">
												<span></span> 질적인 혜택부족
											</label>
										</li>
										<li>	
											<label class="ui-radio">
												<input type="radio" name="sSecssionType" id="sSecssionType6" value="6">
												<span></span> 기타
											</label>
										</li>																																								
									</ul>
									<textarea name="sSecssionMsg" id="sSecssionMsg" rows="5" placeholder="기타 의견을 남겨주세요." class="w-100p"></textarea>
								</div>
								<div class="btn-wrap two-up inner mar-t70">
									<button type="submit" class="btn btn-lg btn-black btn_confirm"><span>확인</span></button>
									<button type="button" onClick="javascript:lpClose(this);" class="btn btn-lg btn-grayLine btn_cancel"><span>취소</span></button>
								</div>
								</form>
							</div>
						</section>
					</div>
					<!--// LP Content -->
				</div>
				<!--// LP Container -->
				<button type="button" class="btn btn_lp_close"><span>레이어팝업 닫기</span></button>
			</div>
			<!--// Layer Popup -->
			
			
			


			<!-- Layer Popup : 배달지 입력 -->
			<div id="LP_addShipping" class="lp-wrapper lp_addShipping">
				<!-- LP Header -->
				<div class="lp-header">
					<h2>배달지 입력</h2>
				</div>
				<!--// LP Header -->
				<!-- LP Container -->
				<div class="lp-container">
					<!-- LP Content -->
					<div class="lp-content">
						<form action="">
							<div class="inner">
								<dl class="regForm">
									<dt>이름</dt>
									<dd>
										<input type="text" class="w-100p">
									</dd>
								</dl>
								<dl class="regForm">
									<dt>전화번호</dt>
									<dd>
										<span class="ui-group-tel">
											<span><input type="tel"maxlength="20"></span>
											<span class="dash">-</span>
											<span><input type="tel" maxlength="20"></span>
											<span class="dash">-</span>
											<span><input type="tel" maxlength="20"></span>
										</span>
									</dd>
								</dl>
								<dl class="regForm">
									<dt><label for="sPost">주소</label></dt>
									<dd>
										<div class="ui-input-post">
											<input type="text" name="sPost" id="sPost" maxlength="7" readonly>
											<button type="button" class="btn btn-md btn-gray btn_post"><span>우편번호 검색</span></button>
										</div>
										<div class="mar-t10"><input type="text" name="sAddr1" id="sAddr1" maxlength="100" class="w-100p"></div>
										<div class="mar-t10"><input type="text" name="sAddr2" id="sAddr2" maxlength="100" class="w-100p"></div>
									</dd>
								</dl>
							</div>
							<div class="btn-wrap two-up inner mar-t80">
								<button type="submit" class="btn btn-lg btn-black"><span>확인</span></button>
								<button type="submit" class="btn btn-lg btn-grayLine"><span>취소</span></button>
							</div>
						</form>
					</div>
					<!--// LP Content -->
				</div>
				<!--// LP Container -->
				<button type="button" class="btn btn_lp_close"><span>레이어팝업 닫기</span></button>
			</div>
			<!--// Layer Popup -->





		</article>
		<!--// Content -->

		<!-- Back to Top -->
		<a href="#Top" class="btn btn_scrollTop">페이지 상단으로 이동</a>
		<!--// Back to Top -->
	</div>
	<!--// Container -->
	<hr>

	<!-- Footer -->
	<!--#include virtual="/includes/footer.asp"-->
	<!--// Footer -->
</div>
</body>
</html>
