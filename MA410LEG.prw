#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"


#DEFINE  ENTER CHR(13)+CHR(10)

/*���������������������������������������������������������������������������
���Programa  � MA410LEG   � Autor � Meliora/Gustavo   Data �    /  /      ���
�������������������������������������������������������������������������͹��
���Descricao � Legenda de Cores - Pedido de Venda                         ���
�������������������������������������������������������������������������͹��
���Uso       � PIC/Pharmaspecial                                          ���
���������������������������������������������������������������������������*/  

User Function MA410LEG()

Local _aLegend := PARAMIXB

    AADD( _aLegend, {"BR_PINK"   ,"Bloqueio por Credito"})

Return(_aLegend) 

