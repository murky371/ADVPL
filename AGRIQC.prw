#include "Protheus.ch"
#include 'Totvs.ch'
#include "FwMvcDef.ch" //Include respons�vel por fazer o Programa em MVC Funcionar


/*/{Protheus.doc} MVCZ5Z6
Fun��o para criar o programa de Pedidos acessando as tabelas SZ5 e SZ6
@type function
@version  
@author Placido
@since 29/06/2021
@return variant, return_description
/*/
User Function AGRIQC()
Local oBrowse   := FwLoadBrw("AGRIQC") //Digo o fonte que eu estou buscando o BrowseDef


oBrowse := FWmBrowse():New()
oBrowse:SetAlias("ZB1") //Cabe�alho
oBrowse:SetDescription("Cultura x Produto")
oBrowse:SetMenuDef("AGRIQC")

oBrowse:Activate()
return


/*/{Protheus.doc} BrowseDef
Static Function respons�vel pela Cria��o
@type function
@version  
@author Placido
@since 29/06/2021
@return variant, return_description
/*/
/*
Static Function BrowseDef()
Local oBrowse   := FwMBrowse():New()

oBrowse:SetAlias("ZB1") //Cabe�alho
oBrowse:SetDescription("Cultura x Diagnostico x Produto")

//oBrowse:AddLegend("SZ5->Z5_STATUS == '1'","GREEN"   ,"Pedido em Aberto")
//oBrowse:AddLegend("SZ5->Z5_STATUS == '2'","RED"     ,"Pedido em Finalizado")
//oBrowse:AddLegend("SZ5->Z5_STATUS == '3'","YELLOW"  ,"Pedido em Libera��o")

oBrowse:SetMenuDef("AGRIQAL")

return oBrowse
*/

Static Function MenuDef()
Local aMenu     := {}

ADD OPTION aMenu    TITLE "Visualizar"      ACTION "VIEWDEF.AGRIQC"    OPERATION     2 ACCESS 0 
ADD OPTION aMenu    TITLE "Incluir"         ACTION "VIEWDEF.AGRIQC"    OPERATION     3 ACCESS 0
ADD OPTION aMenu    TITLE "Alterar"         ACTION "VIEWDEF.AGRIQC"    OPERATION     4 ACCESS 0
ADD OPTION aMenu    TITLE "Excluir"         ACTION "VIEWDEF.AGRIQC"    OPERATION     5 ACCESS 0
ADD OPTION aMenu    TITLE 'Legenda'         ACTION 'u_SZ5LEG'          OPERATION     6 ACCESS 0
ADD OPTION aMenu    TITLE 'Sobre'           ACTION 'u_SZ5SOBR'         OPERATION     6 ACCESS 0

/*
2   VISUALIZA��O
3   INCLUS�O
4   ALTERA��O
5   EXCLUS�O
6   FUN��ES EXTRAS(SOBRE E LEGENDA)
*/
return aMenu


/*/{Protheus.doc} ModelDef
Fun��o Modelo do MVC - Esta fun��o � respons�vel pela montagem da estrutura dos dados
@type function
@version  
@author Placido
@since 29/06/2021
@return variant, return_description
/*/
Static Function ModelDef()
//Declaro o meu modelo de dados sem passar blocos de valida��o pois usaremos a valida��o padr�o do MVC
Local oModel        := MPFormModel():New("PAGRIQC",/*bPre*/,  /*bPos*/,  /*bCommit*/,/*bCancel*/)

//Crio as estruturas das tabelas PAI(SZ5) e FILHO(SZ6)
Local oPaiZB1      := FwFormStruct(1,"ZB1") //Master
Local oFilhoZB2    := FwFormStruct(1,"ZB2") //Detalhe

//Crio Modelos de dados Cabe�alho e Item
oModel:AddFields("ZB1MASTER",,oPaiZB1)
oModel:AddGrid("ZB2DETAIL","ZB1MASTER",oFilhoZB2,,,,,)//ESSAS v�rgulas em branco, s�o blocos de valida��o que n�o vamos usar


