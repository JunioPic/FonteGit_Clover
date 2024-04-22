#Include "Totvs.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "rwmake.ch"

/*/
    Tela de Separação Pic
    Desenvolvido por Junior Guerreiro
    Data do Desenvolvimento 10/11/2021
/*/
User Function xTelsepP()

    Local aArea := GetArea()

    //Fontes
    Local cFontUti    := "Tahoma"
    Local oFontAno    := TFont():New(cFontUti,,-38)
    Local oFontSub    := TFont():New(cFontUti,,-20)
    Local oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
    Local oFontBtn    := TFont():New(cFontUti,,-14)
    //Janela e componentes
    Private oDlgGrp
    Private oPanGrid
    Private oGetGrid
    Private aColunas := {}
    Private cAliasTab := "TMPSBM"
    //Tamanho da janela
    Private    aTamanho := MsAdvSize()
    Private    nJanLarg := aTamanho[5]
    Private    nJanAltu := aTamanho[6]


    //Cria a temporária
    oTempTable := FWTemporaryTable():New(cAliasTab)
     
    //Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
    aFields := {}
    aAdd(aFields, {"XXCLI",        "C", TamSX3('C5_XCLIDES')[01], 0})
    aAdd(aFields, {"XXPROD",       "C", TamSX3('B1_DESC')[01],    0})
    aAdd(aFields, {"XXLOTE",       "C", TamSX3('C9_LOTECTL')[01], 0})
    aAdd(aFields, {"XXPEDIDO",     "C", TamSX3('C9_PEDIDO')[01],  0})
    aAdd(aFields, {"XXLIBERA",     "D", TamSX3('C9_DATALIB')[01], 0})
    aAdd(aFields, {"XXITEM",       "C", TamSX3('C9_ITEM')[01],    0})
    aAdd(aFields, {"XXQTDA",       "N", TamSX3('C9_QTDLIB')[01],  2})
    aAdd(aFields, {"XXEST",        "N", TamSX3('B2_QATU')[01],    2})
    aAdd(aFields, {"XXBLCRED",     "C", TamSX3('C9_BLCRED')[01],  0})
    aAdd(aFields, {"XXBLEST",      "C", TamSX3('C9_BLEST')[01],   0})
    aAdd(aFields, {"XXOBS",        "C", TamSX3('C5_XOBS')[01],    0})

     
    //Define as colunas usadas, adiciona indice e cria a temporaria no banco
    oTempTable:SetFields( aFields )
    oTempTable:AddIndex("1", {"XXPEDIDO"} )
    oTempTable:AddIndex("2", {"XXITEM"} )
    oTempTable:Create()
 
    //Monta o cabecalho
    fMontaHead()
 
    //Montando os dados, eles devem ser montados antes de ser criado o FWBrowse
    FWMsgRun(, {|oSay| fMontDados(oSay) }, "Processando", "Buscando Pedidos a Separar")
 
    //Criando a janela
    DEFINE MSDIALOG oDlgGrp TITLE "Pedidos a Separar" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
             

        //Labels gerais
        @ 004, 003 SAY "FAT"                      SIZE 200, 030 FONT oFontAno  OF oDlgGrp COLORS RGB(149,179,215) PIXEL
        @ 004, 050 SAY "Listagem de"              SIZE 200, 030 FONT oFontSub  OF oDlgGrp COLORS RGB(031,073,125) PIXEL
        @ 014, 050 SAY "Pedidos a Separar"        SIZE 200, 030 FONT oFontSubN OF oDlgGrp COLORS RGB(031,073,125) PIXEL
 
        //Botões
        @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 050, 018 OF oDlgGrp ACTION (xFechar())   FONT oFontBtn PIXEL
        @ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnFech  PROMPT "Atualizar"     SIZE 050, 018 OF oDlgGrp ACTION (xAtuali())   FONT oFontBtn PIXEL
        @ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnLege  PROMPT "Imprimir"      SIZE 050, 018 OF oDlgGrp ACTION (xImp()) FONT oFontBtn PIXEL
 
        //Dados
        @ 024, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "Listagem de pedido a separar: " OF oDlgGrp COLOR 0, 16777215 PIXEL
        oGrpDad:oFont := oFontBtn
            oPanGrid := tPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))
            oGetGrid := FWBrowse():New()
            oGetGrid:DisableFilter()
            oGetGrid:DisableConfig()
            oGetGrid:DisableReport()
            oGetGrid:DisableSeek()
            oGetGrid:DisableSaveConfig()
            oGetGrid:SetFontBrowse(oFontBtn)
            oGetGrid:SetAlias(cAliasTab)
            oGetGrid:SetDataTable()
            oGetGrid:SetInsert(.F.)
            oGetGrid:SetDelete(.F., { || .F. })
            oGetGrid:lHeaderClick := .F.
            oGetGrid:SetColumns(aColunas)
            oGetGrid:SetOwner(oPanGrid)
            oGetGrid:Activate()
    ACTIVATE MsDialog oDlgGrp CENTERED
 
    //Deleta a temporaria
    oTempTable:Delete()
 
    RestArea(aArea)
