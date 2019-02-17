#include 'TOTVS.ch'
#include 'FWMVCDEF.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TMVC1
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
User Function TMVC1()
	/*Declarando as variáveis que serão utilizadas*/
	Local lRet := .T.
	Local aArea := ZZ8-&gt;(GetArea())
	Private oBrowse
	Private cChaveAux := ""

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZZ8")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription("DESCRIÇÃO")

	//Adiciona um filtro ao browse
	oBrowse:SetFilterDefault( "" )
		
	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Montar o menu Funcional
@author  Ademilson Nunes
@since   17-02-2019
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 		OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.TMVC1"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.TMVC1" 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.TMVC1" 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.TMVC1" 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.TMVC1" 	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" 		ACTION "VIEWDEF.TMVC1" 	OPERATION 9 ACCESS 0
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel 	 := ModelDef()
	Local bAvalCampo := {|cCampo| AllTrim(cCampo)+"|" $ "ZZ8_CODIGO|ZZ8_DESCR|ZZ8_NOME|"}
	Local oStr1		 := NIL
	Local nOperation := oModel:GetOperation()
	
	oStr1 := FWFormStruct(2, 'ZZ8')

	// Cria o objeto de View
	oView := FWFormView():New()
	oView:Refresh()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1,'CamposZZ8' )

    //Remove os campos que não irão aparecer	
	//oStr1:RemoveField( 'ZZ8_BLQ' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , 'Descricao' )
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})
	
	//Criando grupos
	oStr1:AddGroup( 'GRUPO01', 'Descrição'		, '', 1 )
	oStr1:AddGroup( 'GRUPO02', 'Funcionário'	, '', 2 )
	oStr1:AddGroup( 'GRUPO03', 'Outros'		    , '', 3 )
	
	// Colocando alguns campos por agrupamentos'
	oStr1:SetProperty( 'ZZ8_CODIGO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStr1:SetProperty( 'ZZ8_DESCR'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStr1:SetProperty( 'ZZ8_USER' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStr1:SetProperty( 'ZZ8_NOME' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )		
	oStr1:SetProperty( 'ZZ8_BLQ'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	
	
	//Criando um botão
	oView:AddUserButton( 'Novo botão', 'CLIPS', {|oView| alert("Você clicou aqui")} )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStr1:= FWFormStruct( 1, 'ZZ8', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados
	
	//Cria o objeto do Modelo de Dados
   //Irie usar uma função TMVC1 que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New('Descricao', /*bPreValidacao*/, { | oModel | TMVC1( oModel ) } , /*{ | oMdl | TMVC1C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Descrição')
	
	//Abaixo irei iniciar o campo X5_TABELA com o conteudo da sub-tabela
	oStr1:SetProperty('ZZ8_CODIGO' , MODEL_FIELD_INIT,{|| GetSXENum("ZZ8","ZZ8_CODIGO")} )

    //Abaixo irei bloquear/liberar os campos para edição
	oStr1:SetProperty('ZZ8_CODIGO' , MODEL_FIELD_WHEN,{|| .F. })
	oStr1:SetProperty('ZZ8_NOME'   , MODEL_FIELD_WHEN,{|| .F. })

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('CamposZZ8',,oStr1,{|oModel|TMVC1T(oModel)},,)
	
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZZ8_CODIGO', 'ZZ8_DESCR', 'ZZ8_USER' })
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposZZ8'):SetDescription('TabelaZZ8')
	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} TMVC1T
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function TMVC1T( oModel )
	Local lRet      := .T.
	Local oModelZZ8 := oModel:GetModel( 'CamposZZ8' )
	
	cChaveAux := ZZ8-&gt;ZZ8_CODIGO

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} TMVC1V
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
// Validações ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou não
//-------------------------------------------------------------------
Static Function TMVC1V( oModel )
	Local lRet      := .T.
	Local oModelZZ8 := oModel:GetModel( 'CamposZZ8' )
	Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()

	//Capturar o conteudo dos campos
	Local cChave	:= oModelZZ8:GetValue('ZZ8_CODIGO')
	Local cTabela	:= oModelZZ8:GetValue('ZZ8_DESCR')
	Local cDescri	:= oModelZZ8:GetValue('ZZ8_USER')
	Local cBlq		:= oModelZZ8:GetValue('ZZ8_BLQ')
	
	Begin Transaction
		
		if nOpc == 3 .or. nOpc == 4
			
			dbSelectArea("ZZ8")
			ZZ8-&gt;(dbSetOrder(1))
			ZZ8-&gt;(dbGoTop())
			If(ZZ8-&gt;(dbSeek(xFilial("ZZ8")+cChave)))
				if cChaveAux != cChave
					SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","TMVC1")
					lRet := .F.
				Endif
			Endif

			if Empty(cChave)
				SFCMsgErro("O campo chave é obrigatório!","TMVC1")
				lRet := .F.
			Endif
			
			if Empty(cDescri)
				SFCMsgErro("O campo descrição é obrigatório!","TMVC1")
				lRet := .F.
			Endif
			
		Endif
		
		if !lRet
			DisarmTransaction()
		Endif
		
	End Transaction
	
	RestArea(aArea)
	
	FwModelActive( oModel, .T. )
	
Return lRet