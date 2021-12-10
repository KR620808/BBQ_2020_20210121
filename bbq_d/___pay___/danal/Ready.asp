<%
	Response.AddHeader "pragma","no-cache"
	
	'/********************************************************************************
	' *
	' * �ٳ� �޴��� ����
	' *
	' * - ���� ��û ������
	' *      CP���� �� ���� ���� ����
	' *
	' * ���� �ý��� ������ ���� ���ǻ����� �����ø� ���񽺰��������� ���� �ֽʽÿ�.
	' * DANAL Commerce Division Technique supporting Team
	' * EMail : tech@danal.co.kr
	' *
	' ********************************************************************************/
    order_idx = GetReqNum("order_idx", "")
    
    response.Cookies("ORDER_IDX") = order_idx
%>
<!--#include virtual="/api/include/cv.asp"-->
<!--#include virtual="/api/include/db_open.asp"-->
<!--#include virtual="/api/include/func.asp"-->
<!--#include file="inc/function.asp"-->
<html>
<head>
<title>�ٳ� �޴��� ����</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr" />
</head>
<%
	Dim TransR
	Dim CPName, ItemAmt, ItemName, ItemCode
	
	'/********************************************************************************
	' *
	' * [ ���� ��û ������ ] *********************************************************
	' *
	' ********************************************************************************/

	'/***[ �ʼ� ������ ]************************************/
	Set ByPassValue = CreateObject("Scripting.Dictionary")
	Set TransR = CreateObject("Scripting.Dictionary")

	'/******************************************************
	' ** �Ʒ��� �����ʹ� �������Դϴ�.( �������� ������ )
	' * Command		: ITEMSEND2
	' * SERVICE		: TELEDIT
	' * ItemCount		: 1
	' * OUTPUTOPTION	: DEFAULT	
	' ******************************************************/
	TransR.Add "Command", "ITEMSEND2"
	TransR.Add "SERVICE", "TELEDIT"
	TransR.Add "ItemCount", "1"
	TransR.Add "OUTPUTOPTION", "DEFAULT"
	
	'/******************************************************
	' * ID			: �ٳ����� ������ �帰 ID( function ���� ���� )
	' * PWD			: �ٳ����� ������ �帰 PWD( function ���� ���� )
	' * CPNAME		: CP ��
	' ******************************************************/
	TransR.Add "ID", ID
	TransR.Add "PWD", PWD
	CPName = "���ť"
	
	'/******************************************************
	' * ItemAmt		: ���� �ݾ�( function ���� ���� )
	' *      - ���� ��ǰ�ݾ� ó���ÿ��� Session �Ǵ� DB�� �̿��Ͽ� ó���� �ֽʽÿ�.
	' *      - �ݾ� ó�� �� �ݾ׺����� ������ �ֽ��ϴ�.
	' * ItemName		: ��ǰ��
	' * ItemCode		: �ٳ����� ������ �帰 ItemCode
	' ******************************************************/
    AMOUNT = 0
    BRAND_ID = ""
    BRANCH_ID = ""
    DANAL_H_SCPID = ""

	Set pCmd = Server.CreateObject("ADODB.Command")
    With pCmd
        .ActiveConnection = dbconn
        .NamedParameters = True
        .CommandType = adCmdStoredProc
        .CommandText = "bp_order_for_pay"

        .Parameters.Append .CreateParameter("@order_idx", adInteger, adParamInput, , order_idx)

        Set pRs = .Execute
    End With
    Set pCmd = Nothing

    If Not (pRs.BOF Or pRs.EOF) Then
        USER_ID = pRs("member_idno")
        ORDER_NUM = pRs("order_num")
        DANAL_H_SCPID = pRs("danal_h_scpid")
        AMOUNT = pRs("order_amt")+pRs("delivery_fee")
    Else
        USER_ID = ""
        ORDER_NUM = ""
        DANAL_H_SCPID = ""
        AMOUNT = ""
    End If



	ItemAmt = AMOUNT
	ItemName = "���ťġŲ����"
	ItemCode = "22S0dj0005"
	ItemInfo = MakeItemInfo( ItemAmt,ItemCode,ItemName )
	
	TransR.Add "ItemInfo", ItemInfo
	
	'/***[ ���� ���� ]**************************************/
	'/******************************************************
	' * SUBCP		: �ٳ����� �����ص帰 SUBCP ID
	' * USERID		: ����� ID
	' * ORDERID		: CP �ֹ���ȣ
	' * IsPreOtbill		: AuthKey ���� ����(Y/N) (�����, ���ڵ������� ���� AuthKey ������ �ʿ��� ��� : Y)
	' * IsSubscript		: �� ���� ���� ����(Y/N) (�� ���� ������ ���� ù ������ ��� : Y)
	' ******************************************************/
	TransR.Add "SUBCP", DANAL_H_SCPID
	TransR.Add "USERID", USER_ID
	TransR.Add "ORDERID", ORDER_NUM
	TransR.Add "IsPreOtbill", "N"
	TransR.Add "IsSubscript", "N"
	
	'/********************************************************************************
	' *
	' * [ CPCGI�� HTTP POST�� ���޵Ǵ� ������ ] **************************************
	' *
	' ********************************************************************************/

	'/***[ �ʼ� ������ ]************************************/
	Dim ByPassValue
	
	'/******************************************************
	' * BgColor		: ���� ������ Background Color ����
	' * TargetURL		: ���� ���� ��û �� CP�� CPCGI FULL URL
	' * BackURL		: ���� �߻� �� ��� �� �̵� �� �������� FULL URL
	' * IsUseCI		: CP�� CI ��� ����( Y or N )
	' * CIURL		: CP�� CI FULL URL
	' ******************************************************/
	ByPassValue.Add "BgColor", "00"
	ByPassValue.Add "TargetURL", GetCurrentHost& "/pay/danal/CPCGI.asp"
	ByPassValue.Add "BackURL", GetCurrentHost& "/pay/danal/BackURL.asp"
	ByPassValue.Add "IsUseCI", "N"
	ByPassValue.Add "CIURL", GetCurrentHost& "/images/common/logo_header_bbq.png"
	
	'/***[ ���� ���� ]**************************************/

	'/******************************************************
	' * Email		: ����� E-mail �ּ� - ���� ȭ�鿡 ǥ�� 
	' * IsCharSet	: CP�� Webserver Character set
	' ******************************************************/
	ByPassValue.Add "Email", ""
	ByPassValue.Add "IsCharSet", "UTF-8"

	'/******************************************************
	' ** CPCGI�� POST DATA�� ���� �˴ϴ�.
	' **
	' ******************************************************/
	ByPassValue.Add "ByBuffer", "This value bypass to CPCGI Page"
	ByPassValue.Add "ByAnyName", "AnyValue"
	
	Set Res = CallTeledit( TransR,false )
	
	IF Res.Item("Result") = "0" Then