//O meu grid, ir� se relacionar com o cabe�alho, atrav�s dos campos FILIAL e CODIGO DE Pedido
oModel:SetRelation("ZB2DETAIL",{{"ZB2_FILIAL","xFilial('ZB2')"}},ZB2->(IndexKey(1)))
//Posso pegar a chave prim�ri da SX2 atrav�s do X2_UNICO
//Setamos a chave prim�ria, prevalece o que est� na SX2(X2_UNICO), se na X2 estiver preenchido
//N�o podemos ter dentro de uma Pedido, dois coment�rios com o mesmo c�digo
oModel:SetPrimarykey({"ZB1_FILIAL","ZB1_CODCUL"})

oModel:GetModel("ZB2DETAIL"):SetUniqueLine({"ZB2_CDIAG"})

oModel:SetDescription("Culturas x Produtos")
oModel:GetModel("ZB1MASTER"):SetDescription("Culturas")
oModel:GetModel("ZB2DETAIL"):SetDescription("Diagnosticos")

Return oModel


/*/{Protheus.doc} ViewDef
Fun��o Respons�vel pela parte visual do Programa
@type function
@version  
@author Placido
@since 29/06/2021
@return variant, return_description
/*/
Static Function ViewDef()
Local oView     := Nil

//Invoco o Model da fun��o que quero
Local oModel    := FwLoadModel("AGRIQC")

Local oPaiZB1      := FwFormStruct(2,"ZB1")
Local oFilhoZB2    := FwFormStruct(2,"ZB2") //Detalhe

//Removo o campo para n�o aparecer, j� que ele estar� sendo preenchido automaticamente pelo c�digo do Pedido do cabe�alho
oFilhoZB2:RemoveField("ZB2_CDIAG")


//Travo o campo de Codigo para n�o ser editado, ou seja, o campo CODIGO DE COMENTARIO do Pedido, ser� autom�tico e n�o poder� ser modificado
//oStFilhoZ6:SetProperty("Z6_ITEM",    MVC_VIEW_CANCHANGE, .F.)

//Travo o campo de TOTAL
//oStFilhoZ6:SetProperty("Z6_VALOR",    MVC_VIEW_CANCHANGE, .F.)

  
//Fa�o a instancia da fun��o FwFormView para a vari�vel oView
oView   := FwFormView():New()

oView:SetModel(oModel)

//Crio as views/vis�es/layout de cabe�alho e item, com as estruturas de dados criadas acima
oView:AddField("VIEWZB1",oPaiZB1,"ZB1MASTER")
oView:AddGrid("VIEWZB2",oFilhoZB2,"ZB2DETAIL")

//Fa�o o campo de Item ficar incremental
oView:AddIncrementField("ZB2DETAIL","ZB2_CDIAG") //Soma 1 ao campo de Item

//Criamos os BOX horizontais para CABE�ALHO E ITENS
oView:CreateHorizontalBox("CABEC",30) //760% do tamanho para cabe�alho
oView:CreateHorizontalBox("GRID1",70)  //40% para itens

//Amarro as views criadas aos BOX criados
oView:SetOwnerView("VIEWZB1","CABEC")
oView:SetOwnerView("VIEWZB2","GRID1")

//Darei t�tulos personalizados ao cabe�alho e coment�rios do Pedido
oView:EnableTitleView("VIEWZB1","Culturas")
oView:EnableTitleView("VIEWZB2","Diagnostico")


return oView


/*/{Protheus.doc} User Function SZ5LEG
    (long_description)
    @type  Function
    @author user
    @since 29/06/2021
    @version version
    @param param_name, param_type, param_descr
    @return aLegenda, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function SZ5LEGENDA()
Local aLegenda  := {}

aAdd(aLegenda,{"BR_VERDE",      "Pedido Aberto"})
aAdd(aLegenda,{"BR_AMARELO" , 	"Pedido em Andamento"})
aAdd(aLegenda,{"BR_VERMELHO", 	"Pedido Finalizado"})

BrwLegenda("Status dos Pedidos",,aLegenda)

Return aLegenda



/*/{Protheus.doc} User Function SZ5SOBRE
Exibe uma tela com uma mensagem sobre o Programa constru�do
    @type  Function
    @author user
    @since 29/06/2021
    @version version
    @param , param_type, param_descr
    @return return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function SZ5SOBRE()
Local cSobre

cSobre := "-<b>Minha primeira tela em MVC Modelo 3<br>"+;
"Este Sistema de Pedidos foi desenvolvido na Semana do Desenvolvedor Protheus 2.0"

MsgInfo(cSobre,"Sobre o Programador...")    
Return 