Return
 
Static Function fMontaHead()
    Local nAtual
    Local aHeadAux := {}

    //Adicionando colunas
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aHeadAux, {"XXCLI", "Cliente",             "C", TamSX3('C5_XCLIDES')[01],  0, ""})
    aAdd(aHeadAux, {"XXPROD", "Produto",            "C", TamSX3('B1_DESC')[01],     0, ""})
    aAdd(aHeadAux, {"XXLOTE", "Lote",               "C", TamSX3('C9_LOTECTL')[01],  0, ""})
    aAdd(aHeadAux, {"XXPEDIDO", "Pedido",           "C", TamSX3('C9_PEDIDO')[01],   0, ""})
    aAdd(aHeadAux, {"XXLIBERA", "Dt. Liberacao",    "D", TamSX3('C9_DATALIB')[01],  0, ""})
    aAdd(aHeadAux, {"XXITEM", "Item",               "C", TamSX3('C9_ITEM')[01],     0, ""})
    aAdd(aHeadAux, {"XXQTDA", "Qtda.",              "N", TamSX3('C9_QTDLIB')[01],   2, "@E 999999.99"})
    aAdd(aHeadAux, {"XXEST", "Estoque",             "N", TamSX3('B2_QATU')[01],     4, "@E 999999.99"})
    aAdd(aHeadAux, {"XXBLCRED", "Blq. Credito",     "C", TamSX3('C9_BLCRED')[01],   0, ""})
    aAdd(aHeadAux, {"XXBLEST", "Blq. Estoque",      "C", TamSX3('C9_BLEST')[01],    0, ""})
    aAdd(aHeadAux, {"XXOBS", "Obs.",                "C", TamSX3('C5_XOBS')[01],     0, ""})
    
 
    //Percorrendo e criando as colunas
    For nAtual := 1 To Len(aHeadAux)
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| " + cAliasTab + "->" + aHeadAux[nAtual][1] +"}"))
        oColumn:SetTitle(aHeadAux[nAtual][2])
        oColumn:SetType(aHeadAux[nAtual][3])
        oColumn:SetSize(aHeadAux[nAtual][4])
        oColumn:SetDecimal(aHeadAux[nAtual][5])
        oColumn:SetPicture(aHeadAux[nAtual][6])
        aAdd(aColunas, oColumn)
    Next
Return
 
