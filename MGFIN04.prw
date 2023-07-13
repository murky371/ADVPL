#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'
#INCLUDE 'FwEditPanel.ch
#INCLUDE "TopConn.ch"



/*/{Protheus.doc} MGFIN04
Rotina MVC de cadastro de Operacao e CFOP 
@type function
@version  
@author Joao Goncalves
@since 6/19/2023
@return Nao retorna nada
/*/
User Function MGFIN04()

	Local oBrowse

	oBrowse := FWmBrowse():New()

	oBrowse:SetDescription(" Operacao x CFOP ")

	oBrowse:SetAlias("ZA5")


	oBrowse:Activate()
return


Static Function MenuDef()

	Local aRotina     := {}

	ADD OPTION aRotina    TITLE "Visualizar"      ACTION "VIEWDEF.MGFIN04"    OPERATION     2 ACCESS 0
	ADD OPTION aRotina    TITLE "Incluir"         ACTION "VIEWDEF.MGFIN04"    OPERATION     3 ACCESS 0
	ADD OPTION aRotina    TITLE "Alterar"         ACTION "VIEWDEF.MGFIN04"    OPERATION     4 ACCESS 0
	ADD OPTION aRotina    TITLE "Excluir"         ACTION "VIEWDEF.MGFIN04"    OPERATION     5 ACCESS 0

return aRotina


/*/{Protheus.doc} ModelDef
description
@type function
@version  
@author Joao Goncalves
@since 6/19/2023
@return oModel
/*/
Static Function ModelDef()
//Declaro o meu modelo de dados sem passar blocos de validaÃ§Ã£o pois usaremos a validaÃ§Ã£o padrÃ£o do MVC
	Local oPaiZA5      := FwFormStruct(1,"ZA5") //Master
	Local oFilhoZA6    := FwFormStruct(1,"ZA6") //Detalhe


	Local oModel       := MPFormModel():New("PMGFIN04",/*bPre*/, /*bPos*/,  /*bCommit*/,/*bCancel*/)

//Crio as estruturas das tabelas PAI(SZ5) e FILHO(SZ6)

//Crio Modelos de dados CabeÃ§alho e Item
	oModel:AddFields('ZA5MASTER', /*cOwner*/, oPaiZA5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//ESSAS vÃ­rgulas em branco, sÃ£o blocos de validaÃ§Ã£o que nÃ£o vamos usar
	oModel:AddGrid("ZA6DETAIL","ZA5MASTER",oFilhoZA6,,,,,)

//O meu grid, irÃ¡ se relacionar com o cabeÃ§alho, atravÃ©s dos campos FILIAL e CODIGO DE Pedido e CFOP
	oModel:SetRelation("ZA6DETAIL",{{"ZA6_FILIAL","xFILIAL('ZA6')","ZA6_COD","ZA5_COD"}/*, {"ZA6_CDIAG", "ZA5_CDIAG"}*/},ZA6->(IndexKey(1)))

// Adiciona a chave primaria da tabela principal
	oModel:SetPrimarykey({"ZA5_FILIAL","ZA5_COD"})

// oModel:GetModel("ZA6DETAIL"):SetUniqueLine({"ZA6_CDIAG"})

// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription("Tipo operacao e CFOP Operacao")

// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel("ZA5MASTER"):SetDescription("Tipo Operaçao")

// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel("ZA6DETAIL"):SetDescription("CFOP Operacao")


Return oModel


/*/{Protheus.doc} ViewDef
description
@type function
@version  
@author Joao Goncalves
@since 6/19/2023
@return oView
/*/
Static Function ViewDef()
	Local oView

//Invoco o Model da funÃ§Ã£o que quero
	Local oModel    := FwLoadModel("MGFIN04")

	Local oPaiZA5      := FwFormStruct(2,"ZA5")
	Local oFilhoZA6    := FwFormStruct(2,"ZA6") //Detalhe
// Local oFilhoZB3    := FwFormStruct(2,"ZB3") //Detalhe


//FaÃ§o a instancia da funÃ§Ã£o FwFormView para a variÃ¡vel oView
	oView   := FwFormView():New()

	oView:SetModel(oModel)

//Crio as views/visÃµes/layout de cabeÃ§alho e item, com as estruturas de dados criadas acima
	oView:AddField("VIEWZA5",oPaiZA5,"ZA5MASTER")
	oView:AddGrid("VIEWZA6",oFilhoZA6,"ZA6DETAIL")

//FaÃ§o o campo de Item ficar incremental
// oView:AddIncrementField("ZA6DETAIL","ZA6_CDIAG") //Soma 1 ao campo de Item

//Criamos os BOX horizontais para CABEÃ‡ALHO E ITENS
	oView:CreateHorizontalBox("CABEC",30) //70% do tamanho para cabeÃ§alho
	oView:CreateHorizontalBox("GRID1",70)  //30% para itens


//Amarro as views criadas aos BOX criados
	oView:SetOwnerView("VIEWZA5","CABEC")
	oView:SetOwnerView("VIEWZA6","GRID1")


//Darei tÃ­tulos personalizados ao cabeÃ§alho e comentÃ¡rios do Pedido
	oView:EnableTitleView("VIEWZA5","Tipo Operacao")
	oView:EnableTitleView("VIEWZA6","CFOP Operacao")



return oView

