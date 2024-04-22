#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#DEFINE ENTER Chr(13)+Chr(10) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³M440STTS   º Autor ³ Edgar Serrano     º Data ³  20/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao LIBERACAO DA ROTINA LIBERA PEDIDO DE VENDA        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico PIC                                             º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

*---------------------*
User Function M440STTS  
*---------------------*

Local cPed :=  ALLTRIM(SC5->C5_NUM)
Local cQuery := ""


   cQuery := " SELECT"                                          + CRLF
   cQuery += " SC6.C6_XTPOPER"                                  + CRLF
   cQuery += " ,SC9.C9_BLCRED"                                  + CRLF
   cQuery += " ,SC9.C9_BLEST"                                   + CRLF
   cQuery += " FROM " +RetSqlName("SC9")+ " SC9(NOLOCK), "      + CRLF
   cQuery += "      " +RetSqlName("SC6")+ " SC6(NOLOCK)  "      + CRLF
   cQuery += " WHERE SC9.C9_PEDIDO = '" + ALLTRIM(cPed) + "' "  + CRLF
   cQuery += " AND SC9.C9_FILIAL = '" + xFilial ("SC9") + "'"   + CRLF
   cQuery += " AND SC6.C6_FILIAL = '" + xFilial ("SC6") + "'"   + CRLF
   cQuery += " AND SC9.C9_PEDIDO = SC6.C6_NUM "                 + CRLF
   cQuery += " AND SC9.D_E_L_E_T_ = ' '"                        + CRLF
   cQuery += " AND SC6.D_E_L_E_T_ = ' '"                        + CRLF
      
    If Select("QRY") > 0
        Dbselectarea("QRY")
        QRY->(DbClosearea())         
    EndIf
    
    TcQuery cQuery New Alias "QRY"

    cOpr := ALLTRIM(QRY->C6_XTPOPER)

    If QRY->C9_BLCRED <> " "
        MsgAlert('ATENÇÃO',"Pedido Bloqueado por Credito, Por Favor Verifique!",{"Fechar"})
      ElseIf QRY->C9_BLCRED == " " .AND. QRY->C9_BLEST == " " 
        Aviso('Atenção',"Pedido liberado com sucesso!",{"Fechar"})
   EndIf 

Return