Static Function fMontDados(oSay)
    Local aArea := GetArea()
    Local cQry  := ""
    Local nAtual := 0
    Local nTotal := 0

    //Zera a grid
    aColsGrid := {}

    //Montando a query
    //oSay:SetText("Montando a consulta")
    cQry := " SELECT DISTINCT  "                                                      + CRLF
    cQry += " SC5.C5_XCLIDES"                                                         + CRLF
    cQry += " ,SB1.B1_DESC "                                                          + CRLF
    cQry += " ,SC9.C9_LOTECTL"                                                        + CRLF
    cQry += " ,SC9.C9_PEDIDO"                                                         + CRLF
    cQry += " ,SC9.C9_DATALIB"                                                        + CRLF
    cQry += " ,SC9.C9_ITEM"                                                           + CRLF
    cQry += " ,SC9.C9_QTDLIB "                                                        + CRLF
    cQry += " ,SB2.B2_QATU"                                                           + CRLF
    cQry += " ,SC9.C9_BLCRED"                                                         + CRLF
    cQry += " ,SC9.C9_BLEST"                                                          + CRLF
    cQry += " ,SC5.C5_XOBS"                                                           + CRLF
    cQry += " FROM " +RetSqlName("SC9")+ " SC9(NOLOCK),"                              + CRLF
    cQry += "      " +RetSqlName("SB1")+ " SB1(NOLOCK),"                              + CRLF
    cQry += "      " +RetSqlName("SB2")+ " SB2(NOLOCK),"                              + CRLF
    cQry += "      " +RetSqlName("SC5")+ " SC5(NOLOCK) "                              + CRLF
    cQry += " WHERE  SC9.C9_NFISCAL = '' "                                            + CRLF
    cQry += " AND SB2.B2_LOCAL = '01' "                                               + CRLF
    cQry += " AND SC9.C9_BLCRED = ' ' "                                               + CRLF
    cQry += " AND SC9.C9_BLEST = ' ' "                                                + CRLF
    cQry += " AND SB1.B1_COD = SC9.C9_PRODUTO"                                        + CRLF
    cQry += " AND SB2.B2_COD = SC9.C9_PRODUTO "                                       + CRLF
    cQry += " AND SC5.C5_NUM = SC9.C9_PEDIDO "                                        + CRLF
    cQry += " AND SC9.D_E_L_E_T_ = ''"                                                + CRLF
    cQry += " AND SB1.D_E_L_E_T_ = ''"                                                + CRLF 
    cQry += " AND SB2.D_E_L_E_T_ = ''"                                                + CRLF 
    cQry += " GROUP BY"                                                               + CRLF
    cQry += " SC5.C5_XCLIDES "                                                        + CRLF
    cQry += " ,SB1.B1_DESC "                                                          + CRLF
    cQry += " ,SC9.C9_LOTECTL "                                                       + CRLF
    cQry += " ,SC9.C9_PEDIDO "                                                        + CRLF
    cQry += " ,SC9.C9_DATALIB "                                                       + CRLF
    cQry += " ,SC9.C9_ITEM "                                                          + CRLF
    cQry += " ,SC9.C9_QTDLIB "                                                        + CRLF
    cQry += " ,SB2.B2_QATU "                                                          + CRLF
    cQry += " ,SC9.C9_BLCRED "                                                        + CRLF
    cQry += " ,SC9.C9_BLEST "                                                         + CRLF
    cQry += " ,SC5.C5_XOBS "                                                          + CRLF

    //Executando a query
    //oSay:SetText("Executando a consulta")
    PLSQuery(cQry, "QRY")

 
    //Se houve dados
    If ! QRY->(EoF())
        //Pegando o total de registros
        DbSelectArea("QRY")
        Count To nTotal
        QRY->(DbGoTop())
 
        //Enquanto houver dados
        While ! QRY->(EoF())
 
            //Muda a mensagem na regua
            nAtual++
            //oSay:SetText("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
 
            RecLock(cAliasTab, .T.)
                (cAliasTab)->XXCLI       := QRY->C5_XCLIDES
                (cAliasTab)->XXPROD      := QRY->B1_DESC
                (cAliasTab)->XXLOTE      := QRY->C9_LOTECTL
                (cAliasTab)->XXPEDIDO    := QRY->C9_PEDIDO
                (cAliasTab)->XXLIBERA    := QRY->C9_DATALIB
                (cAliasTab)->XXITEM      := QRY->C9_ITEM
                (cAliasTab)->XXQTDA      := QRY->C9_QTDLIB
                (cAliasTab)->XXEST       := QRY->B2_QATU
                (cAliasTab)->XXBLCRED    := QRY->C9_BLCRED
                (cAliasTab)->XXBLEST     := QRY->C9_BLEST
                (cAliasTab)->XXOBS       := QRY->C5_XOBS
            (cAliasTab)->(MsUnlock())
 
            QRY->(DbSkip())
        EndDo
 
    Else
        MsgStop("Nao foi encontrado registros!", "Atencao")
 
        RecLock(cAliasTab, .T.)
            (cAliasTab)->XXCLI        := " "
            (cAliasTab)->XXPROD       := " "
            (cAliasTab)->XXLOTE       := " "
            (cAliasTab)->XXPEDIDO     := " "
      DTOS((cAliasTab)->XXLIBERA)     := " "
            (cAliasTab)->XXITEM       := " "
      TRANSFORM((cAliasTab)->XXQTDA, "@E 999.999") := " "
      TRANSFORM((cAliasTab)->XXEST,  "@E 999.999") := " "
            (cAliasTab)->XXBLCRED     := " "
            (cAliasTab)->XXBLEST      := " "
            (cAliasTab)->XXOBS        := " "
        (cAliasTab)->(MsUnlock())
    EndIf
    QRY->(DbCloseArea())
    (cAliasTab)->(DbGoTop())
 
    RestArea(aArea)