%>
<body>
<form name="Ready" action="https://ui.teledit.com/Danal/Teledit/Web/Start.php" method="post">
<%
MakeFormInput Res , Array("Result","ErrMsg")
MakeFormInput ByPassValue , null
%>
<input type="hidden" name="CPName"	value="<%=CPName%>">
<input type="hidden" name="ItemName"	value="<%=ItemName%>">
<input type="hidden" name="ItemAmt"	value="<%=ItemAmt%>">
<input type="hidden" name="IsPreOtbill"	value='<%=TransR.Item("IsPreOtbill")%>'>
<input type="hidden" name="IsSubscript"	value='<%=TransR.Item("IsSubscript")%>'>
</form>
<script Language="JavaScript">
	document.Ready.submit();
</script>
</body>
</html>
<%
	Else
		'/**************************************************************************
		' *
		' * ���� ���п� ���� �۾�
		' *
		' **************************************************************************/
		Result 		= Res.Item("Result")
		ErrMsg 		= Res.Item("ErrMsg")
		AbleBack 	= false
		BackURL 	= ByPassValue.Item("BackURL")
		IsUseCI		= ByPassValue.Item("IsUseCI")
		CIURL 		= ByPassValue.Item("CIURL")
		BgColor 	= ByPassValue.Item("BgColor")
%>
		<!--#include file = "Error.asp"-->
<%
	End IF
%>