<!doctype html>
<html lang="ko">
<head>
<!--#include virtual="/includes/meta.asp"-->
<meta name="Keywords" content="브랜드, BBQ치킨">
<meta name="Description" content="브랜드">
<title>브랜드 | BBQ치킨</title>
<!--#include virtual="/includes/styles.asp"-->
<!--#include virtual="/includes/scripts.asp"-->
</head>

<body>
<div class="wrapper">
	<!-- Header -->
	<header class="header">
		<h1>브랜드</h1>
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

			<!-- Tab -->
			<div class="tab-wrap tab-type2">
				<ul class="tab">
					<li class="on"><a href="./bbq.asp"><span>브랜드스토리</span></a></li>
					<li><a href="./eventList.asp"><span>비비큐 소식</span></a></li>
				</ul>
			</div>
			<!--// Tab -->

			<!-- Tab -->
			<div class="tab-wrap tab-type3">
				<ul class="tab">
					<li><a href="./bbq.asp"><span>비비큐 이야기</span></a></li>
					<li><a href="./oliveList.asp"><span>올리브 이야기</span></a></li>
					<li class="on"><a href="./videoList.asp"><span>영상콘텐츠</span></a></li>
				</ul>
			</div>
			<!--// Tab -->

			<!-- 영상 리스트 -->
			<div class="video-list">
				<div class="inner">
					<div class="box">
						<a href="./videoView.asp" class="video" style="background-image:url(/images/brand/@video.jpg);">Video</a>
						<p class="subject"><a href="./videoView.asp">[BBQ] Let's Chicketing!</a></p>
					</div>
					<div class="box">
						<a href="./videoView.asp" class="video" style="background-image:url(/images/brand/@video.jpg);">Video</a>
						<p class="subject"><a href="./videoView.asp">[BBQ] Let's Chicketing!</a></p>
					</div>
					<div class="box">
						<a href="./videoView.asp" class="video" style="background-image:url(/images/brand/@video.jpg);">Video</a>
						<p class="subject"><a href="./videoView.asp">[BBQ] Let's Chicketing!</a></p>
					</div>
					<div class="box">
						<a href="./videoView.asp" class="video" style="background-image:url(/images/brand/@video.jpg);">Video</a>
						<p class="subject"><a href="./videoView.asp">[BBQ] Let's Chicketing!</a></p>
					</div>
				</div>
			</div>
			<!-- //영상 리스트 -->

			<div class="mar-t80">
				<div class="inner">
					<button type="button" class="btn btn-md btn-grayLine w-100p">더보기</button>
				</div>
			</div>


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