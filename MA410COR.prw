#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#DEFINE ENTER Chr(13)+Chr(10) 

/*���������������������������������������������������������������������������
���Programa  � MA410COR   � Autor � Meliora/Gustavo   Data �    /  /      ���
�������������������������������������������������������������������������͹��
���Descricao � Adicao de Cores Tela Pedido de Venda                       ���
�������������������������������������������������������������������������͹��
���Uso       � PIC/Pharmaspecial                                          ���
���������������������������������������������������������������������������*/ 

*---------------------*
User Function MA410COR
*---------------------*
Local _aCor := {} //ParamIXB

       _aCor := {{"u_xBloqFat(1)"											    			  ,"BR_PINK", "Bloqueado por Credito"  		    },;		//Bloqueado por Credito
			     {"Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)"	  ,'ENABLE', "Pedido em Aberto" 				},;		//Pedido em Aberto
			     {"!Empty(SC5->C5_NOTA).Or.SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ)" 	  ,'DISABLE', "Pedido Encerrado"				},;	  	//Pedido Encerrado
			     {"!Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA).And. Empty(SC5->C5_BLQ)"   ,'BR_AMARELO', "Pedido Liberado"			    },;     //Pedido Liberado
			     {"SC5->C5_BLQ == '1'"														  ,'BR_AZUL'   , "Pedido Bloquedo por regra"	},;		//Pedido Bloquedo por regra
			     {"SC5->C5_BLQ == '2'"														  ,'BR_LARANJA', "Pedido Bloquedo por Verba"	}}		//Pedido Bloquedo por verba   

Return(_aCor) 

  