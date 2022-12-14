<!--#include virtual="/api/include/utf8.asp"-->
<!--#include virtual="/api/include/coop_exchange_proc.asp"-->
<!--#include virtual="/api/include/ktr_exchange_proc.asp"-->
<%
	REFERERURL	= Request.ServerVariables("HTTP_REFERER")

	If left(REFERERURL,19) = left(GetCurrentHost,19) Then 
	Else 
		Response.Write "{""result"":1,""message"":""잘못된 접근방식 입니다.""}"
		Response.End 
	End If

    USER_IP = GetIPADDR()

    Dim txtPIN, PIN_save 
    txtPIN = GetReqStr("txtPIN","")
    PIN_save = GetReqStr("PIN_save","")

    If PIN_save = "Y" Then 
        If IsEmpty(Session("userIdx")) Or IsNull(Session("userIdx")) Or Session("userIdx") = "" Then 
            Response.Write "{""result"":1,""message"":""계정 정보가 없습니다. 다시 로그인하시기 바랍니다.""}"
            Response.End 
        End If 
    End If
    
    if txtPIN <> "" Then  
        dim returnMenuJson : returnMenuJson = ""
        dim arrPin : arrPin = split(txtPIN, "||") 
        dim menuItemList : menuItemList = ""
        for i = 0 to Ubound(arrPin)
            txtPIN = arrPin(i)

            '중복 e쿠폰 체크
            for j=0 to Ubound(arrPin)
                if i<>j Then 
                    if txtPIN = arrPin(j) Then 
                        Response.Write "{""result"":1,""message"":""해당하는 모바일 상품권은 이미 등록 되어있습니다.""}"
                        response.end 
                        exit for
                    end if 
                end if 
            next 
            
            '숫자체크 
            If IsEmpty(txtPIN) Or IsNull(txtPIN) Or Trim(txtPIN) = "" Or Not IsNumeric(txtPIN) Then 
                Response.Write "{""result"":1,""message"":""모바일 상품권은 숫자만 입력 가능합니다.""}"
                response.end 
                exit for
            End If
            
            '쿠폰 조회 로그 쌓기 (2022.3.4)
            dim client_ip 
            client_ip = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
            If FncIsBlank(client_ip) Then
                client_ip = Request.ServerVariables("HTTP_CLIENT_IP")
                If FncIsBlank(client_ip) Then
                    client_ip = Request.ServerVariables("REMOTE_ADDR")
                End If
            End If

            Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('" & Session("userIdx") & "','['+convert(varchar(19), getdate() , 120)+'] PIN_save "& PIN_save & " / txtPIN " & txtPIN & " / SESSION " & "P"&Session.sessionid & " / CLIENT_IP " & C_STR(client_ip) & " / REMOTE_ADDR " & Request.ServerVariables("REMOTE_ADDR") & " / REFERER " & Request.ServerVariables("HTTP_REFERER") & "','0','ajax_getEcouponAll-1')"
            dbconn.Execute(Sql)

			Set eCmd = Server.CreateObject("ADODB.Command")
			With eCmd
				.ActiveConnection = dbconn
				.NamedParameters = True
				.CommandType = adCmdStoredProc
				.CommandText = "bp_coupon_log"

				.Parameters.Append .CreateParameter("@coupon_number", adVarChar, adParamInput, 50, txtPIN)
				.Parameters.Append .CreateParameter("@sessionid", adVarChar, adParamInput, 100, "P"&Session.sessionid)
			    .Parameters.Append .CreateParameter("@member_idx", adInteger, adParamInput, , Session("userIdx"))
				.Parameters.Append .CreateParameter("@remote_addr", adVarChar, adParamInput, 30, C_STR(client_ip))
				.Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)
				.Parameters.Append .CreateParameter("@ERRMSG", adVarChar, adParamOutput, 500)
				.Execute

				ERRCODE = .Parameters("@ERRCODE").Value
				ERRMSG = .Parameters("@ERRMSG").Value
			End With
			Set eCmd = Nothing
			If ERRCODE = 1 Then 
                Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('" & Session("userIdx") & "','['+convert(varchar(19), getdate() , 120)+'] PIN_save "& PIN_save & " / txtPIN " & txtPIN & " / SESSION " & "P"&Session.sessionid & "/" & C_STR(Session("userIdx")) & " / REMOTE_ADDR " & client_ip & " / ERRCODE " & ERRCODE & " / ERRMSG 조회초과-" & ERRMSG & "','0','ajax_getEcouponAll-err')"
                dbconn.Execute(Sql)

				Response.Write "{""result"":1, ""message"":"""& ERRMSG &"""}"
				Response.End
			End If
            '//쿠폰 조회 로그 쌓기 (2022.3.4)

            if left(txtPIN, 1) = "6" or left(txtPIN, 1) = "8" Then 
                Url = COOP_API_URL     
                AuthKey = COOP_AUTH_KEY
                CompCode = COOP_COMPANY_CODE
                BranchCode = "0000"
                AuthPrice = "0"
                AuthDate = Replace(Date, "-", "") & Replace(FormatDateTime(Time(), 4), ":","") & Right(Time(), 2)
                ProductCode = "0000"

                SET coopCoupon_Result = NEW PosResult_Coop
                'coopCoupon_Result.CouponCall Url, AuthKey, ProcessType, CouponType, CompCode, txtPIN, BranchCode, PosNum, AuthPrice, AuthDate, "", "", ProductCode

                coopCoupon_Result.CouponCall Url, AuthKey, "info", txtPIN, BranchCode, AuthPrice, AuthDate, "", "", ProductCode
                RESULT = coopCoupon_Result.m_ResultCode
                RESULT_MSG = coopCoupon_Result.m_ResultMsg
                RESULT_PRODUCT_CODE = coopCoupon_Result.m_ResultProductCode
                ERROR = coopCoupon_Result.m_ErrorCode
            else 
                SET smartcon_Result = NEW PosResult
                smartcon_Result.Smartcon_Proc "info", txtPIN, "bbq_ecoupon","bbq_ecoupon","bbqsite",Replace(Date, "-", ""), Replace(FormatDateTime(Time(), 4), ":","") & Right(Time(), 2), ""
                RESULT = smartcon_Result.m_StatusCode
                RESULT_MSG = smartcon_Result.m_ErrorMessage
                RESULT_PRODUCT_CODE = smartcon_Result.m_ProductCode
            end if 

            Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('" & Session("userIdx") & "','['+convert(varchar(19), getdate() , 120)+'] PIN_save "& PIN_save & " / txtPIN " & txtPIN & " / SESSION " & "P"&Session.sessionid & "/" & C_STR(Session("userIdx")) & " / REMOTE_ADDR " & Request.ServerVariables("REMOTE_ADDR") & " / RESULT " & RESULT & " / RESULT_MSG " & RESULT_MSG & "','0','ajax_getEcouponAll-2')"
            dbconn.Execute(Sql)

            Dim cmd, rs

            if RESULT = "0000" or RESULT = "000" Then

                Set cmd = Server.CreateObject("ADODB.Command")
                With cmd
                    .ActiveConnection = dbconn
                    .NamedParameters = True
                    .CommandType = adCmdStoredProc
                    .CommandText = BBQHOME_DB & ".DBO.UP_COUPON_INFO_NEW_2"

                    .Parameters.Append .CreateParameter("@PIN", adVarChar, adParamInput, 12, txtPIN)
                    .Parameters.Append .CreateParameter("@CPNID", adVarChar, adParamInput, 20, RESULT_PRODUCT_CODE)

                    Set oRs = .Execute

                End With
                Set cmd = Nothing

                If NOT oRs.EOF Then
                    MENU_CD = oRs("MENU_CD")        'MENUID
                    OPTION_ID = oRs("OPTION_ID")    'OPTIONID
                    MENU_NM = oRs("MENU_NM")
                    MENU_PRC = oRs("MENU_PRC") 
                    USESDATE = oRs("USESDATE")      '사용가능 시작일
                    USEEDATE = oRs("USEEDATE")      '사용가능 종료일

                    Dim aCmd, aRs

                    Set aCmd = Server.CreateObject("ADODB.Command")

                    With aCmd
                        .ActiveConnection = dbconn
                        .NamedParameters = True
                        .CommandType = adCmdStoredProc
                        .CommandText = "bp_menu_List"
                        .Parameters.Append .CreateParameter("@ListType", adVarChar, adParamInput, 5, "ONE")
                        .Parameters.Append .CreateParameter("@menu_idx", adInteger, adParamInput, , MENU_CD)
                        .Parameters.Append .CreateParameter("@totalCount", adInteger, adParamOutput)
                        .Parameters.Append .CreateParameter("@BRAND_CODE", adVarchar, adParamInput, 5, SITE_BRAND_CODE)

                        Set aRs = .Execute
                    End With
                    Set aCmd = Nothing

                    Dim vMenuIdx, vMenuTitle, vMenuName, vMenuPrice, vMainFilePath, vMainFileName
                    If Not (aRs.BOF Or aRs.EOF) Then
                        RESULT_MSG = "사용가능한 모바일 상품권입니다."
                        vMenuIdx = aRs("menu_idx")
                        vMenuName = aRs("menu_name")
                        vMenuPrice = aRs("menu_price")
                        vMainFilePath	= "/images/menu/"	'	aRs("THUMB_FILEPATH")	'
                        vMainFileName	= "E-coupon_basic_img.png"	'	aRs("THUMB_FILENAME")	'

                        if PIN_save = "Y" then 
                            Set aCmd = Server.CreateObject("ADODB.Command")

                            With aCmd
                                .ActiveConnection = dbconn
                                .NamedParameters = True
                                .CommandType = adCmdStoredProc
                                .CommandText = "bt_member_coupon_insert"

                                .Parameters.Append .CreateParameter("@member_idx", adInteger, adParamInput, , Session("userIdx"))
                                .Parameters.Append .CreateParameter("@member_idno", adVarChar, adParamInput, 50, Session("userIdNo"))
                                .Parameters.Append .CreateParameter("@member_type", adVarChar, adParamInput, 10, Session("userType"))
                                .Parameters.Append .CreateParameter("@c_code", adVarChar, adParamInput, 200, txtPIN)
                                .Parameters.Append .CreateParameter("@c_title", adVarChar, adParamInput, 200, vMenuName)
                                .Parameters.Append .CreateParameter("@ERRCODE", adInteger, adParamOutput)
                                .Parameters.Append .CreateParameter("@ERRMSG", adVarChar, adParamOutput, 500)

                                Set aRs = .Execute

                                ErrCode = .Parameters("@ERRCODE").Value
                                ErrMsg = .Parameters("@ERRMSG").Value
                            End With
                            Set aCmd = Nothing

                            If Not (aRs.BOF Or aRs.EOF) Then
                                if ErrCode <> 0 then 
                                    Response.Write "{""result"":1,""message"":""해당하는 모바일 상품권은 이미 등록 되어있습니다.""}"
                                    response.end 
                                    
                                    Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('0','['+convert(varchar(19), getdate() , 120)+'] 이미 등록 PIN_save "& PIN_save & " / txtPIN " & txtPIN & " / SESSION " & "P"&Session.sessionid & "/" & C_STR(Session("userIdx")) & " / REMOTE_ADDR " & Request.ServerVariables("REMOTE_ADDR") & "','0','ajax_getEcouponAll-err1')"
                                    dbconn.Execute(Sql)
                                    
                                    exit for
                                end if 
                            End If
                            Set aRs = Nothing
                        End If

                        menuItem = "M$$"&vMenuIdx&"$$0$$"&vMenuPrice&"$$"&vMenuName&"$$"&vMainFilePath&vMainFileName&"$$"&txtPIN&"$$#"
                        if returnMenuJson = "" then 
                            returnMenuJson = """menuItemList"": [" 
                        else 
                            returnMenuJson = returnMenuJson & ", " 
                        end if 
                        returnMenuJson = returnMenuJson & "{""menuItem"":""" & menuItem &""", ""pin"":""" & txtPIN & """, ""title"":""" & vMenuName & """, ""price"":""" & MENU_PRC & """, ""useSDate"":""" & USESDATE & """, ""useEDate"":""" & USEEDATE & """ }"
                    Else
                        Response.Write "{""result"":1,""message"":""해당하는 모바일 상품권이 없습니다.""}"
                        Response.End
                        
                        Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('0','['+convert(varchar(19), getdate() , 120)+'] 없는 상품권 PIN_save "& PIN_save & " / txtPIN " & txtPIN & " / SESSION " & C_STR(Session("userIdx")) & "/" & "P"&Session.sessionid & " / REMOTE_ADDR " & Request.ServerVariables("REMOTE_ADDR") & "','0','ajax_getEcouponAll-err2')"
                        dbconn.Execute(Sql)

                        exit for
                    End If
                Else
                    Response.Write "{""result"":3,""message"":""" & "모바일 상품권 정보가 존재하지 않습니다." & """}"
                    Response.End
                    
                    Sql = "Insert Into bt_order_g2_log(order_idx, payco_log, coupon_amt, log_point) values('0','['+convert(varchar(19), getdate() , 120)+'] 없는 상품권 PIN_save "& PIN_save & " / txtPIN " & txtPIN & " / SESSION " & C_STR(Session("userIdx")) & "/" & "P"&Session.sessionid & " / REMOTE_ADDR " & Request.ServerVariables("REMOTE_ADDR") & "','0','ajax_getEcouponAll-err3')"
                    dbconn.Execute(Sql)
                    
                    exit for
                End If
            Else
                if RESULT_MSG = "" then RESULT_MSG = "잘못된 쿠폰번호"
                Response.Write "{""result"":1,""message"":""" & RESULT_MSG & ".""}"
                Response.End
                exit for
            end if
        next
        returnMenuJson = returnMenuJson & "]"
        Response.Write "{""result"":0,""message"":""" & RESULT_MSG & """, " & returnMenuJson & "}"
    end if 
%>