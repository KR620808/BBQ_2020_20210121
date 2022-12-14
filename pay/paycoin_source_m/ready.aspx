<%@ page language="C#" autoeventwireup="true" inherits="ready, App_Web_ready.aspx.cdcab7d2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <link href="/Styles/style.css" rel="stylesheet" type="text/css" />
</head>
<body onload="setTimeout(function() { document.frm1.submit() }, 1)">
    <form action="<%=startURL%>" name="frm1" method="post">
        <div>
            <table>
                <tr>
                    <td>
                        <input type="hidden" name="orderid" value="<%=orderid%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="amount" value="<%=Amount%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="product" value="<%=Product%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="tid" value="<%=tid%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="back_url" value="<%=backURL%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="cpid" value="<%=cpid%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="order_idx" value="<%=order_idx%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="CARD_SEQ" value="<%=CARD_SEQ%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="gubun" value="<%=gubun%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="domain" value="<%=domain%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="pay_method" value="<%=pay_method%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="branch_id" value="<%=branch_id%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="sub_cp_id" value="<%=sub_cp_id%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="user_id" value="<%=user_id%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="agent_type" value="<%=agent_type%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <textarea name="startparam" rows="10" cols="60" style="display:none;"><%=startParam%></textarea>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="startURL" value="<%=startURL%>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="hidden" name="returnscheme" value="<%=ReturnScheme%>" />
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