Return

 Static Function xAtuali()

    oTempTable:Delete()
    aColsGrid := {}
    u_xTelsepP()
        
 Return

Static Function xImp()

  //oGetGrid:OptionReport()
  //oGetGrid:Report()

    Local cQry   := ""
    Local cTexto := "guia"
    Local nNext := 0
    Private dData  := Dtoc(dDatabase)
    Private hHora  := Time()
    Private nLin := 40
    Private nLin1 := 40
    Private oPrinter
    Private oFont1
    Private oFont2
    Private oHGRAY := TBrush():New( , CLR_HGRAY)
    Private lPreview
    Private cLogo := FisxLogo("1")
   
    
	    /*** FONTES ***/
	Private oFont18T  	:= TFont():New("Courier New",,18,,.T.,,,,,.F.)
	Private oFont16T  	:= TFont():New("Courier New",,16,,.T.,,,,,.F.)
	Private oFont14TC 	:= TFont():New("Courier New",,14,,.T.,,,,,.F.)
	Private oFont14T  	:= TFont():New("Arial"      ,,14,,.T.,,,,,.F.)
	Private oFont18TA 	:= TFont():New("Arial"      ,,18,,.T.,,,,,.F.)
	Private oFont14TI  	:= TFont():New("Arial"      ,,13,,.T.,,,,.T.,.F.)
	Private oFont11F  	:= TFont():New("Arial"      ,,11,,.F.,,,,,.F.)
	Private oFont13T  	:= TFont():New("Arial"      ,,12,,.T.,,,,,.F.)
	Private oFont13F  	:= TFont():New("Arial"      ,,12,,.F.,,,,,.F.)
	Private oFont10FA 	:= TFont():New("Arial"      ,,10,,.F.,,,,,.F.)
	Private oFont10F 	:= TFont():New("Courier New",,10,,.F.,,,,,.F.)
	Private oFont11FA 	:= TFont():New("Arial"      ,,11,,.F.,,,,,.F.)
	
	Private oFont09T  	:= TFont():New("Courier New",,09,,.T.,,,,,.F.)
	Private oFont07F  	:= TFont():New("Courier New",,07,,.F.,,,,,.F.)
	Private oFont09F  	:= TFont():New("Courier New",,09,,.F.,,,,,.F.)
	Private oFont09FA  	:= TFont():New("Arial",,09,,.F.,,,,,.F.)
	
	Private oFont7TA  	:= TFont():New("Courier New",,07,,.T.,,,,,.F.)
	Private oFont12F  	:= TFont():New("Courier New",,12,,.F.,,,,,.F.)
	Private oFont10T  	:= TFont():New("Courier New",,10,,.T.,,,,,.F.)
	Private oFont14N  	:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)
	
	Private oFont10AT  	:= TFont():New("Arial"      ,,10,,.T.,,,,,.F.)
	Private oFont10AF  	:= TFont():New("Arial"      ,,10,,.F.,,,,,.F.)
	
    Private  NSpace10   := 10
    Private  NSpace20   := 20
    Private  NSpace30   := 30
    Private  NSpace40   := 40
    Private  NSpace50   := 50

    If oPrinter == Nil
    lPreview := .T.
    oPrinter := FWMSPrinter():New(cTexto, 6,.F.,,.T.)
    oPrinter:SetResolution(72) //Tamanho estipulado para a Danfe
    oPrinter:SetLandscape()
    oPrinter:SetPaperSize(9)
    oPrinter:SetMargin(20,20,20,20)
    oPrinter:cPathPDF :="C:\TEMP\"    
    EndIf

    cQry := " SELECT DISTINCT  "                                                      + CRLF
    cQry += " SC5.C5_XCLIDES"                                                         + CRLF
    cQry += " ,SC9.C9_PRODUTO"                                                        + CRLF
    cQry += " ,SB1.B1_DESC "                                                          + CRLF
    cQry += " ,SC9.C9_LOTECTL"                                                        + CRLF
    cQry += " ,SC9.C9_PEDIDO"                                                         + CRLF
    cQry += " ,SC9.C9_DATALIB"                                                        + CRLF
    cQry += " ,SC9.C9_ITEM"                                                           + CRLF
    cQry += " ,SC9.C9_QTDLIB "                                                        + CRLF
    cQry += " ,SB2.B2_QATU"                                                           + CRLF
    cQry += " ,SC9.C9_BLCRED"                                                         + CRLF
    cQry += " ,SC9.C9_BLEST"                                                          + CRLF
    cQry += " ,SC5.C5_XOBS"                                                           + CRLF
    cQry += " FROM " +RetSqlName("SC9")+ " SC9(NOLOCK),"                              + CRLF
    cQry += "      " +RetSqlName("SB1")+ " SB1(NOLOCK),"                              + CRLF
    cQry += "      " +RetSqlName("SB2")+ " SB2(NOLOCK),"                              + CRLF
    cQry += "      " +RetSqlName("SC5")+ " SC5(NOLOCK) "                              + CRLF
    cQry += " WHERE  SC9.C9_NFISCAL = '' "                                            + CRLF
    cQry += " AND SB2.B2_LOCAL = '01' "                                               + CRLF
    cQry += " AND (SC9.C9_BLCRED = '' OR SC9.C9_BLCRED = '10') "                      + CRLF
    cQry += " AND (SC9.C9_BLEST = '' OR SC9.C9_BLEST = '10') "                        + CRLF
    cQry += " AND SB1.B1_COD = SC9.C9_PRODUTO"                                        + CRLF
    cQry += " AND SB2.B2_COD = SC9.C9_PRODUTO "                                       + CRLF
    cQry += " AND SC5.C5_NUM = SC9.C9_PEDIDO "                                        + CRLF
    cQry += " AND SC9.D_E_L_E_T_ = ''"                                                + CRLF
    cQry += " AND SB1.D_E_L_E_T_ = ''"                                                + CRLF 
    cQry += " AND SB2.D_E_L_E_T_ = ''"                                                + CRLF 
    cQry += " GROUP BY"                                                               + CRLF
    cQry += " SC5.C5_XCLIDES "                                                        + CRLF
    cQry += " ,SC9.C9_PRODUTO "                                                       + CRLF
    cQry += " ,SB1.B1_DESC "                                                          + CRLF
    cQry += " ,SC9.C9_LOTECTL "                                                       + CRLF
    cQry += " ,SC9.C9_PEDIDO "                                                        + CRLF
    cQry += " ,SC9.C9_DATALIB "                                                       + CRLF
    cQry += " ,SC9.C9_ITEM "                                                          + CRLF
    cQry += " ,SC9.C9_QTDLIB "                                                        + CRLF
    cQry += " ,SB2.B2_QATU "                                                          + CRLF
    cQry += " ,SC9.C9_BLCRED "                                                        + CRLF
    cQry += " ,SC9.C9_BLEST "                                                         + CRLF
    cQry += " ,SC5.C5_XOBS "                                                          + CRLF

     If Select("SPR") > 0
        Dbselectarea("SPR")
     GUI->(DbClosearea()) 
        
    EndIf
    
    TcQuery cQry New Alias "SPR"
    
       
    oPrinter:StartPage()
    oPrinter:Box (020, 020, 595, 810)
    xCadEmp()

    nLin += 45
    oPrinter:Line(nLin, 20, nLin, 810)
    nLin += 1
    oPrinter:FillRect({nLin, 20, nLin+25, 810}, oHGRAY)
    nLin += 15
    oPrinter:Say(nLin,320,"LISTA DE PEDIDOS A SEPARAR",               oFont14TC)
    nLin += 10
    oPrinter:Line(nLin, 20, nLin, 810)
    nLin += 10
    oPrinter:Say(nLin,030,"ITEM",            oFont10T)
    oPrinter:Say(nLin,070,"Nº PEDIDO",       oFont10T)
    oPrinter:Say(nLin,130,"CLIENTE",         oFont10T)
    oPrinter:Say(nLin,300,"PRODUTO",         oFont10T)
    oPrinter:Say(nLin,610,"LOTE",            oFont10T)
    oPrinter:Say(nLin,700,"QTDA. SEPARAR",   oFont10T)
    nLin += 5
    oPrinter:Line(nLin, 20, nLin, 810)

    WHile !("SPR")->(EOF())
    nLin += 10
    oPrinter:Say( nLin,030, +ALLTRIM(("SPR")->C9_ITEM),         oFont10F) 
    oPrinter:Say( nLin,070, +ALLTRIM(("SPR")->C9_PEDIDO),       oFont10F) 
    oPrinter:Say( nLin,130, +ALLTRIM(("SPR")->C5_XCLIDES),      oFont10F) 
    oPrinter:Say( nLin,300, +ALLTRIM(SUBSTR(SPR->C9_PRODUTO,10, 15)), oFont10F) 
    oPrinter:Say( nLin,330, " - " +ALLTRIM(("SPR")->B1_DESC),         oFont10F)
    oPrinter:Say( nLin,610, +ALLTRIM(("SPR")->C9_LOTECTL), oFont10F)
    oPrinter:Say( nLin,700, +TRANSFORM(("SPR")->C9_QTDLIB,'@e 999,999.99'), oFont10F)
    nLin += 10
    oPrinter:Say( nLin , 30, "OBS:",                    oFont10F)
    oPrinter:Say( nLin , 65, +ALLTRIM(("SPR")->C5_XOBS), oFont10F)
    nLin += 5
    oPrinter:Line(nLin, 20, nLin, 810)
    SPR->(DbSkip())

    If nNext = 0
       nNext := nNext + 1 
       oPrinter:Say(040,  720, "PAG:",                          oFont07F)
       oPrinter:Say(040,  735, +TRANSFORM(nNext, '@e 999'),     oFont07F)
    EndIf
     
    iF nLin > 560
      oPrinter:EndPage()
      oPrinter:StartPage()
      oPrinter:Box (020, 020, 595, 810)
      nNext += 1 
      oPrinter:Say(020,  720, "PAG:",                          oFont07F)
      oPrinter:Say(020,  735, +TRANSFORM(nNext, '@e 999'),     oFont07F)     
      nLin := 20   
    EndIf

 EndDo
    
    nLin2 := 560
    oPrinter:Say(nLin2,40,"____________________________________________", oFont10T)
    oPrinter:Say(nLin2,560,"___________________________________________", oFont10T)
    nLin2 += 10
    oPrinter:Say(nLin2,100,"ASS. SEPARADOR",                            oFont10T)
    oPrinter:Say(nLin2,630,"ASS. CONFERENTE",                           oFont10T)

	If lPreview
	     oPrinter:Preview()
	EndIf                      

	FreeObj(oPrinter)
	oPrinter := Nil

Return

Static Function xFechar()

    oDlgGrp:End()
    
Return

Static Function xCadEmp()

    Local aSM0Data2 := {}

   aSM0Data2 := FWSM0Util():GetSM0Data()
   _cEmp       := ALLTRIM(aSM0Data2[5][2])
   _cEmpTel    := ALLTRIM(aSM0Data2[6][2])
   _cEmpCnpj   := ALLTRIM(aSM0Data2[10][2])
   _cEmpIE     := ALLTRIM(aSM0Data2[12][2])
   _cEmpEnd    := ALLTRIM(aSM0Data2[14][2])
   _cEmpBairro := ALLTRIM(aSM0Data2[16][2])
   _cEmpCidade := ALLTRIM(aSM0Data2[17][2])
   _cEmpUf     := ALLTRIM(aSM0Data2[18][2])
   _cEmpCep    := ALLTRIM(aSM0Data2[19][2])

    oPrinter:SayBitmap( 040, 040, cLogo , 100, 50)
    oPrinter:Say(nLin,150,ALLTRIM(_cEmp),                                           oFont14TC)
    nLin += 10                                      
    oPrinter:Say(nLin,150,_cEmpEnd+"-"+_cEmpBairro+"-"+_cEmpCidade+"-"+_cEmpUf+"- CEP:"+TRANSFORM(_cEmpCep,"@R 99999-999"),oFont09F)
    oPrinter:Say(nLin,700, "DATE:",                                      oFont07F)
    oPrinter:Say(nLin,730, OemToAnsi(dData),                             oFont07F)
    nLin += 10
    oPrinter:Say(nLin,150,TRANSFORM(_cEmpTel, "@R (99) 9999-9999" )+"- CNPJ:"+TRANSFORM(_cEmpCnpj, "@R 99.999.999/9999-99")+"- I.E:"+TRANSFORM(_cEmpIE, "@R 999.999.999.999" ),  oFont09F)
    oPrinter:Say(nLin,700, "HOUR:",                                      oFont07F)
    oPrinter:Say(nLin,730, OemToAnsi(hHora),                             oFont07F)

Return



